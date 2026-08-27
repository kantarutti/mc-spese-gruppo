import 'package:flutter/material.dart';

class AppEventTypes {
  static const String viaggio = 'Viaggio';
  static const String gita = 'Gita';
  static const String evento = 'Evento';
  static const String pranzoCena = 'Pranzo - Cena';
  static const String festa = 'Festa';
  static const String regalo = 'Regalo';

  static IconData getIcon(String tipo) {
    switch (tipo) {
      case viaggio:
        return Icons.flight;
      case gita:
        return Icons.directions_car;
      case evento:
        return Icons.event;
      case pranzoCena:
        return Icons.restaurant;
      case festa:
        return Icons.celebration;
      case regalo:
        return Icons.redeem;
      default:
        return Icons.help_outline;
    }
  }
}
