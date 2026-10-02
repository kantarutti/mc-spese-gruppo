import 'package:flutter/material.dart';
import '../config/app_widgets.dart';

class EventoTablesButtons extends StatelessWidget {
  final VoidCallback onLocalitaTap;
  final VoidCallback onValuteTap;
  final VoidCallback onTeamsTap;
  final FieldMode mode;

  const EventoTablesButtons({
    super.key,
    required this.onLocalitaTap,
    required this.onValuteTap,
    required this.onTeamsTap,
    this.mode = FieldMode.edit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          AppWidgets.actionChip(
            icon: Icons.map,
            label: 'Località',
            onTap: onLocalitaTap,
            mode: mode,
          ),
          AppWidgets.actionChip(
            icon: Icons.currency_exchange,
            label: 'Valute',
            onTap: onValuteTap,
            mode: mode,
          ),
          AppWidgets.actionChip(
            icon: Icons.people,
            label: 'Persone',
            onTap: onTeamsTap,
            mode: mode,
          ),
        ],
      ),
    );
  }
}