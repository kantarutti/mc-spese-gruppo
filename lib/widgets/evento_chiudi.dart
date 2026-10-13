import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
      label: 'chiudi'.tr(),
//      textColor: Colors.red,
      onTap: () async {
        final confermato = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('conferma_chiusura_titolo'.tr()),
            content: Text(
              'conferma_chiusura_messaggio'.tr(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('annulla'.tr()),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
//                  backgroundColor: Colors.red,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'chiudi'.tr(),
                  style: const TextStyle(color: Colors.white),
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