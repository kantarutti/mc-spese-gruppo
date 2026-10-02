import 'package:flutter/material.dart';
import '../config/app_widgets.dart';
import '../services/evento_service.dart';
import '../models/event_states_model.dart';
import '../config/app_event_states.dart';

class EventoStatoToggle extends StatelessWidget {
  final dynamic eventoId;
  final EventoService service;
  final String statoCorrente;
  final DateTime? dataInizio;
  final DateTime? dataFine;
  final Function(String nuovoStato, EventState nuovoStatoEnum) onStateChanged;

  const EventoStatoToggle({
    super.key,
    required this.eventoId,
    required this.service,
    required this.statoCorrente,
    required this.dataInizio,
    required this.dataFine,
    required this.onStateChanged,
  });

  Future<void> _gestisciToggleStato() async {
    final statoTrimmed = statoCorrente.trim();
    try {
      String nuovoStato;
      if (statoTrimmed == "Chiuso") {
        if (dataInizio == null) {
          nuovoStato = "Preparazione";
        } else {
          nuovoStato = await service.calcolaStatoCorrente(dataInizio!, dataFine);
        }
      } else {
        nuovoStato = "Chiuso";
      }

      await service.aggiornaStatoEvento(
        eventoId: eventoId,
        nuovoStato: nuovoStato,
      );

      final nuovoStatoEnum = EventStateParser.fromString(nuovoStato);
      
      // Notifichiamo la pagina padre per aggiornare lo UI state
      onStateChanged(nuovoStato, nuovoStatoEnum);
    } catch (e) {
      print("ERRORE STATO: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChiuso = statoCorrente.trim() == "Chiuso";

    return IntrinsicWidth(
      child: Center(
        child: AppWidgets.actionButton(
          icon: isChiuso ? Icons.play_circle_outline : Icons.lock_outline,
          label: isChiuso ? "Apri" : "Chiudi",
          onTap: _gestisciToggleStato,
        ),
      ),
    );
  }
}