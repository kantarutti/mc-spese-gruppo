import 'package:flutter/material.dart';

class AppSpacing {
  // ------------------------------------------------------------
  // 📏 SPAZIATURE STANDARD
  // ------------------------------------------------------------

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
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

  // ------------------------------------------------------------
  // 🎨 RADIUS STANDARD
  // ------------------------------------------------------------

  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;

  // ------------------------------------------------------------
  // 🌫️ BLUR PER LE OMBRE
  // ------------------------------------------------------------

  static const double blurXs = 2.0;
  static const double blurSm = 4.0;
  static const double blurMd = 8.0;
  static const double blurLg = 16.0;
}
