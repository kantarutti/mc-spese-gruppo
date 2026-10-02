// ===============================================================
//  MESSAGE BUILDER — genera testi dell’app
// ===============================================================

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
*$nomeAmministratore* ti ha aggiunto all’attività *“$nomeEvento”* che si terrà $periodo.
Inserisci tutte le spese che sostiteni per l'attività e condividile con il gruppo.

Tutti i conteggi saranno aggiornati automaticamente.

Collegati all’app: https://spesedigruppo.mcapplicazioni.com

Fai il Login inserendo il tuo numero di telefono e il PIN provvisorio: *$pin*

Attenzione iPhone!
Se hai iOS e non vedi l'app, ma vedi 'Isolamento Attivo' disattiva 'Modalità di Sicurezza' per questa app.
 > Impostazioni > Privacy e sicurezza > Modalità di Isolamento > spesedigruppo.mcapplicazioni.com

Ti aspettiamo!
""";

    // ⭐ Utente già registrato → messaggio più semplice
    case StatoUtente.registrato:
      return """
Ciao $nomePersona,
*$nomeAmministratore* ti ha aggiunto all’attività *“$nomeEvento”* che si terrà $periodo.
Inserisci tutte le spese che sostiteni per l'attività e condividile con il gruppo.

Tutti i conteggi saranno aggiornati automaticamente.

Accedi all’app MC Spese di Gruppo dal tuo cellulare o se non l'hai ancora scaricata, da: 
https://spesedigruppo.mcapplicazioni.com

Attenzione iPhone!
Se hai iOS e non vedi l'app, ma vedi 'Isolamento Attivo' disattiva 'Modalità di Sicurezza' per questa app.
 > Impostazioni > Privacy e sicurezza > Modalità di Isolamento > spesedigruppo.pages.dev

Ti aspettiamo!
""";
  }
}

// ---------------------------------------------------------------
// 3. TUTORIAL — Testi dei fumetti
// ---------------------------------------------------------------


// 🔹 HOME
String tutorialHomeTitle() => "Benvenuto in 'Spese di Gruppo'";
String tutorialHomeText() => """

Questa app ti aiuta a gestire in modo semplice e veloce tutte le spese di un evento.

L'attività può essere: 
   🔹Personale, quando vuoi tenere traccia delle tue spese
   🔹Di gruppo, quando più persone partecipano, vuoi sapere la spesa totale ed i conguagli tra i partecipanti
 
🔹 Multi-Località e Multi-Valuta: 
inserisci le spese nella valuta del posto (EUR, USD, JPY…) e l’app converte tutto nella tua valuta principale.

🔹 Tutto è automatizzato: 
tu devi solo inserire le spese che sostieni.

🔹 Tutorial:
nelle pagine, dove previsto, cliccando sull’icona “info”, potrai vedere il tutorial dedicato a quella pagina.
""";

// 🔹 ATTIVITA'
String tutorialEventViewTitle() => "La tua Attività";

String tutorialEventViewText() => """
In queste pagine potrai gestire i costi dell'attività in corso:

   🔹 Inserisci le tue Spese  
   🔹 Inserisci i tuoi Giroconti  
   🔹 Guarda i Grafici

Se sei tu che hai creato l'attività, dovrai gestirne la configurazione: inserire le località, le valute, i conti di spesa e le persone che vi partecipano.
""";


// 🔹 CONFIGURAZIONE ATTIVITA'
String tutorialEventEditTitle() => "Configurazione dell’Attività";
String tutorialEventEditText() => """
Prima di configurare l’attività, completa le tabelle di supporto:

• Località  
• Valute  
• Persone

Una volta compilate queste tabelle, inserisci le altre informazioni dell'attività.
""";
// 🔹 LOCALITÀ
String tutorialLocalitaTitle() => "Le Località";
String tutorialLocalitaText() => """
Le località indicano i luoghi dove si svolgono le attività.

Ti aiutano a organizzare meglio le spese e a capire dove sono stati sostenuti i costi.
""";

// 🔹 VALUTE
String tutorialValuteTitle() => "Le Valute";
String tutorialValuteText() => """
Qui puoi aggiungere le valute utilizzate nell’evento.

Servono per poter registare le spese in valuta estera e mantenere i conti corretti tra partecipanti.
""";

// 🔹 CONTI
String tutorialGruppiTitle() => "I Conti Spesa";
String tutorialGruppiText() => """
I Conti Spesa organizzano le uscite dell'attività. 

Puoi associare una o più Persone allo stesso conto quando condividono le medesime spese.
Esempio: "Marito & Moglie" su un unico conto condiviso.

Ogni Persona inserisce spese e giroconti nel proprio Conto Spesa assegnato.

L’app calcola automaticamente: 
  🔹Spesa Totale, Pro Capite
e per ciascun Conto: 
   🔹Pagato, Dovuto e Conguaglio
""";

// 🔹 PERSONE
String tutorialPersoneTitle() => "Le Persone";
String tutorialPersoneText() => """
Le Persone sono i partecipanti associati ai Conti Spesa, autorizzati a registrare uscite e giroconti.

Quando aggiungi una Persona per la prima volta:
   🔹 Inserisci il suo nome e il numero di cellulare.
   🔹 L’app la salva, la associa al Conto Spesa e la aggiunge alla tua rubrica interna.

Le volte successive ti basterà iniziare a digitare il nome e selezionarlo dalla lista, senza dover inserire nuovamente i dati.

L’app calcola in automatico:
    🔹 Il Totale delle Persone registrate
    🔹 Il Numero di Partecipanti associati al Conto.
""";

// 🔹 SPESE
String tutorialSpeseTitle() => "Le Spesa?";
String tutorialSpeseText() => """
Qui puoi registrare le spese sostenute relative all’attivitàevento  
Inserisci importo, categoria, località e chi ha pagato: l’app aggiorna tutto automaticamente.
""";

