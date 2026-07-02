import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'city_store.dart';
import 'prayer_service.dart';
import 'prayer_times.dart';
import 'widget_service.dart';

const fetchPrayerTask = "fetchPrayerTask";

Future<void> callbackDispatcher() async {
  Workmanager().executeTask((task, inputData) async {
    if (task == fetchPrayerTask) {
      try {
        final prefs = await SharedPreferences.getInstance();
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
          cityName = prefs.getString(CityStore.selectedCityNameKey) ?? 'Şehir';
        } else {
          final position = await Geolocator.getCurrentPosition();
          lat = position.latitude;
          lng = position.longitude;
          cityName = await PrayerService.resolveCityName(lat, lng);
        }

        final response = await http.get(
          Uri.parse(
            'https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=13',
          ),
        );

        if (response.statusCode == 200) {
          final prayerTimes = PrayerTimes.fromJson(json.decode(response.body));

          await WidgetService.savePrayerTimes(
            fajr: prayerTimes.fajr,
            sunrise: prayerTimes.sunrise,
            dhuhr: prayerTimes.dhuhr,
            asr: prayerTimes.asr,
            maghrib: prayerTimes.maghrib,
            isha: prayerTimes.isha,
            city: cityName,
            triggerUpdate: false,
          );

          await prefs.setString('lastPrayerTimes', response.body);
          await prefs.setString(
            'lastUpdateTime',
            DateTime.now().toIso8601String(),
          );
        }
      } catch (_) {}
    }
    return Future.value(true);
  });
}
