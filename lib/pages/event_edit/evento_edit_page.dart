import 'package:flutter/material.dart';

import '../../config/app_widgets.dart';
import '../../services/evento_service.dart';
//import '../services/tutorial_service.dart';
import '../../services/message_builder.dart';
import '../../widgets/tutorial_widget.dart';
import '../../utils/date_utility.dart';
import '../../models/event_states_model.dart';

// Widget scompattati
import '../../widgets/evento_tables_buttons.dart';
import '../../widgets/evento_invia_rendiconto.dart';
import '../../widgets/evento_chiudi.dart';
import '../../widgets/evento_riapri.dart';
import '../../widgets/evento_elimina.dart';
import '../../widgets/evento_state_card.dart'; // <-- IMPORTATO IL WIDGET DELLO STATO

// Pagine di navigazione
import 'localita_page.dart';
import 'valute_page.dart';
import 'gruppi_page.dart';

class EventoEditPage extends StatefulWidget {
  final dynamic eventoId;

  const EventoEditPage({
    super.key,
    required this.eventoId,
  });

  @override
  State<EventoEditPage> createState() => EventoEditPageState();
}

class EventoEditPageState extends State<EventoEditPage> {
  final _service = EventoService();
  final GlobalKey<TutorialWidgetState> _tutorialKey =
      GlobalKey<TutorialWidgetState>();

  Map<String, dynamic>? eventoData;
  late TextEditingController nomeController;

  String? tipoEvento;
  DateTime? dataInizio;
  DateTime? dataFine;

  List<String> localitaDisponibili = [];
  String? localitaSelezionata;

  List<String> valuteDisponibili = [];
  String? valutaOrigine;
  String? valutaTarget;
  String? amministratore;

  bool loading = true;
  late EventState statoEnum;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController();

    Future.microtask(() async {
      await _caricaDatiEvento();
    });
  }

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  Future<void> _caricaDatiEvento() async {
    try {
      eventoData = await _service.caricaDatiEvento(widget.eventoId);

      if (eventoData != null) {
        nomeController.text = eventoData!['nome'] ?? '';
        tipoEvento = eventoData!['tipo_evento'];

        dataInizio = eventoData!['data_inizio'];
        dataFine = eventoData!['data_fine'];

        valutaOrigine = eventoData!['valuta_origine'];
        valutaTarget = eventoData!['valuta_target'];
        localitaSelezionata = eventoData!['localita'];

        final statoString = eventoData!['stato'] ?? "Preparazione";
        statoEnum = EventStateParser.fromString(statoString);
      }

      localitaDisponibili = await _service.loadLocalita(widget.eventoId);
      valuteDisponibili = await _service.loadValute(widget.eventoId);
    } catch (e) {
      print("Errore caricamento evento: $e");
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> salva() async {
    if (eventoData == null) return;

    await _service.salvaEvento(
      eventoId: widget.eventoId,
      nome: nomeController.text.trim(),
      tipoEvento: tipoEvento,
      localita: localitaSelezionata,
      dataInizio: dataInizio,
      dataFine: dataFine,
      valutaOrigine: valutaOrigine,
      valutaTarget: valutaTarget,
    );
  }

  Future<void> _handleDatePick({required bool isStart}) async {
    try {
      final result = await DateUtility.pickAndCalculateDates(
        context: context,
        isStart: isStart,
        currentInizio: dataInizio,
        currentFine: dataFine,
      );

      if (result == null) return;

      setState(() {
        dataInizio = result['dataInizio'];
        dataFine = result['dataFine'];
      });

      await salva();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading || eventoData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final statoStr = eventoData!['stato'] ?? "Preparazione";
    final isChiuso = statoStr == "Chiuso";

    final FieldMode fieldMode = isChiuso ? FieldMode.readOnly : FieldMode.edit;

    return TutorialWidget(
      key: _tutorialKey,
      tutorialKey: "tutorial_eventedit",
      title: tutorialEventEditTitle(),
      text: tutorialEventEditText(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppWidgets.appBar(
          leftWidget: null,
          titleWidget: const Text("Configurazione Attività"),
          rightWidget: null,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppWidgets.inputField(
                label: "Nome",
                controller: nomeController,
                icon: Icons.event,
                onChanged: (_) => salva(),
                mode: fieldMode,
              ),
              const SizedBox(height: 20),
              AppWidgets.dropdownField(
                label: "Tipo",
                value: tipoEvento,
                options: const [
                  "Viaggio",
                  "Gita",
                  "Evento",
                  "Pranzo - Cena",
                  "Festa",
                  "Regalo",
                ],
                onChanged: (v) {
                  setState(() => tipoEvento = v);
                  salva();
                },
                icon: Icons.category,
                mode: fieldMode,
              ),
              const SizedBox(height: 20),
              AppWidgets.dropdownField(
                label: "Siamo a",
                value: localitaSelezionata,
                options: localitaDisponibili,
                onChanged: (v) {
                  setState(() => localitaSelezionata = v);
                  salva();
                },
                icon: Icons.place,
                mode: fieldMode,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppWidgets.dateField(
                      label: "Data Inizio",
                      date: dataInizio,
                      onTap: () => _handleDatePick(isStart: true),
                      mode: fieldMode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppWidgets.dateField(
                      label: "Data Fine",
                      date: dataFine,
                      onTap: () => _handleDatePick(isStart: false),
                      mode: fieldMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppWidgets.valutaField(
                      label: "Valuta Spese",
                      value: valutaOrigine,
                      options: valuteDisponibili,
                      onChanged: (v) {
                        setState(() => valutaOrigine = v);
                        salva();
                      },
                      mode: fieldMode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppWidgets.valutaField(
                      label: "Valuta Conteggi",
                      value: valutaTarget,
                      options: valuteDisponibili,
                      onChanged: (v) {
                        setState(() => valutaTarget = v);
                        salva();
                      },
                      mode: fieldMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Inserito EventoStateCard sotto le valute
              EventoStateCard(statoEnum: statoEnum),
              const SizedBox(height: 30),
              EventoTablesButtons(
                mode: fieldMode,
                onLocalitaTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LocalitaPage(eventoId: widget.eventoId),
                    ),
                  );
                  localitaDisponibili =
                      await _service.loadLocalita(widget.eventoId);
                  setState(() {});
                },
                onValuteTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ValutePage(eventoId: widget.eventoId),
                    ),
                  );
                  valuteDisponibili =
                      await _service.loadValute(widget.eventoId);
                  setState(() {});
                },
                onTeamsTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GruppiPage(eventoId: widget.eventoId),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppWidgets.whiteBar(
              left: null,
              center: EventoInviaRendiconto(
                eventoId: widget.eventoId,
                service: _service,
              ),
              right: isChiuso
                  ? EventoRiapri(
                      eventoId: widget.eventoId,
                      service: _service,
                      onStatoAggiornato: () async {
                        await _caricaDatiEvento();
                        if (mounted) setState(() {});
                      },
                    )
                  : null,
            ),
            AppWidgets.actionBarBalanced(
              left: AppWidgets.actionButton(
                icon: Icons.arrow_back,
                label: "",
                onTap: () => Navigator.pop(context, true),
              ),
              center: isChiuso
                  ? EventoElimina(
                      eventoId: widget.eventoId,
                      service: _service,
                    )
                  : EventoChiudi(
                      eventoId: widget.eventoId,
                      service: _service,
                      onStatoAggiornato: () async {
                        await _caricaDatiEvento();
                        if (mounted) setState(() {});
                      },
                    ),
              right: AppWidgets.actionButton(
                icon: Icons.info,
                label: "",
                onTap: () async {
                  await _tutorialKey.currentState?.resetAndShow();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
