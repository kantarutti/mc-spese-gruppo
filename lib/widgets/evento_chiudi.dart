import 'package:flutter/material.dart';
import '../../config/app_widgets.dart';
import '../../services/evento_service.dart';

class EventoChiudi extends StatelessWidget {
  final dynamic eventoId;
  final EventoService service;
  final VoidCallback onStatoAggiornato;

  const EventoChiudi({
    super.key,
    required this.eventoId,
    required this.service,
    required this.onStatoAggiornato,
  });

  @override
  Widget build(BuildContext context) {
    return AppWidgets.actionButton(
      icon: Icons.lock,
      label: "Chiudi",
//      textColor: Colors.red,
      onTap: () async {
        final confermato = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Chiusura Evento"),
            content: const Text(
              "Sei sicuro di voler chiudere l'evento? Una volta chiuso non potrà più essere aperto.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Annulla"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Chiudi",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );

        if (confermato == true) {
          await service.aggiornaStatoEvento(
            eventoId: eventoId,
            nuovoStato: "Chiuso",
          );
          onStatoAggiornato();
        }
      },
    );
  }
}