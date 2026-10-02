import 'package:flutter/material.dart';
import '../config/app_widgets.dart';
import '../config/app_colors.dart';
import '../services/evento_service.dart';

class EventoElimina extends StatelessWidget {
  final dynamic eventoId;
  final EventoService service;

  const EventoElimina({
    super.key,
    required this.eventoId,
    required this.service,
  });

  Future<void> _confermaEdElimina(BuildContext context) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Conferma"),
        content: const Text("Vuoi cancellare questo evento?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Cancella",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (conferma == true) {
      try {
        await service.eliminaEvento(eventoId);
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Errore cancellazione evento: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppWidgets.actionButton(
      icon: Icons.delete,
      label: "Cancella",
      textColor: Colors.red,
      onTap: () => _confermaEdElimina(context),
    );
  }
}