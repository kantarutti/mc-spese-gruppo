import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppEventStates {
  // ------------------------------------------------------------
  // 📌 LISTA DEGLI STATI SUPPORTATI
  // ------------------------------------------------------------
  static const String preparazione = 'Preparazione';
  static const String inCorso = 'In Corso';
  static const String concluso = 'Concluso';
  static const String chiuso = 'Chiuso';

  // ------------------------------------------------------------
  // 🎨 MAPPATURA STATO → COLORE (Palette Tecnica)
  // ------------------------------------------------------------
  static Color getColor(String stato) {
    switch (stato) {
      case preparazione:
        return AppColors.preparazioneColor; // Arancio tecnico
      case inCorso:
        return AppColors.inCorsoColor; // Verde successo
      case concluso:
        return AppColors.conclusoColor; // Grigio tecnico
      case chiuso:
        return AppColors.chiusoColor; // Rosso critico
      default:
        return const Color(0xFF6E7A89); // fallback tecnico
    }
  }

  // ------------------------------------------------------------
  // 🧩 MAPPATURA STATO → ICONA (Stile Tecnico / Lineare)
  // ------------------------------------------------------------
  static IconData getIcon(String stato) {
    switch (stato) {
      case preparazione:
        return Icons.build_outlined; // più tecnico di hourglass
      case inCorso:
        return Icons.play_circle_outline; // lineare, professionale
      case concluso:
        return Icons.check_circle_outline; // check tecnico
      case chiuso:
        return Icons.lock_outline; // lucchetto lineare
      default:
        return Icons.help_outline; // fallback
    }
  }

  // ------------------------------------------------------------
  // 🏷️ MAPPATURA STATO → LABEL (Testo leggibile)
  // ------------------------------------------------------------
  static String getLabel(String stato) {
    switch (stato) {
      case preparazione:
        return 'Preparazione';
      case inCorso:
        return 'In Corso';
      case concluso:
        return 'Concluso';
      case chiuso:
        return 'Chiuso';
      default:
        return 'Sconosciuto';
    }
  }
}
