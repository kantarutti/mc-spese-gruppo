import 'package:flutter/material.dart';
import 'persone_page.dart';

import '../config/app_widgets.dart';
import '../services/gruppi_service.dart';
import '../widgets/gruppo_widget.dart';
//import '../widgets/dialog_modifica_gruppo.dart';
import '../widgets/event_widgets.dart'; // 🔥 per BoxCard e inputField
import '../utils/help_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GruppiPage extends StatefulWidget {
  final dynamic eventoId;

  const GruppiPage({
    super.key,
    required this.eventoId,
  });

  @override
  State<GruppiPage> createState() => _GruppiPageState();
}

class _GruppiPageState extends State<GruppiPage> {
  final GruppiService _gruppiService = GruppiService();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  bool isLoading = true;
  bool isTyping = false;

  List<Map<String, dynamic>> gruppi = [];

  @override
  void initState() {
    super.initState();
//  SharedPreferences.getInstance().then((prefs) {
//    prefs.remove("showTeamsHelp"); // 🔥 reset
//  });

    _loadGruppi();
  }

  Future<void> _loadGruppi() async {
    final data = await _gruppiService.loadGruppi(widget.eventoId);

    setState(() {
      gruppi = data;
      isLoading = false; // 👈 ora sappiamo che la lista è pronta
    });
  }

  Future<void> _addGruppo() async {
    final nome = nomeController.text.trim();
    final numero = int.tryParse(numeroController.text.trim()) ?? 0;

    if (nome.isEmpty) return;

    final nuovoGruppoId = await _gruppiService.insertGruppo(
      eventoId: widget.eventoId,
      nomeGruppo: nome,
      numeroPersone: numero,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonePage(
          eventoId: widget.eventoId,
          gruppoId: nuovoGruppoId,
        ),
      ),
    );

    _loadGruppi();

    nomeController.clear();
    numeroController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final noUnprotectedGroups =
        gruppi.where((g) => g['protected'] == false).isEmpty;

    return Scaffold(
      appBar: AppWidgets.appBar(
        leftWidget: null,
        titleWidget: const Text(
          "Gestione Team",
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
            // 🔵 BOXCARD con Nome Gruppo + Pulsante
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventWidgets.inputField(
                  label: "Nome Team",
                  controller: nomeController,
                  icon: Icons.group,
                  onChanged: (value) {
                    if (!isTyping) {
                      setState(() => isTyping = true);
                    }
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _addGruppo,
                  icon: const Icon(Icons.add),
                  label: const Text("Aggiungi Team"),
                ),
              ],
            ),

            if (!isLoading && noUnprotectedGroups && !isTyping) ...[
            HelpBanner(
              prefsKey: "showTeamsHelp",
              visible: !isLoading && noUnprotectedGroups && !isTyping,
              title: "Cos'è un Team?",
              message: "Inserisci i vari teams del gruppo.\n"
                  "Ogni team avrà a disposizione il proprio conto dove inserire le spese sostenute per l'evento.\n"
                  "L'app farà tutti i conteggi automaticamente.\n\n"
                  "Dopo aver creato il team,  potrai inserire le persone che vi appartengono.",
            ),

            const SizedBox(height: 20),
            ],            
            Expanded(
              child: ListView.separated(
                itemCount: gruppi.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final gruppo = gruppi[index];

                  return ListTile(
                    title: Text(
                      gruppo['gruppo'] ?? 'Team senza nome',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text("${gruppo['numero_persone']} persone"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ➕ Aggiungi persona
                        IconButton(
                          icon: const Icon(Icons.person,
                              color: Colors.blueAccent),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PersonePage(
                                  eventoId: widget.eventoId,
                                  gruppoId: gruppo['id'],
                                ),
                              ),
                            );
                            _loadGruppi();
                          },
                        ),

                        // ✏️ Modifica gruppo
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.orangeAccent),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (_) => DialogModificaGruppo(
                                gruppoId: gruppo['id'],
                                nomeIniziale: gruppo['gruppo'],
                                numeroIniziale: gruppo['numero_persone'],
                              ),
                            );
                            _loadGruppi();
                          },
                        ),
// 🗑️ Elimina gruppo (con protezione)
                        gruppo['protected'] == true
                            ? IconButton(
                                icon: const Icon(Icons.delete_forever,
                                    color: Colors.grey),
                                onPressed: null, // 🔒 disabilitato
                              )
                            : IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                onPressed: () async {
                                  final conferma = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title:
                                          const Text("Conferma eliminazione"),
                                      content: Text(
                                        "Vuoi davvero eliminare il team \"${gruppo['gruppo']}\"?\n"
                                        "Tutte le persone del team verranno eliminate.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("Annulla"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text("Elimina"),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (conferma == true) {
                                    await _gruppiService
                                        .deleteGruppo(gruppo['id']);
                                    _loadGruppi();
                                  }
                                },
                              ),
                      ],
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PersonePage(
                            eventoId: widget.eventoId,
                            gruppoId: gruppo['id'],
                          ),
                        ),
                      );
                      _loadGruppi();
                    },
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
