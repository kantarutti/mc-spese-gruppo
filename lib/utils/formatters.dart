import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formatta i numeri con 2 decimali e separatore delle migliaia
class CurrencyFormatter {
  static final NumberFormat _nf = NumberFormat("#,##0.00", "it_IT");

  static String format(double value) {
    return _nf.format(value);
  }

  static String formatSimple(double value) {
    return value.toStringAsFixed(2);
  }
}

/// Formatta le date nel formato dd/MM/yyyy
class DateFormatter {
  static String format(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatWithTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatPeriod(dynamic startDate, dynamic endDate) {
    if (startDate == null) return "Data non definita";
    
    try {
      final df = DateFormat('dd/MM/yyyy');
      final dataIniz = df.format(DateTime.parse(startDate.toString()));
      
      if (endDate == null) return dataIniz;
      
      final dataFine = df.format(DateTime.parse(endDate.toString()));
      return "$dataIniz - $dataFine";
    } catch (e) {
      return startDate.toString();
    }
  }
}

/// Formatter "morbido" per i numeri di telefono con prefisso internazionale
/// Formato: +[prefisso] [spazio] XXX XXX XXXXXX
class MorbidoTelefonoFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Forza il '+' sempre all'inizio
    if (text.isEmpty || !text.startsWith('+')) {
      return const TextEditingValue(
        text: '+',
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    // Se l'utente cancella tutto tranne il +, ci fermiamo
    if (text == '+') return newValue;

    // Troviamo la posizione del primo spazio (fine del prefisso internazionale)
    int firstSpaceIndex = text.indexOf(' ');

    if (firstSpaceIndex == -1) {
      // L'utente sta ancora scrivendo il prefisso internazionale, non formattiamo nulla
      return newValue;
    }

    // Se c'è lo spazio, formattiamo solo quello che viene DOPO
    String prefix = text.substring(0, firstSpaceIndex + 1);
    String remaining = text.substring(firstSpaceIndex + 1).replaceAll(' ', '');
    String formattedRemaining = '';

    for (int i = 0; i < remaining.length; i++) {
      if (i == 3 || i == 6) formattedRemaining += ' ';
      if (i < 12) formattedRemaining += remaining[i]; // Limite massimo per il numero
    }

    String result = prefix + formattedRemaining;
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

/// Formatter universale per numeri di telefono internazionali
/// Inserisce automaticamente spazi ogni 2-3 cifre
class UniversalPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Forza il '+' all'inizio se non c'è
    if (text.isEmpty || !text.startsWith('+')) {
      text = '+$text';
    }

    // Estrae solo i caratteri numerici dopo il '+'
    String digits = text.substring(1).replaceAll(' ', '');

    // Limita a 15 cifre (standard internazionale)
    if (digits.length > 15) {
      digits = digits.substring(0, 15);
    }

    // Ricostruisce il formato con spazi
    String formatted = '+';
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5 || i == 8 || i == 11) formatted += ' ';
      formatted += digits[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter per valute (input di numeri con virgola e punto)
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Consenti solo numeri, punto e virgola
    String text = newValue.text.replaceAll(RegExp(r'[^\d.,]'), '');

    // Sostituisci virgola con punto per il parsing
    text = text.replaceAll(',', '.');

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Formatter per codici e testi che devono essere maiuscoli
class UppercaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Formatter per codici che accetta solo alfanumerici
class AlphanumericFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}