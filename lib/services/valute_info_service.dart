import 'dart:convert';
import 'package:flutter/services.dart';

class ValuteInfoService {
  static final Map<String, Map<String, dynamic>> _currencyByCode = {};
  static final Map<String, Map<String, dynamic>> _currencyByName = {};
  static final Map<String, List<String>> _countriesByCurrency = {};

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;

    final jsonString = await rootBundle.loadString('assets/data/currencies.json');
    final lines = const LineSplitter().convert(jsonString);

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      final c = json.decode(line);

      final code = c['currency'].toString().toUpperCase();
      final name = c['currency_name'].toString();
      final countriesString = c['countries'].toString();

      final countries = countriesString.split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      _currencyByCode[code] = {
        'code': code,
        'name': name,
        'countries': countries,
      };

      _currencyByName[name.toLowerCase()] = _currencyByCode[code]!;

      _countriesByCurrency[code] = countries;
    }

    _loaded = true;
  }

  static Map<String, dynamic>? findByCode(String code) {
    return _currencyByCode[code.toUpperCase()];
  }

  static Map<String, dynamic>? findByName(String name) {
    return _currencyByName[name.toLowerCase()];
  }

  static List<String> getCountries(String code) {
    return _countriesByCurrency[code.toUpperCase()] ?? [];
  }

static List<Map<String, dynamic>> search(String query) {
  query = query.toLowerCase();
  final results = <Map<String, dynamic>>[];

  for (final c in _currencyByCode.values) {
    final code = c['code'].toString().toLowerCase();
    final name = c['name'].toString().toLowerCase();
    final countries = (c['countries'] as List).map((e) => e.toString().toLowerCase()).toList();

    final matchesCode = code.contains(query);
    final matchesName = name.contains(query);
    final matchesCountry = countries.any((country) => country.contains(query));

    if (matchesCode || matchesName || matchesCountry) {
      results.add(c);
    }
  }

  return results;
}

}
