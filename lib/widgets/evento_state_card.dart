import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../config/app_event_states.dart';
import '../models/event_states_model.dart';

class EventoStateCard extends StatelessWidget {
  final EventState statoEnum;

  const EventoStateCard({super.key, required this.statoEnum});

  @override
  Widget build(BuildContext context) {
    final color = AppEventStates.getColor(statoEnum);
    final icon = AppEventStates.getIcon(statoEnum);

    // ⭐ Usiamo translationKey e applichiamo .tr() sfruttando il context del widget
    final label = statoEnum.translationKey.tr();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}