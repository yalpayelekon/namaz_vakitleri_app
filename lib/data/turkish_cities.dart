import 'dart:math';

import '../models/city.dart';

const turkishCities = [
  City(name: 'Adana', latitude: 37.0000, longitude: 35.3213),
  City(name: 'Adıyaman', latitude: 37.7648, longitude: 38.2786),
  City(name: 'Afyonkarahisar', latitude: 38.7507, longitude: 30.5567),
  City(name: 'Ağrı', latitude: 39.7191, longitude: 43.0503),
  City(name: 'Aksaray', latitude: 38.3687, longitude: 34.0370),
  City(name: 'Amasya', latitude: 40.6499, longitude: 35.8353),
  City(name: 'Ankara', latitude: 39.9334, longitude: 32.8597),
  City(name: 'Antalya', latitude: 36.8969, longitude: 30.7133),
  City(name: 'Ardahan', latitude: 41.1105, longitude: 42.7022),
  City(name: 'Artvin', latitude: 41.1828, longitude: 41.8183),
  City(name: 'Aydın', latitude: 37.8560, longitude: 27.8416),
  City(name: 'Balıkesir', latitude: 39.6484, longitude: 27.8826),
  City(name: 'Bartın', latitude: 41.6344, longitude: 32.3375),
  City(name: 'Batman', latitude: 37.8812, longitude: 41.1351),
  City(name: 'Bayburt', latitude: 40.2552, longitude: 40.2249),
  City(name: 'Bilecik', latitude: 40.1429, longitude: 29.9793),
  City(name: 'Bingöl', latitude: 38.8853, longitude: 40.4983),
  City(name: 'Bitlis', latitude: 38.3938, longitude: 42.1232),
  City(name: 'Bolu', latitude: 40.7395, longitude: 31.6116),
  City(name: 'Burdur', latitude: 37.7203, longitude: 30.2908),
  City(name: 'Bursa', latitude: 40.1885, longitude: 29.0610),
  City(name: 'Çanakkale', latitude: 40.1553, longitude: 26.4142),
  City(name: 'Çankırı', latitude: 40.6013, longitude: 33.6134),
  City(name: 'Çorum', latitude: 40.5506, longitude: 34.9556),
  City(name: 'Denizli', latitude: 37.7765, longitude: 29.0864),
  City(name: 'Diyarbakır', latitude: 37.9144, longitude: 40.2306),
  City(name: 'Düzce', latitude: 40.8438, longitude: 31.1565),
  City(name: 'Edirne', latitude: 41.6818, longitude: 26.5623),
  City(name: 'Elazığ', latitude: 38.6810, longitude: 39.2264),
  City(name: 'Erzincan', latitude: 39.7500, longitude: 39.5000),
  City(name: 'Erzurum', latitude: 39.9055, longitude: 41.2658),
  City(name: 'Eskişehir', latitude: 39.7767, longitude: 30.5206),
  City(name: 'Gaziantep', latitude: 37.0662, longitude: 37.3833),
  City(name: 'Giresun', latitude: 40.9128, longitude: 38.3895),
  City(name: 'Gümüşhane', latitude: 40.4386, longitude: 39.5086),
  City(name: 'Hakkari', latitude: 37.5744, longitude: 43.7408),
  City(name: 'Hatay', latitude: 36.4018, longitude: 36.3498),
  City(name: 'Iğdır', latitude: 39.9167, longitude: 44.0450),
  City(name: 'Isparta', latitude: 37.7648, longitude: 30.5566),
  City(name: 'İstanbul', latitude: 41.0082, longitude: 28.9784),
  City(name: 'İzmir', latitude: 38.4192, longitude: 27.1287),
  City(name: 'Kahramanmaraş', latitude: 37.5858, longitude: 36.9371),
  City(name: 'Karabük', latitude: 41.2061, longitude: 32.6204),
  City(name: 'Karaman', latitude: 37.1759, longitude: 33.2287),
  City(name: 'Kars', latitude: 40.6013, longitude: 43.0975),
  City(name: 'Kastamonu', latitude: 41.3887, longitude: 33.7827),
  City(name: 'Kayseri', latitude: 38.7312, longitude: 35.4787),
  City(name: 'Kilis', latitude: 36.7184, longitude: 37.1212),
  City(name: 'Kırıkkale', latitude: 39.8468, longitude: 33.5153),
  City(name: 'Kırklareli', latitude: 41.7333, longitude: 27.2167),
  City(name: 'Kırşehir', latitude: 39.1425, longitude: 34.1709),
  City(name: 'Kocaeli', latitude: 40.8533, longitude: 29.8815),
  City(name: 'Konya', latitude: 37.8746, longitude: 32.4932),
  City(name: 'Kütahya', latitude: 39.4167, longitude: 29.9833),
  City(name: 'Malatya', latitude: 38.3552, longitude: 38.3095),
  City(name: 'Manisa', latitude: 38.6191, longitude: 27.4289),
  City(name: 'Mardin', latitude: 37.3212, longitude: 40.7245),
  City(name: 'Mersin', latitude: 36.8121, longitude: 34.6415),
  City(name: 'Muğla', latitude: 37.2153, longitude: 28.3636),
  City(name: 'Muş', latitude: 38.9462, longitude: 41.7539),
  City(name: 'Nevşehir', latitude: 38.6939, longitude: 34.6857),
  City(name: 'Niğde', latitude: 37.9667, longitude: 34.6833),
  City(name: 'Ordu', latitude: 40.9839, longitude: 37.8764),
  City(name: 'Osmaniye', latitude: 37.0742, longitude: 36.2478),
  City(name: 'Rize', latitude: 41.0201, longitude: 40.5234),
  City(name: 'Sakarya', latitude: 40.7569, longitude: 30.3781),
  City(name: 'Samsun', latitude: 41.2867, longitude: 36.3300),
  City(name: 'Şanlıurfa', latitude: 37.1591, longitude: 38.7969),
  City(name: 'Siirt', latitude: 37.9333, longitude: 41.9500),
  City(name: 'Sinop', latitude: 42.0231, longitude: 35.1531),
  City(name: 'Sivas', latitude: 39.7477, longitude: 37.0179),
  City(name: 'Şırnak', latitude: 37.4187, longitude: 42.4918),
  City(name: 'Tekirdağ', latitude: 40.9833, longitude: 27.5167),
  City(name: 'Tokat', latitude: 40.3167, longitude: 36.5500),
  City(name: 'Trabzon', latitude: 41.0015, longitude: 39.7178),
  City(name: 'Tunceli', latitude: 39.1079, longitude: 39.5401),
  City(name: 'Uşak', latitude: 38.6823, longitude: 29.4082),
  City(name: 'Van', latitude: 38.4891, longitude: 43.4089),
  City(name: 'Yalova', latitude: 40.6500, longitude: 29.2667),
  City(name: 'Yozgat', latitude: 39.8181, longitude: 34.8147),
  City(name: 'Zonguldak', latitude: 41.4564, longitude: 31.7987),
];

City findNearestCity(double latitude, double longitude) {
  City nearest = turkishCities.first;
  var minDistance = double.infinity;

  for (final city in turkishCities) {
    final distance = _haversineKm(
      latitude,
      longitude,
      city.latitude,
      city.longitude,
    );
    if (distance < minDistance) {
      minDistance = distance;
      nearest = city;
    }
  }

  return nearest;
}

double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  return earthRadiusKm * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _toRadians(double degrees) => degrees * pi / 180;
