import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'prayer_times.dart';

class PrayerService {
  static Future<(PrayerTimes?, String)> fetchPrayerTimes() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return (null, 'Konum kapalı');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return (null, 'Konum izni reddedildi');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return (null, 'Konum izni kalıcı olarak reddedildi');
      }

      // Konum verisi al
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final double lat = position.latitude;
      final double lng = position.longitude;

      // API çağrısı
      final response = await http.get(
        Uri.parse(
          'https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=13',
        ),
      );

      if (response.statusCode != 200) {
        return (null, 'API hatası');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final prayerTimes = PrayerTimes.fromJson(data);

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final city = placemarks.isNotEmpty
          ? placemarks.first.locality ?? 'Bilinmeyen'
          : 'Bilinmeyen';

      return (prayerTimes, city);
    } catch (e) {
      return (null, 'Hata: $e');
    }
  }
}
