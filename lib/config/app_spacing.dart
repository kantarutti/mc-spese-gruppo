import 'package:flutter/material.dart';

class AppSpacing {
  // ------------------------------------------------------------
  // 📏 SPAZIATURE STANDARD (8 / 12 / 16 / 24 / 32)
  // ------------------------------------------------------------

  /// Spaziatura molto piccola (icone, micro padding)
  static const double xs = 4.0;

  /// Spaziatura piccola (tra elementi vicini)
  static const double sm = 8.0;

  /// Spaziatura media (tra label e campo, tra righe)
  static const double md = 12.0;

  /// Spaziatura standard (tra sezioni, tra card)
  static const double lg = 16.0;

  /// Spaziatura ampia (tra blocchi principali)
  static const double xl = 24.0;

  /// Spaziatura extra ampia (padding esterno pagina)
  static const double xxl = 32.0;


  // ------------------------------------------------------------
  // 📦 PADDING PREDEFINITI
  // ------------------------------------------------------------

  /// Padding interno delle card tecniche
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  /// Padding interno dei form (pagina di edit)
  static const EdgeInsets formPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: lg,
  );

  /// Padding generale delle pagine (contenuto principale)
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: lg,
  );

  /// Spaziatura verticale tra sezioni
  static const EdgeInsets sectionSpacing = EdgeInsets.only(top: xl);

  /// Spaziatura verticale tra elementi in una colonna
  static const EdgeInsets columnSpacing = EdgeInsets.only(top: md);
}
