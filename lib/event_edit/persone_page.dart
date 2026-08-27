import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../config/app_widgets.dart';
import '../config/app_colors.dart';
import '../services/persone_service.dart';
import '../services/amici_service.dart';
import '../services/invito_service.dart';
import '../widgets/amico_suggestion_widget.dart';
import '../utils/help_banner.dart';

class PersonePage extends StatefulWidget {
  final dynamic eventoId;
  final dynamic gruppoId;

  const PersonePage({
    super.key,
    required this.eventoId,
    required this.gruppoId,
  });

  @override
  State<PersonePage> createState() => _PersonePageState();
}

class _PersonePageState extends State<PersonePage> {
  final PersoneService _personeService = PersoneService();
  final AmiciService _amiciService = AmiciService();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cellulareController = TextEditingController();


  bool isLoading = true;
  bool isTyping = false;

  List<Map<String, dynamic>> persone = [];
  List<Map<String, dynamic>> suggerimenti = [];

  // 🔵 Campi gruppo
  String nomeGruppo = "";
  int numeroPersone = 0;
  // 🔵 Campi evento (per il messaggio di invito)
  String nomeEvento = "";
  String luogoEvento = "";
  String dataInizio = "";
  String dataFine = "";
  String nomeOrganizzatore = "";

  // 🔵 Modalità modifica
  bool isEditing = false;

  // 🔵 Controller per la modalità modifica
  final TextEditingController gruppoEditController = TextEditingController();
  final TextEditingController numeroEditController = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadGruppo();
    _loadEvento(); // 🔵 aggiunto
    _loadPersone();
  }

  Future<void> _loadGruppo() async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('gruppi')
        .select('gruppo, numero_persone')
        .eq('id', widget.gruppoId)
        .single();

    setState(() {
      nomeGruppo = data['gruppo'] ?? '';
      numeroPersone = data['numero_persone'] ?? 0;

      gruppoEditController.text = nomeGruppo;
      numeroEditController.text = numeroPersone.toString();
    });
  }

  Future<void> _loadEvento() async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('eventi')
        .select('nome, localita, data_inizio, data_fine, organizzatore')
        .eq('id', widget.eventoId)
        .single();

    setState(() {
      nomeEvento = data['nome'] ?? '';
      luogoEvento = data['localita'] ?? '';
      dataInizio = data['data_inizio'] ?? '';
      dataFine = data['data_fine'] ?? '';
      nomeOrganizzatore = data['organizzatore'] ?? '';
    });
  }

  Future<void> _loadPersone() async {
    final data = await _personeService.loadPersone(widget.gruppoId);
    setState(() {
      persone = data;
      isLoading = false; // 👈 ora sappiamo che la lista è pronta
    });
  }

  Future<void> _addPersona() async {
    final nome = nomeController.text.trim();
    final cellulare = cellulareController.text.trim();

    if (nome.isEmpty) return;

    // 1️⃣ Inserisco la persona nel gruppo
    await _personeService.insertPersona(
      nome: nome,
      telefono: cellulare,
      eventoId: widget.eventoId,
      gruppoId: widget.gruppoId,
    );

    // 2️⃣ Invio l’invito usando il servizio esterno
    await InvitoService(context).inviaInvito(
      nomePersona: nome,
      cellulare: cellulare,
      nomeOrganizzatore: nomeOrganizzatore,
      nomeEvento: nomeEvento,
      luogoEvento: luogoEvento,
      dataInizio: dataInizio,
      dataFine: dataFine,
    );

    // 3️⃣ Pulizia campi e refresh
    nomeController.clear();
    cellulareController.clear();
    setState(() => suggerimenti.clear());

    await _loadPersone();
    await _loadGruppo();
  }

  Future<void> _searchAmici(String query) async {
    if (query.isEmpty) {
      setState(() => suggerimenti = []);
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint("❌ Utente non loggato");
      return;
    }

    final ownerId = user.id;

    final results = await _amiciService.searchFriendsByName(
      ownerId,
      query,
    );

    // 🔵 Mostra solo suggerimenti, nessun popup
    setState(() => suggerimenti = results);
  }

  Future<Map<String, String>?> chiediNomeTelefono(
    BuildContext context,
    String nomeIniziale,
  ) async {
    final nomeCtrl = TextEditingController(text: nomeIniziale);
    final telefonoCtrl = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Aggiungi persona al team"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeCtrl,
                decoration: const InputDecoration(
                  labelText: "Nome completo",
                  hintText: "Inserisci il nome",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: telefonoCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Numero di telefono",
                  hintText: "Es. +39 3331234567",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annulla"),
            ),
            ElevatedButton(
              onPressed: () {
                final nome = nomeCtrl.text.trim();
                final telefono = telefonoCtrl.text.trim();

                // 🔥 VALIDAZIONE TELEFONO (come nel resto dell'app)
                final regexTelefono = RegExp(r'^\+[0-9]{8,}$');

                if (!regexTelefono.hasMatch(telefono)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Inserisci un numero valido: Inserisci il prefisso internazionale con +",
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(context, {
                  "nome": nome,
                  "telefono": telefono,
                });
              },
              child: const Text("Conferma"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
      final noUnprotectedPersone =
      persone.where((p) => p['protected'] == false).isEmpty;
    return Scaffold(
      appBar: AppWidgets.appBar(
        leftWidget: null,
        titleWidget: const Text(
          "Persone del Team",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        rightWidget: null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: TextEditingController(text: nomeGruppo),
                  readOnly: true,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: "Team",
                    prefixIcon: Icon(Icons.group),

                    // Sfondo grigio chiaro SOLO per readonly
                    filled: true,
                    fillColor: AppColors.readonlyFieldColor,
                  ),

                  // ⭐ Valore in grassetto
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: "Nome persona",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (value) {
                    _searchAmici(value);
                    // 👇 appena digita → nascondi il banner
                    if (!isTyping) {
                      setState(() => isTyping = true);
                    }
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final nome = nomeController.text.trim();

                    // Se il nome è vuoto → non fare nulla
                    if (nome.isEmpty) return;

                    // 👇 Se NON ho già un numero → persona nuova → popup
                    if (cellulareController.text.trim().isEmpty) {
                      final dati = await chiediNomeTelefono(context, nome);

                      if (dati == null) return;

                      nomeController.text = dati["nome"] ?? "";
                      cellulareController.text = dati["telefono"] ?? "";
                    }

                    // 👇 Ora esegui la logica originale
                    await _addPersona();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Aggiungi persona al team"),
                ),
                const SizedBox(height: 8),
                AmicoSuggestionList(
                  risultati: suggerimenti,
                  onSelect: (amico) {
                    nomeController.text = amico['friend_name'];
                    cellulareController.text = amico['friend_cellulare'] ?? '';

                    // 👇 Chiude la lista dei suggerimenti
                    setState(() => suggerimenti = []);
                  },
                ),
              ],
            ),

            // ⭐ BANNER HELP (solo se lista vuota)
            if (!isLoading && noUnprotectedPersone && !isTyping) ...[
              const SizedBox(height: 20),
              HelpBanner(
                prefsKey: "showTeamsHelp",
                visible: true, // 👈 gestiamo noi la visibilità
                title: "Membri del Team",
                message: "Inserisci i vari membri del team.\n"
                    "Queste persone potranno inserire le spese sostenute per l'evento sul conto del Team.\n\n"
                    "L'app farà tutti i conteggi automaticamente",
              ),
//              const SizedBox(height: 20),
            ],

            // 🔵 LISTA PERSONE
            Expanded(
              child: ListView.separated(
                itemCount: persone.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final persona = persone[index];

                  return ListTile(
                    title: Text(
                      persona['persona'] ?? 'Senza nome',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      persona['cellulare']?.isNotEmpty == true
                          ? persona['cellulare']
                          : "Nessun cellulare",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔵 ICONA CONDIVIDI
                        IconButton(
                          icon:
                              const Icon(Icons.share, color: Colors.blueAccent),
                          onPressed: () {
                            InvitoService(context).inviaInvito(
                              nomePersona: persona['persona'],
                              cellulare: persona['cellulare'],
                              nomeOrganizzatore: nomeOrganizzatore,
                              nomeEvento: nomeEvento,
                              luogoEvento: luogoEvento,
                              dataInizio: dataInizio,
                              dataFine: dataFine,
                            );
                          },
                        ),

                        // 🔴 ICONA CESTINO
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () async {
                            await _personeService.deletePersona(persona['id']);
                            await _loadPersone();
                            await _loadGruppo();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppWidgets.actionBar(
        actions: [
          AppWidgets.actionButton(
            icon: Icons.arrow_back,
            label: "Indietro",
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
