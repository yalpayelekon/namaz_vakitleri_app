import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'city_store.dart';
import 'data/turkish_cities.dart';
import 'prayer_times.dart';

class PrayerService {
  static Future<(PrayerTimes?, String)> fetchPrayerTimes() async {
    try {
      final useDeviceLocation = await CityStore.useDeviceLocation();
      final selectedCity = await CityStore.selectedCity();

      if (!useDeviceLocation && selectedCity != null) {
        return _fetchByCoordinates(
          selectedCity.latitude,
          selectedCity.longitude,
          cityName: selectedCity.name,
        );
      }

      final positionResult = await _getDevicePosition();
      if (positionResult == null) {
        return (null, 'Konum alınamadı');
      }

      return _fetchByCoordinates(
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
    position ??= await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );

    return position;
  }

  static Future<(PrayerTimes?, String)> _fetchByCoordinates(
    double latitude,
    double longitude, {
    String? cityName,
  }) async {
    final response = await http.get(
      Uri.parse(
        'https://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude&method=13',
      ),
    );

    if (response.statusCode != 200) {
      return (null, 'API hatası');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final prayerTimes = PrayerTimes.fromJson(data);
    final city = cityName ?? await resolveCityName(latitude, longitude);

    return (prayerTimes, city);
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
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
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
      final response = await http.get(
        uri,
        headers: const {'User-Agent': 'namaz_vakitleri_app/1.0'},
      );

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
