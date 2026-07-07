import 'package:flutter/material.dart';

/// Colori dell'applicazione
class AppColors {
  static const Color primary = Color(0xFF00B2FF); // Azzurro intenso
  static const Color primaryDark = Color(0xFF0091CC);
  static const Color secondary = Color(0xFF26C6DA);
  
  // Sfondi
  static const Color scaffoldBackground = Colors.white;
  static const Color cardBackground = Colors.white;
  
  // Testi
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Stato transazioni
  static const Color negative = Color(0xFFC62828); // Rosso - uscite
  static const Color positive = Color(0xFF2E7D32); // Verde - entrate
  static const Color warning = Color(0xFFFFC107); // Giallo - avvertenze
  static const Color error = Color(0xFFB00020);
  
  // Input
  static const Color inputFill = Color(0xFFF5F5F5);
  static const Color inputBorder = Color(0xFFE0E0E0);
  
  // Divider
  static const Color divider = Color(0xFFEEEEEE);
}

/// Stringhe dell'applicazione
class AppStrings {
  // Titoli e label comuni
  static const String appName = 'MC Spese di Gruppo';
  static const String noData = 'Nessun dato disponibile';
  static const String loading = 'Caricamento...';
  static const String error = 'Errore';
  static const String success = 'Operazione completata';
  
  // Bottoni
  static const String save = 'SALVA';
  static const String cancel = 'ANNULLA';
  static const String delete = 'ELIMINA';
  static const String edit = 'MODIFICA';
  static const String add = 'AGGIUNGI';
  static const String close = 'CHIUDI';
  static const String back = 'INDIETRO';
  
  // Autenticazione
  static const String login = 'LOGIN';
  static const String logout = 'Esci';
  static const String register = 'REGISTRATI';
  static const String email = 'Email';
  static const String password = 'Codice Personale';
  static const String phone = 'Cellulare';
  
  // Navigazione tab
  static const String home = 'Home';
  static const String expenses = 'Spese';
  static const String settlements = 'Giroconti';
  static const String stats = 'Grafici';
  static const String groups = 'Gruppi';
  
  // Campo evento
  static const String eventName = 'Nome Evento';
  static const String eventType = 'Tipo Evento';
  static const String eventLocation = 'Località';
  static const String eventStartDate = 'Data Inizio';
  static const String eventEndDate = 'Data Fine';
  static const String eventOrganizer = 'Organizzatore';
  static const String eventStatus = 'Stato';
  
  // Tipi evento
  static const List<String> eventTypes = [
    'Viaggio',
    'Gita',
    'Evento',
    'Pranzo - Cena',
    'Festa',
    'Regalo'
  ];
  
  // Stati evento
  static const List<String> eventStates = [
    'Creazione',
    'Preparazione',
    'In Corso',
    'Concluso',
    'Chiuso'
  ];
  
  // Campi gruppo
  static const String groupName = 'Nome Gruppo';
  static const String groupMembers = 'Numero partecipanti';
  
  // Campi spesa
  static const String expenseAmount = 'Importo';
  static const String expenseDate = 'Data';
  static const String expenseLocation = 'Località';
  static const String expenseType = 'Tipologia';
  static const String expenseNote = 'Causale';
  static const String expenseCurrency = 'Valuta';
  
  // Tipologie spesa
  static const List<String> expenseTypes = [
    'Trasporti',
    'Alloggi',
    'Cibo & Bevande',
    'Visite & Svago',
    'Altro'
  ];
  
  // Valuta
  static const String currencyOrigin = 'Valuta Spesa';
  static const String currencyTarget = 'Valuta Conteggi';
  static const String exchangeRate = 'Cambio';
  
  // Conteggi
  static const String totalExpense = 'Spesa Totale';
  static const String proCapite = 'Pro Capite';
  static const String groupCost = 'Costo Gruppo';
  static const String settlement = 'Conguaglio';
  static const String balance = 'Saldo';
  static const String owe = 'Dare';
  static const String receive = 'Avere';
  
  // Giroconti
  static const String from = 'Da';
  static const String to = 'A';
  static const String movements = 'MOVIMENTI';
  
  // Profilo
  static const String profile = 'Profilo';
  static const String myProfile = 'Il Mio Profilo';
  static const String name = 'Nome Completo';
  static const String nation = 'Nazione';
  static const String city = 'Località';
  static const String currency = 'Valuta';
  static const String group = 'Gruppo';
  static const String changePassword = 'Cambia Codice Personale';
  static const String newPassword = 'Nuovo Codice';
  static const String confirmPassword = 'Conferma';
}

/// Padding e spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Border radius
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double full = 30.0;
}

/// Durate animazioni
class AppDuration {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

/// Font size
class AppFontSize {
  static const double xs = 10.0;
  static const double sm = 12.0;
  static const double md = 14.0;
  static const double lg = 16.0;
  static const double xl = 18.0;
  static const double xxl = 20.0;
  static const double xxxl = 24.0;
}
