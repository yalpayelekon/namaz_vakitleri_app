import 'package:flutter/material.dart';
import 'dart:math';

import 'city_picker_sheet.dart';
import 'city_store.dart';
import 'prayer_times.dart';
import 'prayer_service.dart';
import 'widget_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PrayerTimes? prayerTimes;
  String city = 'Yükleniyor...';
  String dailyQuote = '';
  bool useDeviceLocation = true;
  bool isLoading = true;

  final List<String> quotes = [
    '“Namaz müminin miracıdır.”',
    '“Sabır ve namaz ile Allah’tan yardım dileyin.” (Bakara 2:45)',
    '“Gündüz ve gecenin bir kısmında namaz kıl.” (İsra 17:78)',
    '“Kıyamet günü kulun ilk sorgusu namazdandır.” (Hadis)',
  ];

  @override
  void initState() {
    super.initState();
    _pickRandomQuote();
    _loadData();
  }

  void _pickRandomQuote() {
    final rnd = Random();
    setState(() {
      dailyQuote = quotes[rnd.nextInt(quotes.length)];
    });
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    useDeviceLocation = await CityStore.useDeviceLocation();
    final result = await PrayerService.fetchPrayerTimes();

    if (!mounted) return;

    setState(() {
      prayerTimes = result.$1;
      city = result.$2;
      isLoading = false;
    });

    if (prayerTimes != null) {
      await WidgetService.savePrayerTimes(
        fajr: prayerTimes!.fajr,
        sunrise: prayerTimes!.sunrise,
        dhuhr: prayerTimes!.dhuhr,
        asr: prayerTimes!.asr,
        maghrib: prayerTimes!.maghrib,
        isha: prayerTimes!.isha,
        city: city,
      );
    }
  }

  Future<void> _openCityPicker() async {
    final selectedCity = await showCityPickerSheet(context);
    if (selectedCity == null || !mounted) return;

    await CityStore.saveSelectedCity(selectedCity);
    await _loadData();
  }

  Future<void> _useCurrentLocation() async {
    await CityStore.useCurrentLocation();
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Namaz Vakitleri'),
        actions: [
          IconButton(
            tooltip: 'Konumumu kullan',
            onPressed: isLoading ? null : _useCurrentLocation,
            icon: Icon(
              Icons.my_location,
              color: useDeviceLocation ? null : Colors.white54,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : prayerTimes == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(city),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _openCityPicker,
                        icon: const Icon(Icons.location_city),
                        label: const Text('Şehir seç'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: _openCityPicker,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$city - ${prayerTimes!.date}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            const Icon(Icons.edit_location_alt, size: 20),
                          ],
                        ),
                      ),
                      if (!useDeviceLocation)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Manuel şehir seçimi aktif',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      const SizedBox(height: 16),
                      _buildTimeRow('İmsak', prayerTimes!.fajr),
                      _buildTimeRow('Güneş', prayerTimes!.sunrise),
                      _buildTimeRow('Öğle', prayerTimes!.dhuhr),
                      _buildTimeRow('İkindi', prayerTimes!.asr),
                      _buildTimeRow('Akşam', prayerTimes!.maghrib),
                      _buildTimeRow('Yatsı', prayerTimes!.isha),
                      const SizedBox(height: 24),
                      const Text(
                        'Günün Ayeti / Hadisi:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(dailyQuote, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTimeRow(String label, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(time, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
