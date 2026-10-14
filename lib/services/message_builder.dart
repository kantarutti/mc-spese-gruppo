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
//  required String luogoEvento,
  required String dataInizio,
  required String dataFine,
  required String conto,
  required StatoUtente stato,
  required String pin,
}) {

// Costruiamo correttamente il periodo usando .tr(args:) sulle chiavi dedicate
  final periodo = (dataInizio == dataFine)
      ? 'periodo_giorno'.tr(args: [dataInizio])
      : 'periodo_intervallo'.tr(args: [dataInizio, dataFine]);

  final messaggioBase = 'messaggio_invito_base'.tr(args: [
    nomePersona,        // 1° {}
    nomeAmministratore, // 2° {}
    nomeEvento,         // 3° {}
    periodo,            // 4° {} -> inserisce il testo formattato di "periodo"
    conto,              // 5° {}
  ]);

  final bloccoNonRegistrato = stato == StatoUtente.nonRegistrato
      ? 'messaggio_invito_non_registrato'.tr(args: [pin])
      : '';

  return "$messaggioBase$bloccoNonRegistrato";
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
