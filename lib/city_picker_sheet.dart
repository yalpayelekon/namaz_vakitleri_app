import 'package:flutter/material.dart';

import 'data/turkish_cities.dart';
import 'models/city.dart';

Future<City?> showCityPickerSheet(BuildContext context) {
  return showModalBottomSheet<City>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _CityPickerSheet(),
  );
}

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet();

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<City> get _filteredCities {
    final normalized = _normalize(_query);
    if (normalized.isEmpty) {
      return turkishCities;
    }

    return turkishCities
        .where((city) => _normalize(city.name).contains(normalized))
        .toList();
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('İ', 'i');
  }

  @override
  Widget build(BuildContext context) {
    final cities = _filteredCities;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Şehir Seç',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Şehir ara...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];
                  return ListTile(
                    title: Text(city.name),
                    onTap: () => Navigator.pop(context, city),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
