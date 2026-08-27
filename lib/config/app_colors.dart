import 'package:flutter/material.dart';

class AppColors {
  // ------------------------------------------------------------
  // 🔵 COLORI PRINCIPALI DELL'APP (Stile Tecnico / Gestionale)
  // ------------------------------------------------------------

  /// Colore principale dell'app (AppBar, pulsanti primari, header)
  static const Color primaryColor = Color(0xFF1E3A5F); // Blu acciaio

  /// Colore secondario (azioni, icone tecniche, pulsanti secondari)
  static const Color secondaryColor = Color(0xFF00A3FF); // Azzurro tecnico

  /// Testo e icone su sfondo primaryColor
  static const Color primaryTextColor = Colors.white;

  /// Testo principale su sfondo chiaro
  static const Color secondaryTextColor = Color(0xFF2F2F2F); // Grafite scuro

  /// Testo non selezionato nella NavigationBar
  static final Color disabledTextColor = const Color(0xFF2F2F2F).withOpacity(0.5);

  /// Sfondo delle pagine (dashboard)
  static const Color backgroundColor = Color(0xFFF4F6F8); // Grigio tecnico chiaro

  /// Sfondo delle card
  static const Color cardColor = Colors.white;

  /// Divider, bordi leggeri, separatori
  static const Color dividerColor = Color(0xFFD0D6DE); // Grigio bordo tecnico

/// Sfondo per campi di sola visualizzazione
static const Color readonlyFieldColor = Color(0xFFE9ECEF); // Grigio tecnico chiaro

  // ------------------------------------------------------------
  // 🎯 COLORI DEGLI STATI DELL'EVENTO (Stile Tecnico)
  // ------------------------------------------------------------

  /// Evento in preparazione (oggi < data_inizio)
  static const Color preparazioneColor = Color(0xFF007BFF); // Arancio tecnico

  /// Evento in corso (data_inizio <= oggi <= data_fine)
  static const Color inCorsoColor = Color(0xFF2ECC71); // Verde successo

  /// Evento concluso (oggi > data_fine)
  static const Color conclusoColor = Color(0xFF6E7A89); // Grigio tecnico

  /// Evento chiuso manualmente
  static const Color chiusoColor = Color(0xFFE74C3C); // Rosso critico
}
