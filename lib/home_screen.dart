import 'package:flutter/material.dart';
import 'dart:math';

import 'prayer_times.dart';
import 'prayer_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PrayerTimes? prayerTimes;
  String city = 'Yükleniyor...';
  String dailyQuote = '';

  final List<String> quotes = [
    '“Namaz müminin miracıdır.”',
    '“Sabır ve namaz ile Allah’tan yardım dileyin.” (Bakara 2:45)',
    '“Gündüz ve gecenin bir kısmında namaz kıl.” (İsra 17:78)',
    '“Kıyamet günü kulun ilk sorgusu namazdandır.” (Hadis)',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _pickRandomQuote();
  }

  void _pickRandomQuote() {
    final rnd = Random();
    setState(() {
      dailyQuote = quotes[rnd.nextInt(quotes.length)];
    });
  }

  Future<void> _loadData() async {
    final result = await PrayerService.fetchPrayerTimes();
    setState(() {
      prayerTimes = result.$1;
      city = result.$2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Namaz Vakitleri')),
      body: prayerTimes == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$city - ${prayerTimes!.date}',
                    style: const TextStyle(fontSize: 18),
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
