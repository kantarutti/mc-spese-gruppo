import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'event_view_page.dart';

class EventEditPage extends StatefulWidget {
  final Map<String, dynamic>? evento;
  final bool isEmbedded;
  const EventEditPage({super.key, this.evento, this.isEmbedded = false});

  @override
  State<EventEditPage> createState() => EventEditPageState();
}

class EventEditPageState extends State<EventEditPage> {
  final _supabase = Supabase.instance.client;
  final _nomeController = TextEditingController();
  final _organizzatoreController = TextEditingController();
  
  String? _tipoEventoSelezionato; 
  String? _localitaSelezionata;
  String? _valutaOrigine; 
  String? _valutaTarget;  
  String? _statoEvento;
  DateTime? _dataInizio;
  DateTime? _dataFine;
  
  List<String> _opzioniLocalita = [];
  List<String> _opzioniValute = [];
  bool _isLoading = false;
  
  final List<String> _statiDisponibili = ['Creazione', 'Preparazione', 'In Corso', 'Concluso', 'Chiuso'];
  
  final List<String> _tipiEventoNomi = [
    'Viaggio', 'Gita', 'Evento', 'Pranzo - Cena', 'Festa', 'Regalo'
  ];

  final TextStyle _fieldStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

  @override
  void initState() {
    super.initState();
    _inizializzaDati();
  }

  Future<void> _inizializzaDati() async {
    if (widget.evento != null) {
      final ev = widget.evento!;
      _nomeController.text = ev['nome'] ?? '';
      _organizzatoreController.text = ev['organizzatore'] ?? '';
      _tipoEventoSelezionato = ev['tipo_evento'];
      _localitaSelezionata = ev['localita'];
      _valutaOrigine = ev['valuta_origine']; 
      _valutaTarget = ev['valuta_target']; 
      _statoEvento = ev['stato'] ?? 'Creazione';
      if (ev['data_inizio'] != null) _dataInizio = DateTime.parse(ev['data_inizio']);
      if (ev['data_fine'] != null) _dataFine = DateTime.parse(ev['data_fine']);
      
      await caricaDatiEvento(ev['id']);

      if (_organizzatoreController.text.isEmpty || _localitaSelezionata == null) {
        final freshData = await _supabase
            .from('eventi')
            .select('organizzatore, localita')
            .eq('id', ev['id'])
            .single();
        
        if (mounted) {
          setState(() {
            if (_organizzatoreController.text.isEmpty) {
              _organizzatoreController.text = freshData['organizzatore'] ?? '';
            }
            _localitaSelezionata ??= freshData['localita'];
          });
        }
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> caricaDatiEvento(dynamic id) async {
    try {
      final resLoc = await _supabase.from('localita').select('localita').eq('evento_id', id);
      final resVal = await _supabase.from('valute').select('valuta').eq('evento_id', id);
      if (mounted) {
        setState(() {
          _opzioniLocalita = List<String>.from(resLoc.map((e) => e['localita']));
          _opzioniValute = List<String>.from(resVal.map((e) => e['valuta']));
        });
      }
    } catch (e) {
      debugPrint("Errore caricamento: $e");
    }
  }

  Future<void> salva() async {
    if (widget.evento == null) return;

    setState(() => _isLoading = true);
    
    final dati = {
      'nome': _nomeController.text,
      'tipo_evento': _tipoEventoSelezionato,
      'organizzatore': _organizzatoreController.text,
      'localita': _localitaSelezionata,
      'valuta_origine': _valutaOrigine,
      'valuta_target': _valutaTarget,
      'stato': _statoEvento,
      'data_inizio': _dataInizio?.toIso8601String(),
      'data_fine': _dataFine?.toIso8601String(),
    };

    try {
      await _supabase.from('eventi').update(dati).eq('id', widget.evento!['id']);
      
      if (mounted) {
        if (widget.isEmbedded) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => EventViewPage(eventoId: widget.evento!['id']),
            ),
            (route) => route.isFirst,
          );
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint("Errore salvataggio: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildField("Evento", TextField(controller: _nomeController, style: _fieldStyle, decoration: const InputDecoration(border: InputBorder.none, isDense: true))),
          
          _buildField("Tipologia", 
            DropdownButton<String>(
              value: _tipoEventoSelezionato,
              isExpanded: true,
              underline: const SizedBox(),
              items: _tipiEventoNomi.map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo, style: _fieldStyle))).toList(),
              onChanged: (v) => setState(() => _tipoEventoSelezionato = v),
            )
          ),

          _buildField("Siamo a", 
            DropdownButton<String>(
              value: _opzioniLocalita.contains(_localitaSelezionata) ? _localitaSelezionata : null,
              isExpanded: true, underline: const SizedBox(),
              items: _opzioniLocalita.map((l) => DropdownMenuItem(value: l, child: Text(l, style: _fieldStyle))).toList(),
              onChanged: (v) => setState(() => _localitaSelezionata = v),
            )
          ),

          Row(
            children: [
              Expanded(
                child: _buildField("Inizio", InkWell(
                  onTap: () async { 
                    DateTime? d = await showDatePicker(
                      context: context, 
                      firstDate: DateTime(2000), 
                      lastDate: DateTime(2100), 
                      initialDate: _dataInizio ?? DateTime.now()
                    ); 
                    if (d != null) setState(() => _dataInizio = d); 
                  }, 
                  child: Text(_dataInizio == null ? "Seleziona" : DateFormat('dd/MM/yyyy').format(_dataInizio!), style: _fieldStyle)
                ))
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildField("Fine", InkWell(
                  onTap: () async { 
                    final DateTime dataMinima = _dataInizio ?? DateTime(2000);
                    DateTime dataInizialeCalendario = _dataFine ?? DateTime.now();
                    if (dataInizialeCalendario.isBefore(dataMinima)) {
                      dataInizialeCalendario = dataMinima;
                    }

                    DateTime? d = await showDatePicker(
                      context: context, 
                      firstDate: dataMinima, 
                      lastDate: DateTime(2100), 
                      initialDate: dataInizialeCalendario,
                    ); 
                    if (d != null) setState(() => _dataFine = d); 
                  }, 
                  child: Text(_dataFine == null ? "Seleziona" : DateFormat('dd/MM/yyyy').format(_dataFine!), style: _fieldStyle)
                ))
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: _buildField("Valuta Spesa", 
                  DropdownButton<String>(
                    value: _opzioniValute.contains(_valutaOrigine) ? _valutaOrigine : null,
                    isExpanded: true, underline: const SizedBox(),
                    items: _opzioniValute.map((v) => DropdownMenuItem(value: v, child: Text(v, style: _fieldStyle))).toList(),
                    onChanged: (v) => setState(() => _valutaOrigine = v),
                  )
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildField("Valuta Conteggi", 
                  DropdownButton<String>(
                    value: _opzioniValute.contains(_valutaTarget) ? _valutaTarget : null,
                    isExpanded: true, underline: const SizedBox(),
                    items: _opzioniValute.map((v) => DropdownMenuItem(value: v, child: Text(v, style: _fieldStyle))).toList(),
                    onChanged: (v) => setState(() => _valutaTarget = v),
                  )
                ),
              ),
            ],
          ),

          _buildField("Organizzatore", TextField(controller: _organizzatoreController, style: _fieldStyle, decoration: const InputDecoration(border: InputBorder.none, isDense: true))),
          
          _buildField("Stato", DropdownButton<String>(value: _statoEvento, isExpanded: true, underline: const SizedBox(), items: _statiDisponibili.map((s) => DropdownMenuItem(value: s, child: Text(s, style: _fieldStyle))).toList(), onChanged: (v) => setState(() => _statoEvento = v))),
          
          //const SizedBox(height: 20),
          //if (_isLoading) 
          //  const CircularProgressIndicator() 
          //else 
          //  ElevatedButton(
          //    onPressed: salva, 
          //    style: ElevatedButton.styleFrom(
          //      backgroundColor: const Color(0xFF00B2FF), 
          //      minimumSize: const Size(double.infinity, 50), 
          //      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
          //    ), 
          //    child: const Text("SALVA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          //  ),
        ],
      ),
    );
  }

  // Metodo aggiornato: rimossa la Row interna e l'icona
  Widget _buildField(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)), 
          child
        ]
      )
    );
  }
}