import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../config/app_widgets.dart';
import '../../models/valuta_model.dart';

import '../../services/valuta_service.dart';
import '../../services/valute_info_service.dart';
import '../../services/message_builder.dart';
import '../../services/tutorial_service.dart';
import '../../widgets/bubble_widget.dart';

class ValutePage extends StatefulWidget {
  final dynamic eventoId;

  const ValutePage({
    super.key,
    required this.eventoId,
  });

  @override
  State<ValutePage> createState() => _ValutePageState();
}

class _ValutePageState extends State<ValutePage> {
  final ValutaService _valutaService = ValutaService();
  final TextEditingController valutaController = TextEditingController();

  List<ValutaModel> valute = [];
  bool loading = true;
  bool showTutorial = true;

  // 🔥 Evidenziazione rossa del match
  List<TextSpan> _highlightMatch(String text, String query) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;
    int index;

    while ((index = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      showTutorial = await TutorialService.shouldShow("tutorial_valute");
      await _loadValute();
      setState(() {});
    });

    ValuteInfoService.load();
  }

  Future<void> _loadValute() async {
    setState(() => loading = true);

    try {
      valute = await _valutaService.getValute(widget.eventoId);
    } catch (e) {
      // Gestione errori opzionale
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _addValuta() async {
    final nuovaValuta = valutaController.text.trim().toUpperCase();
    if (nuovaValuta.isEmpty) return;

    await _valutaService.addValuta(nuovaValuta, widget.eventoId);

    valutaController.clear();
    await _loadValute();
    setState(() {});
  }

  // ID di tipo int per la tabella valute
  Future<void> _deleteValuta(int id) async {
    await _valutaService.deleteValuta(id);
    await _loadValute();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final query = valutaController.text.trim();
    final showSearchResults = query.isNotEmpty;

    return Scaffold(
      appBar: AppWidgets.appBar(
        leftWidget: null,
        titleWidget: Text('valute_evento'.tr()),
        rightWidget: null,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 🔵 FORM DI INSERIMENTO
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 0,
                  color: Colors.blue.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // 🔵 INPUT UTILIZZANDO IL COMPONENTE CENTRALIZZATO
                        AppWidgets.inputField(
                          label: 'nuova_valuta'.tr(),
                          controller: valutaController,
                          icon: Icons.currency_exchange,
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 12),

                        // 🔵 PULSANTE AGGIUNGI
                        ElevatedButton.icon(
                          onPressed: _addValuta,
                          icon: const Icon(Icons.add),
                          label: Text('aggiungi_alla_lista'.tr()),
                        ),

                        const SizedBox(height: 12),

                        // 🔵 LISTA DI RICERCA (scrollabile, no overflow)
                        if (showSearchResults)
                          Container(
                            constraints: const BoxConstraints(
                              maxHeight: 400,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListView(
                              shrinkWrap: true,
                              children:
                                  ValuteInfoService.search(query).map((v) {
                                final countries =
                                    (v['countries'] as List).join(", ");

                                return ListTile(
                                  title: RichText(
                                    text: TextSpan(
                                      children: _highlightMatch(
                                        "${v['code']} - ${v['name']}",
                                        query,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  subtitle: RichText(
                                    text: TextSpan(
                                      children: _highlightMatch(
                                        countries,
                                        query,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      valutaController.text = v['code'];
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // 🔵 LISTA VALUTE EVENTO (con bidoncino)
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: valute.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final item = valute[index];

                          final info =
                              ValuteInfoService.findByCode(item.valuta);
                          final display = info != null
                              ? "${info['code']} - ${info['name']}"
                              : item.valuta;

                          return ListTile(
                            title: Text(
                              display,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            // 🔥 BIDONCINO
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteValuta(item.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (!loading && showTutorial)
            BubbleWidget(
              title: tutorialValuteTitle(),
              text: tutorialValuteText(),
              onClose: () => setState(() => showTutorial = false),
              onDontShowAgain: () async {
                await TutorialService.disable("tutorial_valute");
                setState(() => showTutorial = false);
              },
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
              await TutorialService.reset("tutorial_valute");
              showTutorial =
                  await TutorialService.shouldShow("tutorial_valute");

              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}