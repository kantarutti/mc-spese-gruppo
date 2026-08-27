import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_widgets.dart';
import '../config/app_event_states.dart';

import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../event_edit/event_edit_page.dart';

class EventTab extends StatefulWidget {
  final dynamic eventoId;
  const EventTab({super.key, required this.eventoId});

  @override
  State<EventTab> createState() => _EventTabState();
}

class _EventTabState extends State<EventTab> {
  final _supabase = Supabase.instance.client;
  String? _userId;
  String? _organizzatoreId;

  static const Color azzurroIntenso = Color(0xFF00B2FF);
  String _tassoCambio = "Caricamento...";
  bool _mostraCambio = true;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // 🔵 chiamata senza await
    _fetchLiveExchangeRate();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('utente_id');
  }

  Future<void> _fetchLiveExchangeRate() async {
    try {
      final data = await _supabase
          .from('eventi')
          .select('valuta_origine, valuta_target')
          .eq('id', widget.eventoId)
          .single();

      final String vSpese = data['valuta_origine'] ?? 'EUR';
      final String vConteggi = data['valuta_target'] ?? 'EUR';

      if (vSpese == vConteggi) {
        if (mounted) setState(() => _mostraCambio = false);
        return;
      }

      final url =
          Uri.parse('https://api.exchangerate-api.com/v4/latest/$vConteggi');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final rates = jsonDecode(response.body)['rates'];
        final rate = rates[vSpese];
        if (mounted) {
          setState(() {
            _tassoCambio =
                "$vConteggi 1.00  <->  ${rate.toStringAsFixed(2)} $vSpese";
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

  String _formattaPeriodo(String? inizio, String? fine) {
    if (inizio == null) return "-";
    String dataI = DateFormat('dd-MM-yyyy').format(DateTime.parse(inizio));
    if (fine == null || inizio == fine) return dataI;
    String dataF = DateFormat('dd-MM-yyyy').format(DateTime.parse(fine));
    return "$dataI  -  $dataF";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _supabase
          .from('eventi')
          .stream(primaryKey: ['id']).eq('id', widget.eventoId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Center(child: CircularProgressIndicator());
        final ev = snapshot.data!.first;
        _organizzatoreId = ev['organizzatore_id']?.toString();

        final double totaleSpesa = (ev['totale_spesa'] ?? 0).toDouble();
        final int numero_persone = ev['numero_persone'] ?? 1;
        final double proCapite =
            totaleSpesa / (numero_persone > 0 ? numero_persone : 1);
        final String stato = ev['stato'] ?? "Preparazione";
        final String tipoEvento = ev['tipo_evento'] ?? "Viaggio";

        return Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar:
              (_organizzatoreId != null && _organizzatoreId == _userId)
                  ? AppWidgets.tabBar(
                      center: AppWidgets.tabButton(
                        icon: Icons.edit,
                        label: "Modifica",
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventEditPage(evento: ev),
                            ),
                          );
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
                      _formattaPeriodo(ev['data_inizio'], ev['data_fine']),
                      Colors.black87,
                      small: true),
                  _buildBox("", "$numero_persone Persone", Colors.black87,
                      small: true),
                  const SizedBox(height: 30),
                  _buildBox("Siamo a", ev['localita'] ?? "N/D", Colors.black87),
                  const SizedBox(height: 10),
                  _buildBox("Spesa Totale", totaleSpesa.toStringAsFixed(2),
                      Colors.red),
                  const SizedBox(height: 10),
                  _buildBox(
                      "Pro Capite", proCapite.toStringAsFixed(2), Colors.blue),
                  const SizedBox(height: 10),
                  if (_mostraCambio)
                    _buildBox("Cambio", _tassoCambio, Colors.black87,
                        small: true),
                  const SizedBox(height: 30),
                  // Invertito il posto tra Organizzatore e Stato
                  _buildBox("Amministratore", ev['organizzatore'] ?? "N/D",
                      Colors.black87),
                  const SizedBox(height: 30),
                  // STATO -------------------------------------------
                  _buildBox("Stato", stato, AppEventStates.getColor(stato)),
                  const SizedBox(height: 30),

                  if (_organizzatoreId != null && _organizzatoreId == _userId)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBox(String label, String value, Color color,
      {bool small = false}) {
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
