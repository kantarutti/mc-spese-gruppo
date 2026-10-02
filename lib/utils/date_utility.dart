import 'package:flutter/material.dart';

class DateUtility {
  /// Apre il date picker e gestisce la logica di calcolo/validazione delle date.
  /// Ritorna una mappa con le nuove date (inizio e fine), oppure null se l'utente annulla.
  static Future<Map<String, DateTime?>?> pickAndCalculateDates({
    required BuildContext context,
    required bool isStart,
    required DateTime? currentInizio,
    required DateTime? currentFine,
  }) async {
    final initial = isStart ? currentInizio : currentFine;
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return null;

    DateTime? newInizio = currentInizio;
    DateTime? newFine = currentFine;

    if (isStart) {
      newInizio = picked;
      if (currentInizio != null && currentFine != null) {
        final diff = currentFine.difference(currentInizio).inDays;
        newFine = picked.add(Duration(days: diff < 0 ? 0 : diff));
      } else if (currentFine == null) {
        newFine = picked;
      }
    } else {
      if (currentInizio != null && picked.isBefore(currentInizio)) {
        // Restitoliamo un segnale o gestiamo il messaggio fuori. 
        // Per semplicità qui restituiamo un'eccezione o gestiamo il controllo prima.
        throw Exception("La data fine non può essere precedente alla data inizio");
      }
      newFine = picked;
    }

    return {
      'dataInizio': newInizio,
      'dataFine': newFine,
    };
  }
}