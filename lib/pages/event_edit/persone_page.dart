import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../../config/app_widgets.dart';
import '../../config/app_colors.dart';
import '../../services/persona_service.dart';
import '../../services/amico_service.dart';
import '../../services/invito_service.dart';
import '../../widgets/amico_suggestion_widget.dart';

import '../../../services/tutorial_service.dart';
import '../../../services/message_builder.dart';
import '../../../widgets/bubble_widget.dart';

// 🔵 Importiamo il validatore centralizzato
import '../../../formatters/formatters.dart';

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
  final PersonaService _personaService = PersonaService();
  final AmicoService _amicoService = AmicoService();

  final TextEditingController nomeController = TextEditingController();
  // Controller invisibile nella UI principale, popolato da suggerimenti o dialog
  final TextEditingController cellulareController = TextEditingController();

  bool isLoading = true;
  bool isTyping = false;
  bool showTutorial = false;

  List<Map<String, dynamic>> persone = [];
  List<Map<String, dynamic>> suggerimenti = [];

  String nomeGruppo = "";
  int numeroPersone = 0;

  String nomeEvento = "";
  String luogoEvento = "";
  String dataInizio = "";
  String dataFine = "";
  String nomeAmministratore = "";

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      showTutorial = await TutorialService.shouldShow("tutorial_persone");

      await _loadGruppo();
      await _loadEvento();
      await _loadPersone();

      setState(() {});
    });
  }

  Future<void> _loadGruppo() async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('gruppi')
        .select('gruppo, numero_persone')
        .eq('id', widget.gruppoId)
        .single();

    nomeGruppo = data['gruppo'] ?? '';
    numeroPersone = data['numero_persone'] ?? 0;
  }

  Future<void> _loadEvento() async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('eventi')
        .select('nome, localita, data_inizio, data_fine, amministratore')
        .eq('id', widget.eventoId)
        .single();

    nomeEvento = data['nome'] ?? '';
    luogoEvento = data['localita'] ?? '';
    dataInizio = data['data_inizio'] ?? '';
    dataFine = data['data_fine'] ?? '';
    nomeAmministratore = data['amministratore'] ?? '';
  }

  Future<void> _loadPersone() async {
    final data = await _personaService.loadPersone(widget.gruppoId);

    persone = data;
    isLoading = false;
  }

  Future<void> _addPersona() async {
    final nome = nomeController.text.trim();
    
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('inserisci_nome_persona'.tr())),
      );
      return;
    }

    // 🔵 Controllo finale di validazione sul numero di cellulare tramite PhoneValidator
    final cellulare = PhoneValidator.validateAndNotify(context, cellulareController.text);
    if (cellulare == null) return; // Se null, il validatore ha già mostrato lo SnackBar

    final risultato = await _personaService.insertPersona(
      nome: nome,
      telefono: cellulare,
      eventoId: widget.eventoId,
      gruppoId: widget.gruppoId,
    );

    // Controlliamo se la persona è già inserita nell'evento
    if (risultato['isAlreadyPresent'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(risultato['message'] ?? 'persona_gia_inserita'.tr()),
          ),
        );
      }
      return;
    }

    if (risultato['success'] == true) {
      await InvitoService(context).inviaInvito(
        nomePersona: nome,
        cellulare: cellulare,
        nomeAmministratore: nomeAmministratore,
        nomeEvento: nomeEvento,
        luogoEvento: luogoEvento,
        dataInizio: dataInizio,
        dataFine: dataFine,
        conto: nomeGruppo,
      );
    }

    nomeController.clear();
    cellulareController.clear();
    suggerimenti.clear();

    await _loadPersone();
    await _loadGruppo();

    setState(() {});
  }

  Future<void> _searchAmici(String query) async {
    if (query.isEmpty) {
      suggerimenti.clear();
      setState(() {});
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final ownerId = prefs.getString('utente_id');

    if (ownerId == null) {
      suggerimenti.clear();
      setState(() {});
      return;
    }

    final results = await _amicoService.searchFriendsByName(ownerId, query);

    suggerimenti = results.map((amico) => amico.toMap()).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppWidgets.appBar(
            leftWidget: null,
            titleWidget: Text(
              'conto_label_appbar'.tr(),
              style: const TextStyle(
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
                TextField(
                  controller: TextEditingController(text: nomeGruppo),
                  readOnly: true,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'conto_label'.tr(),
                    prefixIcon: const Icon(Icons.list),
                    filled: true,
                    fillColor: AppColors.readonlyFieldColor,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                // 📝 Campo visibile SOLO per il nome della persona
                TextField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    labelText: 'nome_persona'.tr(),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  onChanged: (value) {
                    _searchAmici(value);
                    if (!isTyping) {
                      setState(() => isTyping = true);
                    }
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final nome = nomeController.text.trim();

                    if (nome.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('inserisci_prima_nome_persona'.tr())),
                      );
                      return;
                    }

                    // Se non abbiamo ancora un numero (es. non selezionato dai suggerimenti), apriamo il dialog
                    if (cellulareController.text.trim().isEmpty) {
                      final dati = await chiediNomeTelefono(context, nome);

                      if (dati == null) return;

                      nomeController.text = dati["nome"] ?? "";
                      cellulareController.text = dati["telefono"] ?? "";
                    }

                    await _addPersona();
                  },
                  icon: const Icon(Icons.add),
                  label: Text('aggiungi_persona'.tr()),
                ),
                const SizedBox(height: 8),
                AmicoSuggestionList(
                  risultati: suggerimenti,
                  onSelect: (amico) {
                    nomeController.text = amico['friend_name'] ?? '';
                    cellulareController.text = amico['friend_cellulare'] ?? '';
                    suggerimenti.clear();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 20),
              Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          itemCount: persone.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, index) {
                            final persona = persone[index];

                            return ListTile(
                              title: Text(
                                persona['persona'] ?? 'senza_nome'.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                persona['cellulare']?.isNotEmpty == true
                                    ? persona['cellulare']
                                    : 'nessun_cellulare'.tr(),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.share,
                                        color: Colors.blueAccent),
                                    onPressed: () {
                                      InvitoService(context).inviaInvito(
                                        nomePersona: persona['persona'],
                                        cellulare: persona['cellulare'],
                                        nomeAmministratore: nomeAmministratore,
                                        nomeEvento: nomeEvento,
                                        luogoEvento: luogoEvento,
                                        dataInizio: dataInizio,
                                        dataFine: dataFine,
                                        conto: nomeGruppo,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent),
                                    onPressed: () async {
                                      await _personaService
                                          .deletePersona(persona['id']);
                                      await _loadPersone();
                                      await _loadGruppo();
                                      setState(() {});
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
                label: "",
                onTap: () => Navigator.pop(context),
              ),
              AppWidgets.actionButton(
                icon: Icons.info,
                label: "",
                onTap: () async {
                  await TutorialService.reset("tutorial_persone");
                  setState(() => showTutorial = true);
                },
              ),
            ],
          ),
        ),
        if (showTutorial)
          BubbleWidget(
            title: tutorialPersoneTitle(),
            text: tutorialPersoneText(),
            onClose: () => setState(() => showTutorial = false),
            onDontShowAgain: () async {
              await TutorialService.disable("tutorial_persone");
              setState(() => showTutorial = false);
            },
          ),
      ],
    );
  }

  /// Dialog per chiedere il numero se non è stato preso dai suggerimenti
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
          title: Text('aggiungi_persona'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeCtrl,
                decoration: InputDecoration(
                  labelText: 'nome_completo'.tr(),
                ),
              ),
              const SizedBox(height: 12),
              // 🔵 Semplice TextField senza formatter in tempo reale, esattamente come nel login
              TextField(
                controller: telefonoCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'numero_telefono_hint'.tr(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('annulla'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                final nome = nomeCtrl.text.trim();

                if (nome.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('inserisci_nome_completo'.tr())),
                  );
                  return;
                }

                // 🔵 Sfruttiamo esattamente lo stesso PhoneValidator del login
                final cellulare = PhoneValidator.validateAndNotify(context, telefonoCtrl.text);
                if (cellulare == null) return; // Se null, lo SnackBar è già partito e blocca il flusso

                Navigator.pop(context, {
                  "nome": nome,
                  "telefono": cellulare, // Restituisce il numero validato e pulito
                });
              },
              child: Text('conferma'.tr()),
            ),
          ],
        );
      },
    );
  }
}