import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = newValue.text;
    
    // Se il testo è vuoto, restituiamo un valore pulito senza calcoli
    if (text.isEmpty) {
      return newValue;
    }

    // Filtra mantenendo solo cifre, '+' e spazi
    final String sanitized = text.replaceAll(RegExp(r'[^\d+\s]'), '');

    // Se il testo sanificato è identico a quello inserito, non tocchiamo la selezione del cursore
    if (sanitized == text) {
      return newValue;
    }

    // Calcoliamo la nuova posizione del cursore in modo intelligente
    int selectionIndex = newValue.selection.end;
    
    // Se l'utente ha digitato o cancellato, adeguiamo l'offset contando quanti caratteri 
    // non validi sono stati scartati prima della posizione corrente del cursore.
    int diff = newValue.text.length - sanitized.length;
    selectionIndex -= diff;
    
    // Assicuriamoci che l'indice rimanga nei limiti validi della stringa sanificata
    selectionIndex = selectionIndex.clamp(0, sanitized.length);

    return TextEditingValue(
      text: sanitized,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}