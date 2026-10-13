// ===============================================================
//  MESSAGE BUILDER — genera testi dell’app
// ===============================================================
import 'package:easy_localization/easy_localization.dart';
// ---------------------------------------------------------------
// 1. STATO UTENTE
// ---------------------------------------------------------------
enum StatoUtente {
  registrato,
  nonRegistrato,
}

// ---------------------------------------------------------------
// 2. MESSAGGIO DI INVITO
// ---------------------------------------------------------------
String buildMessaggioInvito({
  required String nomePersona,
  required String nomeAmministratore,
  required String nomeEvento,
  required String luogoEvento,
  required String dataInizio,
  required String dataFine,
  required String conto,
  required StatoUtente stato,
  required String pin,
}) {
  // Se le date sono uguali → usa "il ..."
  final periodo = (dataInizio == dataFine)
      ? "il *$dataInizio*"
      : "dal *$dataInizio* al *$dataFine*";

  final messaggioBase = """
Ciao $nomePersona,

*$nomeAmministratore* ti ha aggiunto all’attività *“$nomeEvento”* che si terrà $periodo.

Inserisci tutte le spese che sostieni per l'attività sul conto *$conto* e condividile con il gruppo.

Tutti i conteggi saranno aggiornati automaticamente.
""";

  final bloccoNonRegistrato = """

Collegati all’app:
https://spesedigruppo.mcapplicazioni.com

Fai il Login inserendo il tuo numero di telefono e il PIN provvisorio: *$pin*

Attenzione iPhone!
Se hai iOS e non vedi l'app, ma vedi "Isolamento Attivo", disattiva la Modalità di Isolamento per questa app:

Impostazioni > Privacy e sicurezza > Modalità di Isolamento > spesedigruppo.mcapplicazioni.com
""";

  return """
$messaggioBase${stato == StatoUtente.nonRegistrato ? bloccoNonRegistrato : ""}

Ti aspettiamo!
""";
}


// ---------------------------------------------------------------
// 3. TUTORIAL — Testi dei fumetti
// ---------------------------------------------------------------

// 🔹 HOME
String tutorialHomeTitle() => "tutorial_home_title".tr();
String tutorialHomeText() => "tutorial_home_text".tr();

// 🔹 ATTIVITA'
String tutorialEventViewTitle() => "tutorial_event_view_title".tr();
String tutorialEventViewText() => "tutorial_event_view_text".tr();

// 🔹 CONFIGURAZIONE ATTIVITA'
String tutorialEventEditTitle() => "tutorial_event_edit_title".tr();
String tutorialEventEditText() => "tutorial_event_edit_text".tr();

// 🔹 LOCALITÀ
String tutorialLocalitaTitle() => "tutorial_localita_title".tr();
String tutorialLocalitaText() => "tutorial_localita_text".tr();

// 🔹 VALUTE
String tutorialValuteTitle() => "tutorial_valute_title".tr();
String tutorialValuteText() => "tutorial_valute_text".tr();

// 🔹 CONTI
String tutorialGruppiTitle() => "tutorial_gruppi_title".tr();
String tutorialGruppiText() => "tutorial_gruppi_text".tr();

// 🔹 PERSONE
String tutorialPersoneTitle() => "tutorial_persone_title".tr();
String tutorialPersoneText() => "tutorial_persone_text".tr();

// 🔹 SPESE
String tutorialSpeseTitle() => "tutorial_spese_title".tr();
String tutorialSpeseText() => "tutorial_spese_text".tr();
