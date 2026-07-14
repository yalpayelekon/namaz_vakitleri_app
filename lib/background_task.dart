import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'city_store.dart';
import 'prayer_times.dart';
import 'widget_service.dart';

const fetchPrayerTask = 'fetchPrayerTask';

/// Redundant nightly windows so at least one run usually succeeds.
const _nightlyHours = [1, 2, 3];

const _lastUpdateTimeKey = 'lastUpdateTime';

Duration delayUntilHour(int hour) {
  final now = DateTime.now();
  var next = DateTime(now.year, now.month, now.day, hour);
  if (!now.isBefore(next)) {
    next = next.add(const Duration(days: 1));
  }
  return next.difference(now);
}

String _uniqueNameForHour(int hour) =>
    'daily_prayer_update_${hour.toString().padLeft(2, '0')}';

Future<void> initializeBackgroundTasks() async {
  if (!Platform.isAndroid) return;

  await Workmanager().initialize(callbackDispatcher);
  // Önceki tek 03:00 görevi kalmasın.
  await Workmanager().cancelByUniqueName('daily_prayer_update');

  for (final hour in _nightlyHours) {
    await Workmanager().registerPeriodicTask(
      _uniqueNameForHour(hour),
      fetchPrayerTask,
      frequency: const Duration(hours: 24),
      initialDelay: delayUntilHour(hour),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    DartPluginRegistrant.ensureInitialized();

    if (task != fetchPrayerTask && task != Workmanager.iOSBackgroundTask) {
      return true;
    }

    try {
      await _fetchAndSavePrayerTimes();
      return true;
    } catch (_) {
      return false;
    }
  });
}

Future<void> _fetchAndSavePrayerTimes() async {
  final prefs = await SharedPreferences.getInstance();

  // Another nightly slot already refreshed today — skip.
  if (_alreadyUpdatedToday(prefs)) {
    return;
  }

  final useDeviceLocation =
      prefs.getBool(CityStore.useDeviceLocationKey) ?? true;

  late final double lat;
  late final double lng;
  late final String cityName;

  if (!useDeviceLocation &&
      prefs.containsKey(CityStore.selectedCityLatKey) &&
      prefs.containsKey(CityStore.selectedCityLngKey)) {
    lat = prefs.getDouble(CityStore.selectedCityLatKey)!;
    lng = prefs.getDouble(CityStore.selectedCityLngKey)!;
    cityName = prefs.getString(CityStore.selectedCityNameKey) ??
        prefs.getString('city') ??
        'Şehir';
  } else {
    final coords = await _resolveCoordinates(prefs);
    if (coords == null) {
      throw StateError('No coordinates available for background update');
    }
    lat = coords.$1;
    lng = coords.$2;
    cityName = prefs.getString('city') ??
        prefs.getString(CityStore.selectedCityNameKey) ??
        'Şehir';
  }

  final response = await http
      .get(
        Uri.parse(
          'https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=13',
        ),
      )
      .timeout(const Duration(seconds: 20));

  if (response.statusCode != 200) {
    throw HttpException('Aladhan API ${response.statusCode}');
  }

  final prayerTimes = PrayerTimes.fromJson(
    json.decode(response.body) as Map<String, dynamic>,
  );

  await WidgetService.savePrayerTimes(
    fajr: prayerTimes.fajr,
    sunrise: prayerTimes.sunrise,
    dhuhr: prayerTimes.dhuhr,
    asr: prayerTimes.asr,
    maghrib: prayerTimes.maghrib,
    isha: prayerTimes.isha,
    city: cityName,
    latitude: lat,
    longitude: lng,
    // MethodChannel may be unavailable in a headless isolate;
    // NamazApplication refreshes the widget when prefs change.
    triggerUpdate: false,
  );

  await prefs.setString(_lastUpdateTimeKey, DateTime.now().toIso8601String());
}

bool _alreadyUpdatedToday(SharedPreferences prefs) {
  final raw = prefs.getString(_lastUpdateTimeKey);
  if (raw == null) return false;

  final last = DateTime.tryParse(raw);
  if (last == null) return false;

  final now = DateTime.now();
  return last.year == now.year &&
      last.month == now.month &&
      last.day == now.day;
}

Future<(double, double)?> _resolveCoordinates(SharedPreferences prefs) async {
  final lastLat = prefs.getDouble(WidgetService.lastLatKey);
  final lastLng = prefs.getDouble(WidgetService.lastLngKey);
  if (lastLat != null && lastLng != null) {
    return (lastLat, lastLng);
  }

  final cityLat = prefs.getDouble(CityStore.selectedCityLatKey);
  final cityLng = prefs.getDouble(CityStore.selectedCityLngKey);
  if (cityLat != null && cityLng != null) {
    return (cityLat, cityLng);
  }

  try {
    Position? position = await Geolocator.getLastKnownPosition();
    position ??= await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 15),
      ),
    ).timeout(const Duration(seconds: 15));
    return (position.latitude, position.longitude);
  } catch (_) {
    return null;
  }
}
