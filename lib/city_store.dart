import 'package:shared_preferences/shared_preferences.dart';

import 'models/city.dart';

class CityStore {
  static const useDeviceLocationKey = 'use_device_location';
  static const selectedCityNameKey = 'selected_city_name';
  static const selectedCityLatKey = 'selected_city_lat';
  static const selectedCityLngKey = 'selected_city_lng';

  static Future<bool> useDeviceLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(useDeviceLocationKey) ?? true;
  }

  static Future<City?> selectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(selectedCityNameKey);
    final lat = prefs.getDouble(selectedCityLatKey);
    final lng = prefs.getDouble(selectedCityLngKey);

    if (name == null || lat == null || lng == null) {
      return null;
    }

    return City(name: name, latitude: lat, longitude: lng);
  }

  static Future<void> saveSelectedCity(City city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(useDeviceLocationKey, false);
    await prefs.setString(selectedCityNameKey, city.name);
    await prefs.setDouble(selectedCityLatKey, city.latitude);
    await prefs.setDouble(selectedCityLngKey, city.longitude);
  }

  static Future<void> useCurrentLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(useDeviceLocationKey, true);
    await prefs.remove(selectedCityNameKey);
    await prefs.remove(selectedCityLatKey);
    await prefs.remove(selectedCityLngKey);
  }
}
