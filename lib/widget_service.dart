import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetService {
  static const _channel = MethodChannel('com.example.namaz_vakitleri_app/widget');

  static Future<void> savePrayerTimes({
    required String fajr,
    required String sunrise,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
    required String city,
    bool triggerUpdate = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fajr', fajr);
    await prefs.setString('sunrise', sunrise);
    await prefs.setString('dhuhr', dhuhr);
    await prefs.setString('asr', asr);
    await prefs.setString('maghrib', maghrib);
    await prefs.setString('isha', isha);
    await prefs.setString('city', city);
    if (triggerUpdate) {
      await updateWidgets();
    }
  }

  static Future<void> updateWidgets() async {
    try {
      await _channel.invokeMethod<void>('updateWidgets');
    } catch (_) {}
  }
}
