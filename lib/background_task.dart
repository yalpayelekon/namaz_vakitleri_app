import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

const fetchPrayerTask = "fetchPrayerTask";

Future<void> callbackDispatcher() async {
  Workmanager().executeTask((task, inputData) async {
    if (task == fetchPrayerTask) {
      try {
        // Konum al
        final position = await Geolocator.getCurrentPosition();
        final lat = position.latitude;
        final lng = position.longitude;

        // API çağrısı
        final response = await http.get(
          Uri.parse(
            'https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=13',
          ),
        );

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('lastPrayerTimes', response.body); // Local cache
          prefs.setString('lastUpdateTime', DateTime.now().toIso8601String());
        }
      } catch (_) {}
    }
    return Future.value(true);
  });
}
