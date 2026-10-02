import 'package:flutter/material.dart';
import '../config/app_widgets.dart';
import '../services/evento_service.dart';
 
class EventoInviaRendiconto extends StatelessWidget {
  final dynamic eventoId;
  final EventoService service;

  const EventoInviaRendiconto({
    super.key,
    required this.eventoId,
    required this.service,
  });

Future<void> _inviaRendicontoEmail(BuildContext context) async {
  try {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invio rendiconto in corso...")),
    );

    final String emailInviata = await service.inviaEmailRiepilogo(eventoId, 'mc.applicazioni@gmail.com');

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Rendiconto inviato a $emailInviata")),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Mostra l'errore esatto in un popup sul cellulare
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Errore Web Mobile"),
        content: Text("$e"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return AppWidgets.whiteButton(
      icon: Icons.email,
      label: "Invia Rendiconto",
      onTap: () => _inviaRendicontoEmail(context),
    );
  }
}