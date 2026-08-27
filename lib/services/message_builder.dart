// ===============================================================
//  MESSAGE BUILDER — genera il testo del messaggio di invito
// ===============================================================

// Stato dell’utente rispetto all’app
enum StatoUtente {
  registrato,
  nonRegistrato,
}

// Generatore del messaggio di invito
String buildMessaggioInvito({
  required String nomePersona,
  required String nomeOrganizzatore,
  required String nomeEvento,
  required String luogoEvento,
  required String dataInizio,
  required String dataFine,
  required StatoUtente stato,
  required String pin,
}) {
  // 🔹 Se le date sono uguali → usa "il ..."
  final periodo = (dataInizio == dataFine)
      ? "il *$dataInizio*"
      : "dal *$dataInizio* al *$dataFine*";

  switch (stato) {

    // ⭐ Utente NON registrato → messaggio completo con PIN
    case StatoUtente.nonRegistrato:
      return """
Ciao $nomePersona,
*$nomeOrganizzatore* ti ha aggiunto all’evento *“$nomeEvento”* che si terrà a *$luogoEvento* $periodo.
Potrai inserire tutte le spese che hai sostenuto per l'evento e condividerle con il gruppo.

Tutti i conteggi saranno aggiornati automaticamente.

Collegati all’app MC Spese di Gruppo:
https://spesedigruppo.netlify.app

Fai il Login inserendo il tuo numero di telefono e il PIN personale: *$pin*

Ti aspettiamo!
""";

    // ⭐ Utente già registrato → messaggio più semplice
    case StatoUtente.registrato:
      return """
Ciao $nomePersona,
*$nomeOrganizzatore* ti ha aggiunto all’evento *“$nomeEvento”* che si terrà a *$luogoEvento* $periodo.
Potrai inserire tutte le spese che hai sostenuto per l'evento e condividerle con il gruppo.

Tutti i conteggi saranno aggiornati automaticamente.

Accedi all’app MC Spese di Gruppo dal tuo cellulare o se non l'hai ancora scaricata, dal: 
https://spesedigruppo.netlify.app
""";
  }
}
