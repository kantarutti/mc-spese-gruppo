import 'package:flutter/material.dart';

/// 🔵 Validazione, pulizia e logica di business per i numeri di telefono
class PhoneValidator {
  /// Rimuove tutto tranne i numeri e il segno più iniziale
  static String cleanPhoneNumber(String input) {
    if (input.isEmpty) return '';
    final bool hasPlus = input.trim().startsWith('+');
    final digitsOnly = input.replaceAll(RegExp(r'\D'), '');
    return hasPlus ? '+$digitsOnly' : digitsOnly;
  }

  /// Verifica che la lunghezza del numero sia plausibile (tra 8 e 15 cifre)
  static bool isValidMobileNumber(String input) {
    final cleaned = cleanPhoneNumber(input);
    final digits = cleaned.replaceAll('+', '');
    return digits.length >= 8 && digits.length <= 15;
  }

  /// ⭐ Metodo con feedback visivo (SnackBar) riutilizzabile in tutta l'app
  static String? validateAndNotify(BuildContext context, String input) {
    final rawCell = input.trim();

    if (rawCell.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci il numero di cellulare")),
      );
      return null;
    }

    if (!rawCell.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inserisci il prefisso internazionale (es. +39...)"),
        ),
      );
      return null;
    }

    final cell = cleanPhoneNumber(rawCell);

    if (!isValidMobileNumber(cell)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Il numero di cellulare non è valido. Controlla le cifre inserite."),
        ),
      );
      return null;
    }

    return cell; // Restituisce il numero pulito e validato
  }
}