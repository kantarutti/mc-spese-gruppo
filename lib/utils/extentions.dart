import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'formatters.dart';

/// Estensioni per double (numeri decimali)
extension DoubleExtensions on double {
  /// Formatta un numero come valuta (es: 1234.56 → "1.234,56")
  String toCurrency() {
    return CurrencyFormatter.format(this);
  }

  /// Converte a stringa con 2 decimali
  String toDecimal() {
    return toStringAsFixed(2);
  }

  /// Arrotonda a N decimali
  double roundTo(int decimals) {
    final factor = pow(10, decimals).toDouble();
    return (this * factor).round() / factor;
  }

  /// Verifica se il numero è positivo
  bool get isPositive => this > 0;

  /// Verifica se il numero è negativo
  bool get isNegative => this < 0;

  /// Verifica se il numero è zero
  bool get isZero => this == 0;

  /// Ritorna il valore assoluto formattato
  String toAbsoluteCurrency() {
    return abs().toCurrency();
  }
}

/// Funzione helper per il roundTo
double pow(num x, num y) => math.pow(x, y).toDouble();

/// Estensioni per String
extension StringExtensions on String {
  /// Capitalizza la prima lettera
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  /// Capitalizza la prima lettera di ogni parola
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.capitalize())
        .join(' ');
  }

  /// Rimuove tutti gli spazi
  String removeAllSpaces() {
    return replaceAll(' ', '');
  }

  /// Rimuove spazi all'inizio e fine
  String trimSpaces() {
    return trim();
  }

  /// Converte stringa a double in modo sicuro
  double? toDoubleOrNull() {
    try {
      return double.parse(replaceAll(',', '.'));
    } catch (e) {
      return null;
    }
  }

  /// Converte stringa a int in modo sicuro
  int? toIntOrNull() {
    try {
      return int.parse(this);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se è un numero valido
  bool get isNumeric {
    if (isEmpty) return false;
    return double.tryParse(replaceAll(',', '.')) != null;
  }

  /// Verifica se è una email valida (semplice check)
  bool get isValidEmail {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this);
  }

  /// Verifica se è un telefono valido (almeno 10 caratteri)
  bool get isValidPhone {
    final cleaned = removeAllSpaces().replaceAll('+', '');
    return cleaned.length >= 10 && cleaned.isNumeric;
  }

  /// Tronca la stringa a una lunghezza massima
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return substring(0, maxLength) + suffix;
  }

  /// Verifica se è una valuta valida (formato: EUR, USD, JPY, ecc.)
  bool get isValidCurrency {
    return length == 3 && RegExp(r'^[A-Z]{3}$').hasMatch(this);
  }
}

/// Estensioni per DateTime
extension DateTimeExtensions on DateTime {
  /// Formatta la data nel formato dd/MM/yyyy
  String toDayMonthYear() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Formatta la data nel formato dd/MM/yyyy HH:mm
  String toDayMonthYearTime() {
    return DateFormat('dd/MM/yyyy HH:mm').format(this);
  }

  /// Ritorna solo la data senza ora
  DateTime get dateOnly {
    return DateTime(year, month, day);
  }

  /// Verifica se è oggi
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Verifica se è ieri
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Differenza in giorni da oggi
  int get daysFromNow {
    final now = DateTime.now();
    return difference(now).inDays;
  }
}

/// Estensioni per BuildContext
extension BuildContextExtensions on BuildContext {
  /// Ottiene la larghezza dello schermo
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Ottiene l'altezza dello schermo
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Verifica se lo schermo è in modalità portrait
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;

  /// Verifica se lo schermo è in modalità landscape
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  /// Verifica se è un dispositivo mobile (larghezza < 600)
  bool get isMobile => screenWidth < 600;

  /// Verifica se è un tablet (larghezza 600-1200)
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;

  /// Verifica se è un desktop (larghezza > 1200)
  bool get isDesktop => screenWidth >= 1200;

  /// Ottiene il padding sicuro (notch, cutout, ecc.)
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  /// Mostra uno SnackBar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Mostra uno SnackBar di errore (rosso)
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Mostra uno SnackBar di successo (verde)
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Naviga a una nuova schermata
  void navigateTo(Widget page) {
    Navigator.of(this).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Naviga e sostituisce la pagina precedente
  void navigateAndReplace(Widget page) {
    Navigator.of(this).pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Torna indietro
  void goBack() {
    Navigator.of(this).pop();
  }
}

/// Estensioni per List
extension ListExtensions<T> on List<T> {
  /// Verifica se la lista è vuota in modo più leggibile
  bool get isEmpty => length == 0;

  /// Ritorna il primo elemento o null
  T? get firstOrNull => isEmpty ? null : first;

  /// Ritorna l'ultimo elemento o null
  T? get lastOrNull => isEmpty ? null : last;

  /// Ritorna un elemento a un indice o null se fuori range
  T? getAt(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

/// Estensioni per Map
extension MapExtensions<K, V> on Map<K, V> {
  /// Ottiene un valore in modo sicuro
  V? getOrNull(K key) {
    return this[key];
  }

  /// Ottiene un valore o ritorna un default
  V getOrDefault(K key, V defaultValue) {
    return this[key] ?? defaultValue;
  }
}