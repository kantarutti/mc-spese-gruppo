import 'package:flutter/services.dart';

/// 🔵 Permette di digitare solo numeri e limita la lunghezza a un massimo di 6 cifre
class PinFormatter extends TextInputFormatter {
  final int maxLength;

  PinFormatter({this.maxLength = 6});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // Filtra mantenendo solo le cifre numeriche (toglie lettere e simboli)
    final String sanitized = text.replaceAll(RegExp(r'[^\d]'), '');

    // Se supera la lunghezza massima, tronchiamo la stringa
    final String truncated = sanitized.length <= maxLength 
        ? sanitized 
        : sanitized.substring(0, maxLength);

    // Gestione intelligente del cursore per evitare che salti alla fine
    int selectionIndex = newValue.selection.end;
    int diff = newValue.text.length - truncated.length;
    selectionIndex -= diff;
    selectionIndex = selectionIndex.clamp(0, truncated.length);

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}