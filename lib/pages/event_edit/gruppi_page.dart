import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'persone_page.dart';

import '../../config/app_widgets.dart';
import '../../models/gruppo_model.dart';
import '../../services/gruppo_service.dart';
import '../../widgets/gruppo_widget.dart';

import '../../services/tutorial_service.dart';
import '../../services/message_builder.dart';
import '../../widgets/bubble_widget.dart';

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

  bool isLoading = true;
  bool showTutorial = true;

  List<GruppoModel> gruppi = [];

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      showTutorial = await TutorialService.shouldShow("tutorial_gruppi");
      await _loadGruppi();
      setState(() {});
    });
  }

  Future<void> _loadGruppi() async {
    setState(() => isLoading = true);
    try {
      gruppi = await _gruppiService.loadGruppi(widget.eventoId);
    } catch (e) {
      // Gestione errori opzionale
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addGruppo() async {
    final nome = nomeController.text.trim();
    if (nome.isEmpty) return;

    final nuovoGruppoId = await _gruppiService.insertGruppo(
      eventoId: widget.eventoId,
      nomeGruppo: nome,
      numeroPersone: 0, 
    );

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonePage(
          eventoId: widget.eventoId,
          gruppoId: nuovoGruppoId,
        ),
      ),
    );

    nomeController.clear();
    await _loadGruppi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidgets.appBar(
        leftWidget: null,
        titleWidget: Text(
          'conti_spesa'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        rightWidget: null,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔵 BOXCARD CONTO con Nome + Pulsanti
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppWidgets.inputField(
                      label: 'conto_spesa'.tr(),
                      controller: nomeController,
                      icon: Icons.list,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _addGruppo,
                      icon: const Icon(Icons.add),
                      label: Text('aggiungi_conto'.tr()),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔵 LISTA DEI GRUPPI
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          itemCount: gruppi.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, index) {
                            final gruppo = gruppi[index];

                            return ListTile(
                              title: Text(
                                gruppo.gruppo.isEmpty
                                    ? 'conto_senza_nome'.tr()
                                    : gruppo.gruppo,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('${gruppo.numeroPersone} ${'persone_label'.tr()}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Pulsante Gestione Persone
                                  IconButton(
                                    icon: const Icon(Icons.person,
                                        color: Colors.blueAccent),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PersonePage(
                                            eventoId: widget.eventoId,
                                            gruppoId: gruppo.id,
                                          ),
                                        ),
                                      );
                                      await _loadGruppi();
                                    },
                                  ),
                                  // Pulsante Modifica
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.orangeAccent),
                                    onPressed: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (_) => DialogModificaGruppo(
                                          gruppoId: gruppo.id,
                                          nomeIniziale: gruppo.gruppo,
                                          numeroIniziale: gruppo.numeroPersone,
                                        ),
                                      );
                                      await _loadGruppi();
                                    },
                                  ),
                                  // Pulsante Elimina (condizionale se protetto)
                                  gruppo.protected
                                      ? const IconButton(
                                          icon: Icon(Icons.delete_forever,
                                              color: Colors.grey),
                                          onPressed: null,
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent),
                                          onPressed: () async {
                                            final conferma =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: Text(
                                                    'conferma_eliminazione'.tr()),
                                                content: Text(
                                                  "${'vuoi_davvero_eliminare_conto'.tr(args: [gruppo.gruppo])}\n${'tutte_le_persome_verranno_eliminate'.tr()}",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                    child:
                                                        Text('annulla'.tr()),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, true),
                                                    child: Text('elimina'.tr()),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (conferma == true) {
                                              await _gruppiService
                                                  .deleteGruppo(gruppo.id);
                                              await _loadGruppi();
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
                                      gruppoId: gruppo.id,
                                    ),
                                  ),
                                );
                                await _loadGruppi();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // 🔥 BubbleWidget per il tutorial
          if (!isLoading && showTutorial)
            BubbleWidget(
              title: tutorialGruppiTitle(),
              text: tutorialGruppiText(),
              onClose: () => setState(() => showTutorial = false),
              onDontShowAgain: () async {
                await TutorialService.disable("tutorial_gruppi");
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
              await TutorialService.reset("tutorial_gruppi");
              showTutorial =
                  await TutorialService.shouldShow("tutorial_gruppi");
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}