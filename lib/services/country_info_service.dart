import 'dart:convert';
import 'package:flutter/services.dart';

class CountryInfoService {
  static List<dynamic> _countries = [];

  static final Map<String, Map<String, dynamic>> _currencyByCode = {};
  static final Map<String, Map<String, dynamic>> _countryByIso = {};
  static final Map<String, Map<String, dynamic>> _countryByName = {};
  static final Map<String, List<Map<String, dynamic>>> _genericCurrencyGroups = {};

  static bool _loaded = false;

  // ⭐ Carica countries.json una sola volta
  static Future<void> load() async {
    if (_loaded) return;

    final jsonString = await rootBundle.loadString('assets/data/countries.json');
    _countries = json.decode(jsonString);

    for (final c in _countries) {
      final iso = c['iso'].toString().toUpperCase();
      final name = c['name'].toString().toLowerCase();
      final currency = c['currency'].toString().toUpperCase();
      final currencyName = c['currency_name'].toString().toLowerCase();

      // Indicizzazione per ISO
      _countryByIso[iso] = c;

      // Indicizzazione per nome nazione
      _countryByName[name] = c;

      // Indicizzazione per codice valuta
      _currencyByCode[currency] = {
        'code': currency,
        'name': c['currency_name'],
        'country': c['name'],
      };

      // Indicizzazione per valute generiche (dollaro, peso, franco…)
      final generic = _extractGenericCurrencyName(currencyName);
      if (generic != null) {
        _genericCurrencyGroups.putIfAbsent(generic, () => []);
        _genericCurrencyGroups[generic]!.add({
          'country': c['name'],
          'currency': currency,
          'currency_name': c['currency_name'],
        });
      }
    }

    _loaded = true;
  }

  // ⭐ Estrae il nome generico della valuta (dollaro, peso, franco…)
  static String? _extractGenericCurrencyName(String currencyName) {
    final parts = currencyName.split(" ");
    if (parts.isEmpty) return null;
    return parts[0];
  }

  // ⭐ Ricerca globale: name, iso, currency, currency_name
  static List<Map<String, dynamic>> searchAll(String query) {
    query = query.toLowerCase();

    final List<Map<String, dynamic>> results = [];

    for (final c in _countries) {
      final name = c['name'].toString().toLowerCase();
      final iso = c['iso'].toString().toLowerCase();
      final currency = c['currency'].toString().toLowerCase();
      final currencyName = c['currency_name'].toString().toLowerCase();

      if (name.contains(query) ||
          iso.contains(query) ||
          currency.contains(query) ||
          currencyName.contains(query)) {
        results.add(c);
      }
    }

    return results;
  }

  // ⭐ Ricerca per codice valuta (EUR, USD…)
  static Map<String, dynamic>? findCurrencyByCode(String code) {
    return _currencyByCode[code.toUpperCase()];
  }

  // ⭐ Ricerca per nome valuta specifica (Euro, Yen…)
  static Map<String, dynamic>? findSpecificCurrencyByName(String name) {
    name = name.toLowerCase();
    try {
      return _currencyByCode.values.firstWhere(
        (c) => c['name'].toString().toLowerCase().contains(name),
      );
    } catch (_) {
      return null;
    }
  }

  // ⭐ Ricerca per nome valuta generica (Dollaro, Peso…)
  static List<Map<String, dynamic>> findGenericCurrencyMatches(String generic) {
    generic = generic.toLowerCase();
    return _genericCurrencyGroups[generic] ?? [];
  }

  // ⭐ Ricerca per nome nazione (Italia, Francia…)
  static Map<String, dynamic>? findCountryByName(String query) {
    query = query.toLowerCase();
    try {
      return _countryByName.values.firstWhere(
        (c) => c['name'].toString().toLowerCase().contains(query),
      );
    } catch (_) {
      return null;
    }
  }

  // ⭐ Ricerca per ISO (IT, FR…)
  static Map<String, dynamic>? findCountryByIso(String iso) {
    iso = iso.toLowerCase();
    try {
      return _countryByIso.values.firstWhere(
        (c) => c['iso'].toString().toLowerCase().contains(iso),
      );
    } catch (_) {
      return null;
    }
  }

  // ⭐ Ottiene il nome della valuta da codice (EUR → Euro)
  static String getCurrencyName(String code) {
    final c = _currencyByCode[code.toUpperCase()];
    return c != null ? c['name'] : "";
  }
}
