import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'city_store.dart';
import 'data/turkish_cities.dart';
import 'prayer_times.dart';
import 'widget_service.dart';

class PrayerService {
  static const _networkTimeout = Duration(seconds: 15);
  static const _geocodeTimeout = Duration(seconds: 5);

  static Future<(PrayerTimes?, String)> fetchPrayerTimes() async {
    try {
      final useDeviceLocation = await CityStore.useDeviceLocation();
      final selectedCity = await CityStore.selectedCity();

      if (!useDeviceLocation && selectedCity != null) {
        return await _fetchByCoordinates(
          selectedCity.latitude,
          selectedCity.longitude,
          cityName: selectedCity.name,
        );
      }

      final positionResult = await _getDevicePosition();
      if (positionResult == null) {
        return (null, 'Konum alınamadı');
      }

      return await _fetchByCoordinates(
        positionResult.latitude,
        positionResult.longitude,
      );
    } catch (e) {
      return (null, 'Hata: $e');
    }
  }

  static Future<Position?> _getDevicePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    Position? position = await Geolocator.getLastKnownPosition();
    try {
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      ).timeout(_networkTimeout);
    } catch (_) {
      return position;
    }

    return position;
  }

  static Future<(PrayerTimes?, String)> _fetchByCoordinates(
    double latitude,
    double longitude, {
    String? cityName,
  }) async {
    final response = await http
        .get(
          Uri.parse(
            'https://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude&method=13',
          ),
        )
        .timeout(_networkTimeout);

    if (response.statusCode != 200) {
      return (null, 'API hatası');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final prayerTimes = PrayerTimes.fromJson(data);
    final fallbackCity = cityName ?? findNearestCity(latitude, longitude).name;
    final resolvedCity = await resolveCityName(latitude, longitude)
        .timeout(_geocodeTimeout, onTimeout: () => fallbackCity);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(WidgetService.lastLatKey, latitude);
    await prefs.setDouble(WidgetService.lastLngKey, longitude);

    return (prayerTimes, cityName ?? resolvedCity);
  }

  static Future<String> resolveCityName(double latitude, double longitude) async {
    final fromPlacemark = await _cityFromPlacemark(latitude, longitude);
    if (fromPlacemark != null) {
      return fromPlacemark;
    }

    final fromNominatim = await _cityFromNominatim(latitude, longitude);
    if (fromNominatim != null) {
      return fromNominatim;
    }

    return findNearestCity(latitude, longitude).name;
  }

  static Future<String?> _cityFromPlacemark(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(_geocodeTimeout);
      if (placemarks.isEmpty) {
        return null;
      }

      final placemark = placemarks.first;
      for (final candidate in [
        placemark.locality,
        placemark.subAdministrativeArea,
        placemark.administrativeArea,
        placemark.name,
      ]) {
        if (candidate != null && candidate.trim().isNotEmpty) {
          return candidate.trim();
        }
      }
    } catch (_) {}

    return null;
  }

  static Future<String?> _cityFromNominatim(
    double latitude,
    double longitude,
  ) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=$latitude&lon=$longitude&format=json&accept-language=tr&zoom=10',
      );
      final response = await http
          .get(
            uri,
            headers: const {'User-Agent': 'namaz_vakitleri_app/1.0'},
          )
          .timeout(_networkTimeout);

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>?;
      if (address == null) {
        return null;
      }

      for (final key in ['city', 'town', 'province', 'state', 'county']) {
        final value = address[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    } catch (_) {}

    return null;
  }
}
