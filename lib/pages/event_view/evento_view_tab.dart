import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_widgets.dart';
import '../../config/app_event_states.dart';
import '../../models/event_states_model.dart';
import '../../models/evento_model.dart';
import '../../services/evento_service.dart';

import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../event_edit/evento_edit_page.dart';

// ⭐ IMPORT PER IL TUTORIAL
import '../../services/tutorial_service.dart';
import '../../services/message_builder.dart';
import '../../widgets/bubble_widget.dart';

class EventoViewTab extends StatefulWidget {
  final dynamic eventoId;
  const EventoViewTab({super.key, required this.eventoId});

  @override
  State<EventoViewTab> createState() => _EventoViewTabState();
}

class _EventoViewTabState extends State<EventoViewTab> {
  final _supabase = Supabase.instance.client;
  final EventoService _eventoService = EventoService();
  
  String? _userId;
  String? _amministratoreId;

  String _tassoCambio = "Caricamento...";
  bool _mostraCambio = true;
  bool showTutorial = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchLiveExchangeRate();

    Future.microtask(() async {
      showTutorial = await TutorialService.shouldShow("tutorial_eventview");
      setState(() {});
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('utente_id');
  }

  Future<void> _fetchLiveExchangeRate() async {
    try {
      final evento = await _eventoService.getEventoById(widget.eventoId);
      if (evento == null) return;

      final String vSpese = evento.valutaOrigine ?? 'EUR';
      final String vConteggi = evento.valutaTarget ?? 'EUR';

      if (vSpese == vConteggi) {
        if (mounted) setState(() => _mostraCambio = false);
        return;
      }

      final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/$vConteggi');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final rates = jsonDecode(response.body)['rates'];
        final rate = rates[vSpese];
        if (mounted) {
          setState(() {
            _tassoCambio = "$vConteggi 1.00  <->  ${rate.toStringAsFixed(2)} $vSpese";
            _mostraCambio = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _tassoCambio = "Errore connessione");
      }
    }
  }

  String _formattaPeriodo(DateTime? inizio, DateTime? fine) {
    if (inizio == null) return "-";
    String dataI = DateFormat('dd-MM-yyyy').format(inizio);
    if (fine == null || inizio == fine) return dataI;
    String dataF = DateFormat('dd-MM-yyyy').format(fine);
    return "$dataI  -  $dataF";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _supabase
              .from('eventi')
              .stream(primaryKey: ['id'])
              .eq('id', widget.eventoId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final evMap = snapshot.data!.first;
            final evento = EventoModel.fromMap(evMap);

            _amministratoreId = evento.amministratoreId;

            final double totaleSpesa = evento.totaleSpesa;
            final int numeroPersone = evento.numeroPersone > 0 ? evento.numeroPersone : 1;
            final double proCapite = totaleSpesa / numeroPersone;

            final String statoString = evento.stato ?? "Preparazione";
            final EventState statoEnum = EventStateParser.fromString(statoString);

            return Scaffold(
              backgroundColor: Colors.white,
              bottomNavigationBar: (_amministratoreId != null && _amministratoreId == _userId)
                  ? AppWidgets.whiteBar(
                      left: null,
                      center: AppWidgets.whiteButton(
                        icon: Icons.edit,
                        label: "Modifica",
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventoEditPage(eventoId: widget.eventoId),
                            ),
                          );
                          setState(() {});
                        },
                      ),
                      right: AppWidgets.whiteButton(
                        icon: Icons.info,
                        label: "",
                        onTap: () async {
                          await TutorialService.reset("tutorial_eventview");
                          showTutorial = await TutorialService.shouldShow("tutorial_eventview");
                          setState(() {});
                        },
                      ),
                    )
                  : null,
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      _buildBox(
                        "",
                        _formattaPeriodo(evento.dataInizio, evento.dataFine),
                        Colors.black87,
                        small: true,
                      ),
                      const SizedBox(height: 10),
                      _buildBox(
                        "",
                        "${evento.numeroPersone} Persone",
                        Colors.black87,
                        small: true,
                      ),
                      const SizedBox(height: 30),
                      _buildBox(
                        "Siamo a",
                        evento.localita ?? "N/D",
                        Colors.black87,
                      ),
                      const SizedBox(height: 10),
                      _buildBox(
                        "Spesa Totale",
                        totaleSpesa.toStringAsFixed(2),
                        Colors.red,
                      ),
                      const SizedBox(height: 10),
                      _buildBox(
                        "Pro Capite",
                        proCapite.toStringAsFixed(2),
                        Colors.blue,
                      ),
                      const SizedBox(height: 10),
                      if (_mostraCambio)
                        _buildBox(
                          "Cambio",
                          _tassoCambio,
                          Colors.black87,
                          small: true,
                        ),
                      const SizedBox(height: 30),
                      _buildBox(
                        "Amministratore",
                        evento.amministratore ?? "N/D",
                        Colors.black87,
                      ),
                      const SizedBox(height: 30),
                      _buildBox(
                        "Stato",
                        statoEnum.label,
                        AppEventStates.getColor(statoEnum),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        if (showTutorial)
          BubbleWidget(
            title: tutorialEventViewTitle(),
            text: tutorialEventViewText(),
            onClose: () => setState(() => showTutorial = false),
            onDontShowAgain: () async {
              await TutorialService.disable("tutorial_eventview");
              setState(() => showTutorial = false);
            },
          ),
      ],
    );
  }

  Widget _buildBox(String label, String value, Color color, {bool small = false}) {
    return Column(
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: small ? 18 : 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}