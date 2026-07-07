/// Costanti dell'applicazione
class AppConstants {
  // URL Supabase (da configurare)
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';

  // Nomi delle tabelle
  static const String tableEventi = 'eventi';
  static const String tableGruppi = 'gruppi';
  static const String tableSpese = 'spese';
  static const String tableGiroconti = 'giroconti';
  static const String tableLocalita = 'localita';
  static const String tableValuta = 'valuta';
  static const String tablePartecipanti = 'partecipanti';

  // Durate
  static const Duration snackBarDuration = Duration(seconds: 2);
  static const Duration loadingDelay = Duration(milliseconds: 500);

  // Valori di default
  static const int maxNameLength = 100;
  static const int minNameLength = 2;
  static const double minAmount = 0.0;
  static const double maxAmount = 999999.99;

  // Regex patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^[+]?[(]?[0-9]{3}[)]?[-\s.]?[0-9]{3}[-\s.]?[0-9]{4,6}$';
  static const String currencyPattern = r'^[A-Z]{3}$';

  // Messaggi di errore comuni
  static const String errorGeneric = 'Si è verificato un errore';
  static const String errorNetwork = 'Errore di connessione';
  static const String errorAuth = 'Errore di autenticazione';
  static const String errorValidation = 'Dati non validi';
  static const String errorNotFound = 'Risorsa non trovata';

  // Messaggi di successo
  static const String successCreated = 'Creato con successo';
  static const String successUpdated = 'Aggiornato con successo';
  static const String successDeleted = 'Eliminato con successo';
  static const String successSaved = 'Salvato con successo';
}

/// Stati dell'evento
class EventoStato {
  static const String creazione = 'Creazione';
  static const String inCorso = 'In Corso';
  static const String concluso = 'Concluso';
  static const String archiviato = 'Archiviato';

  static const List<String> all = [creazione, inCorso, concluso, archiviato];
}

/// Tipi di evento
class TipoEvento {
  static const String viaggio = 'Viaggio';
  static const String cena = 'Cena';
  static const String vacanza = 'Vacanza';
  static const String altro = 'Altro';

  static const List<String> all = [viaggio, cena, vacanza, altro];
}

/// Tipologie di spesa
class TipologiaSpesa {
  static const String alloggio = 'Alloggio';
  static const String trasporto = 'Trasporto';
  static const String cibo = 'Cibo';
  static const String attivita = 'Attività';
  static const String altro = 'Altro';

  static const List<String> all = [alloggio, trasporto, cibo, attivita, altro];
}

/// Valute supportate
class ValuteSupportate {
  static const List<String> comuni = [
    'EUR',
    'USD',
    'GBP',
    'JPY',
    'CHF',
    'CAD',
    'AUD',
    'NZD',
    'CNY',
    'INR',
  ];

  static const List<String> europee = [
    'EUR',
    'GBP',
    'CHF',
    'NOK',
    'SEK',
    'DKK',
  ];
}