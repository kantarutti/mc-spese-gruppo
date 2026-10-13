import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
        title: Text('conferma'.tr()),
        content: Text('vuoi_eliminare_evento'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('annulla'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'cancella'.tr(),
              style: const TextStyle(color: Colors.white),
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
            SnackBar(content: Text("${'errore_cancellazione_evento'.tr()}: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppWidgets.actionButton(
      icon: Icons.delete,
      label: 'cancella'.tr(),
      textColor: Colors.red,
      onTap: () => _confermaEdElimina(context),
    );
  }
}