import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../config/app_widgets.dart';
import '../services/evento_service.dart';

class EventoRiapri extends StatelessWidget {
  final dynamic eventoId;
  final EventoService service;
  final VoidCallback onStatoAggiornato;

  const EventoRiapri({
    super.key,
    required this.eventoId,
    required this.service,
    required this.onStatoAggiornato,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AppWidgets.whiteButton(
        icon: Icons.lock_open,
        label: 'riapri'.tr(),
        onTap: () async {
          // Esegue la riapertura direttamente senza mostrare alcun AlertDialog
          await service.aggiornaStatoEvento(
            eventoId: eventoId,
            nuovoStato: "Preparazione",
          );
          onStatoAggiornato();
        },
      ),
    );
  }
}