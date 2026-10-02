/// 🔵 Valuta ISO (3 lettere maiuscole, es. EUR, USD)
class CurrencyValidator {
  static bool isValid(String value) {
    return RegExp(r'^[A-Z]{3}$').hasMatch(value);
  }
}

/// 🔵 Controllo email valida
class EmailValidator {
  static bool isValid(String value) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value);
  }
}