import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
            label: 'localita_btn'.tr(),
            onTap: onLocalitaTap,
            mode: mode,
          ),
          AppWidgets.actionChip(
            icon: Icons.currency_exchange,
            label: 'valute_btn'.tr(),
            onTap: onValuteTap,
            mode: mode,
          ),
          AppWidgets.actionChip(
            icon: Icons.people,
            label: 'persone_btn'.tr(),
            onTap: onTeamsTap,
            mode: mode,
          ),
        ],
      ),
    );
  }
}