import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'message_builder.dart';   // dove hai il tuo buildMessaggioInvito

class InvitoService {
  final BuildContext context;

  InvitoService(this.context);

  Future<void> inviaInvito({
    required String nomePersona,
    required String cellulare,
    required String nomeOrganizzatore,
    required String nomeEvento,
    required String luogoEvento,
    required String dataInizio,
    required String dataFine,
  }) async {

    // 1️⃣ Recupero dati utente da Supabase
    final userData = await Supabase.instance.client
        .from('utenti')
        .select()
        .eq('cellulare', cellulare)
        .maybeSingle();

    final bool utenteRegistrato = userData?['utente_registrato'] ?? false;
    final String pin = userData?['PIN'] ?? '';

    final stato = utenteRegistrato
        ? StatoUtente.registrato
        : StatoUtente.nonRegistrato;

    // 2️⃣ Genero il messaggio
    final messaggio = buildMessaggioInvito(
      nomePersona: nomePersona,
      nomeOrganizzatore: nomeOrganizzatore,
      nomeEvento: nomeEvento,
      luogoEvento: luogoEvento,
      dataInizio: dataInizio,
      dataFine: dataFine,
      stato: stato,
      pin: pin,
    );

    // 3️⃣ Popup anteprima
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Anteprima invito"),
          content: SingleChildScrollView(
            child: SelectableText(
              messaggio,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annulla"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Share.share(messaggio);
              },
              child: const Text("Invia"),
            ),
          ],
        );
      },
    );
  }
}
