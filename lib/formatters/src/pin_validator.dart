import 'package:flutter/material.dart';

class PinValidator {
  static String? validateAndNotify(BuildContext context, String? pinText) {
    final rawPin = pinText ?? '';
    final pin = rawPin.trim();

    // 🔍 DEBUG PRINT
    print("--- DEBUG PIN VALIDATOR ---");
    print("Testo grezzo inserito: '$rawPin' (lunghezza: ${rawPin.length})");
    print("Testo dopo il trim: '$pin' (lunghezza: ${pin.length})");

    if (pin.isEmpty) {
      print("Errore: PIN vuoto");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci il PIN")),
      );
      return null;
    }

    if (pin.length != 6) {
      print("Errore: Lunghezza non valida (${pin.length} anziché 6)");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Il PIN deve essere composto esattamente da 6 numeri")),
      );
      return null;
    }

    print("PIN valido superato con successo: '$pin'");
    return pin;
  }
}