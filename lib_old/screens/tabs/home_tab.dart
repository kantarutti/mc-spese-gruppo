import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../event_manage_page.dart'; 
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeTab extends StatefulWidget {
  final dynamic eventoId;
  const HomeTab({super.key, required this.eventoId});

  @override
  State<HomeTab> createState() => _HomeTabState();
  
}

class _HomeTabState extends State<HomeTab> {
  final _supabase = Supabase.instance.client;
  static const Color azzurroIntenso = Color(0xFF00B2FF);
  String _tassoCambio = "Caricamento...";
  bool _mostraCambio = true;

  @override
  void initState() {
    super.initState();
    _fetchLiveExchangeRate();
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

  String _formattaPeriodo(String? inizio, String? fine) {
    if (inizio == null) return "-";
    String dataI = DateFormat('dd-MM-yyyy').format(DateTime.parse(inizio));
    if (fine == null || inizio == fine) return dataI;
    String dataF = DateFormat('dd-MM-yyyy').format(DateTime.parse(fine));
    return "$dataI  -  $dataF";
  }

  Color _getColoreStato(String? stato) {
    switch (stato) {
      case 'Creazione': return Colors.grey;
      case 'Preparazione': return Colors.orange;
      case 'In Corso': return Colors.green;
      case 'Concluso': return azzurroIntenso;
      case 'Chiuso': return Colors.red;
      default: return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _supabase.from('eventi').stream(primaryKey: ['id']).eq('id', widget.eventoId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: CircularProgressIndicator());
        final ev = snapshot.data!.first;
        
        final double totaleSpesa = (ev['totale_spesa'] ?? 0).toDouble();
        final int persone = ev['persone'] ?? 1;
        final double proCapite = totaleSpesa / (persone > 0 ? persone : 1);
        final String stato = ev['stato'] ?? "Preparazione";
        final String tipoEvento = ev['tipo_evento'] ?? "Viaggio";

        return Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox.expand( 
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    // Rimosso il nome dell'evento
                    Text(_formattaPeriodo(ev['data_inizio'], ev['data_fine']), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('$persone Persone', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    // Rimossa l'icona del tipo evento, lasciato solo il testo
                    Text(tipoEvento, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    _buildBox("Siamo a", ev['localita'] ?? "N/D", Colors.black87),
                    const SizedBox(height: 30),
                    _buildBox("Spesa Totale", totaleSpesa.toStringAsFixed(2), Colors.red),
                    const SizedBox(height: 30),
                    _buildBox("Pro Capite", proCapite.toStringAsFixed(2), Colors.blue),
                    const SizedBox(height: 25),
                    if (_mostraCambio)
                      _buildBox("Cambio", _tassoCambio, Colors.black87, small: true),
                    const SizedBox(height: 25),
                    // Invertito il posto tra Organizzatore e Stato
                    _buildBox("Organizzatore", ev['organizzatore'] ?? "N/D", Colors.black87),
                    const SizedBox(height: 30),
                    _buildBox("Stato", stato, _getColoreStato(stato)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: azzurroIntenso,
            child: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => EventManagePage(evento: ev)
              )).then((_) => _fetchLiveExchangeRate());
            },
          ),
        );
      },
    );
  }

  Widget _buildBox(String label, String value, Color color, {bool small = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: small ? 18 : 22, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}