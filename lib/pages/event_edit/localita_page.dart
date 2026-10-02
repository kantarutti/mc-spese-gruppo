import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_widgets.dart';
import '../../services/message_builder.dart';
import '../../widgets/bubble_widget.dart';
import '../../services/tutorial_service.dart';
import '../../models/localita_model.dart';
import '../../services/localita_service.dart';

class LocalitaPage extends StatefulWidget {
  final dynamic eventoId;

  const LocalitaPage({
    super.key,
    required this.eventoId,
  });

  @override
  State<LocalitaPage> createState() => _LocalitaPageState();
}

class _LocalitaPageState extends State<LocalitaPage> {
  final LocalitaService _localitaService = LocalitaService();
  final TextEditingController nomeController = TextEditingController();

  List<LocalitaModel> localita = [];
  bool loading = true;
  bool showTutorial = false;

  @override
  void initState() {
    super.initState();
    _loadLocalita();
    _checkTutorial();
  }

  // 🔹 Fumetto -------------------------------------------------------
  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool("tutorial_localita") ?? false;

    setState(() {
      showTutorial = !seen; // se non visto → mostra
    });
  }

  Future<void> _dontShowAgain() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("tutorial_localita", true);

    setState(() => showTutorial = false);
  }

  // 🔹 Località -----------------------------------------------------
  Future<void> _loadLocalita() async {
    setState(() => loading = true);

    final data = await _localitaService.getLocalita(widget.eventoId);

    setState(() {
      localita = data;
      loading = false;
    });
  }

  Future<void> _addLocalita() async {
    final nome = nomeController.text.trim();
    if (nome.isEmpty) return;

    await _localitaService.addLocalita(nome, widget.eventoId);

    nomeController.clear();
    _loadLocalita();
  }

  Future<void> _deleteLocalita(int id) async {
    await _localitaService.deleteLocalita(id);
    _loadLocalita();
  }

  // 🔹 Popup Modifica Località -------------------------------------
  void _editLocalita(LocalitaModel item) {
    final controller = TextEditingController(text: item.localita);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Modifica Località"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nome Località"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _localitaService.updateLocalita(
                item.id,
                controller.text.trim(),
              );

              if (!mounted) return;
              Navigator.pop(context);
              _loadLocalita();
            },
            child: const Text("Salva"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🔹 CONTENUTO NORMALE DELLA PAGINA
        Scaffold(
          appBar: AppWidgets.appBar(
            leftWidget: null,
            titleWidget: const Text("Località dell'Evento"           ),
            rightWidget: null,
          ),

          body: Column(
            children: [
              // FORM DI INSERIMENTO
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 0,
                  color: Colors.deepPurple.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        AppWidgets.inputField(
                          label: "Nuova Località",
                          controller: nomeController,
                          icon: Icons.location_city,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _addLocalita,
                          icon: const Icon(Icons.add),
                          label: const Text("Aggiungi alla lista"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // LISTA LOCALITÀ
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: localita.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final item = localita[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.localita,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () => _editLocalita(item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.redAccent),
                                      onPressed: () =>
                                          _deleteLocalita(item.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),

          bottomNavigationBar: AppWidgets.actionBar(
            actions: [
              AppWidgets.actionButton(
                icon: Icons.arrow_back,
                label: "",
                onTap: () => Navigator.pop(context),
              ),
              AppWidgets.actionButton(
                icon: Icons.info,
                label: "",
                onTap: () async {
                  await TutorialService.reset("tutorial_localita");

                  showTutorial =
                      await TutorialService.shouldShow("tutorial_localita");

                  setState(() {});
                },
              ),
            ],
          ),
        ),

        // 🔹 OVERLAY DEL FUMETTO
        if (showTutorial)
          BubbleWidget(
            title: tutorialLocalitaTitle(),
            text: tutorialLocalitaText(),
            onClose: () => setState(() => showTutorial = false),
            onDontShowAgain: _dontShowAgain,
          ),
      ],
    );
  }
}