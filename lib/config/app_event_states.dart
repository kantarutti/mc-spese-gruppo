import 'package:flutter/material.dart';
import '../models/event_states_model.dart';
import 'app_colors.dart';

class AppEventStates {
  static Color getColor(EventState state) {
    switch (state) {
      case EventState.preparazione:
        return AppColors.preparazioneColor;
      case EventState.inCorso:
        return AppColors.inCorsoColor;
      case EventState.concluso:
        return AppColors.conclusoColor;
      case EventState.chiuso:
        return AppColors.chiusoColor;
    }
  }

  static IconData getIcon(EventState state) {
    switch (state) {
      case EventState.preparazione:
        return Icons.build_outlined;
      case EventState.inCorso:
        return Icons.play_circle_outline;
      case EventState.concluso:
        return Icons.check_circle_outline;
      case EventState.chiuso:
        return Icons.lock_outline;
    }
  }

  static String getLabel(EventState state) {
    return state.label; // usa l’estensione del model
  }
}
