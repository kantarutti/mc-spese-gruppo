import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:intl/intl.dart';
import 'dart:convert'; // Necessario per decodificare il JSON dell'API[cite: 5]
import 'package:http/http.dart'
    as http; // Necessario per la chiamata internet[cite: 5]
import '../../config/app_widgets.dart';
import '../../widgets/evento_card.dart';
import '../home_page.dart';

class GroupExpenseTab extends StatefulWidget {
  final dynamic gruppoId;
  final dynamic eventoId;
  final Map<String, dynamic>? spesaIniziale; // Se nullo, è un nuovo inserimento

  const GroupExpenseTab(
      {super.key,
      required this.gruppoId,
      required this.eventoId,
      this.spesaIniziale});

  @override
  State<GroupExpenseTab> createState() => _GroupExpensePageState();
}

class _GroupExpensePageState extends State<GroupExpenseTab> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // Controller e variabili di stato
  DateTime _dataSelezionata = DateTime.now();
  String? _localitaScelta;
  String _valutaScelta = 'EUR';
  String _valutaTarget = 'EUR';
  double _tassoAnteprima = 1.0;
  bool _isLoading =
      false; // Stato per gestire l'attesa della ricerca internet[cite: 1, 5]

  // Controller per la spesa (quella che inserisce l'utente ora)
  final TextEditingController _spesaController = TextEditingController();

  String? _tipologiaScelta;
  final TextEditingController _causaleController = TextEditingController();

  List<String> _listaLocalita = [];
  List<String> _listaValute = [];
  final List<String> _listaTipologie = [
    'Trasporti',
    'Alloggi',
    'Cibo & Bevande',
    'Visite & Svago',
    'Altro'
  ];

  @override
  void initState() {
    super.initState();
    _caricaDatiEvento();
    if (widget.spesaIniziale != null) {
      // Leggiamo la spesa e la formattiamo a 2 decimali
      double spesaRecuperata =
          double.tryParse(widget.spesaIniziale!['spesa'].toString()) ?? 0.0;
      _spesaController.text = spesaRecuperata.toStringAsFixed(2);

      _causaleController.text = widget.spesaIniziale!['causale'] ?? '';

      // Carica la valuta salvata e aggiorna lo stato dei pulsanti
      _valutaScelta = widget.spesaIniziale!['valuta_origine'] ?? '';
      _valutaTarget = widget.spesaIniziale!['valuta_target'] ?? 'EUR';

      if (widget.spesaIniziale!['data'] != null) {
        _dataSelezionata = DateTime.parse(widget.spesaIniziale!['data']);
      }

      _tipologiaScelta = widget.spesaIniziale!['tipologia'];
      _localitaScelta = widget.spesaIniziale!['localita'];
      _tassoAnteprima =
          (widget.spesaIniziale!['tasso_cambio'] as num).toDouble();
    }
    _spesaController.addListener(() => setState(() {}));
  }

  // Funzione per recuperare il tasso di cambio reale da internet[cite: 5]
  Future<double> _getExchangeRate(String from, String to) async {
    if (from == to) return 1.0;
    try {
      // Chiamata all'API di cambio valuta[cite: 5]
      final url = Uri.parse('https://open.er-api.com/v6/latest/$from');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // L'API restituisce i tassi rispetto alla valuta base (to)[cite: 5]
        return (data['rates'][to] as num).toDouble();
      }
    } catch (e) {
//      print("Errore durante il recupero del tasso: $e");
    }
    return 0.0; // Restituisce 0 in caso di errore[cite: 5]
  }

  Future<void> _caricaDatiEvento() async {
    try {
      // 1. Leggiamo i dati necessari dalla tabella 'eventi'
      final eventoData = await _supabase
          .from('eventi')
          .select('localita, valuta_origine, valuta_target')
          .eq('id', widget.eventoId)
          .single();

      // 2. Leggiamo TUTTE le località possibili
      final localitaData = await _supabase
          .from('localita')
          .select('localita')
          .eq('evento_id', widget.eventoId);

      // 3. Leggiamo le valute
      final valuteData = await _supabase
          .from('valute')
          .select('valuta')
          .eq('evento_id', widget.eventoId);

      setState(() {
        // Popoliamo la lista del menu a tendina
        _listaLocalita = (localitaData as List)
            .map((l) => l['localita'].toString())
            .toList();

        _listaValute =
            (valuteData as List).map((v) => v['valuta'].toString()).toList();

        // Sempre aggiornata, sia in insert che in update
        if (eventoData['valuta_target'] != null) {
          _valutaTarget = eventoData['valuta_target'];
        }

        // Gestione NUOVA spesa
        if (widget.spesaIniziale == null) {
          if (eventoData['localita'] != null) {
            _localitaScelta = eventoData['localita'].toString();
          } else if (_listaLocalita.isNotEmpty) {
            _localitaScelta = _listaLocalita.first;
          }

          if (eventoData['valuta_origine'] != null) {
            _valutaScelta = eventoData['valuta_origine'];
          }
        }
      });

      // Ora che sappiamo la valuta scelta e quella target, scarichiamo il tasso reale
      if (_valutaScelta != _valutaTarget) {
        double tassoIniziale =
            await _getExchangeRate(_valutaScelta, _valutaTarget);
        if (tassoIniziale > 0) {
          setState(() {
            _tassoAnteprima = tassoIniziale;
          });
        }
      }

      // ---------------------------------
    } catch (e) {
 //     print("Errore caricamento dati: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppWidgets.appBar(
        leftWidget: null,
        titleWidget: Text(
          widget.spesaIniziale == null ? "Nuova Spesa" : "Modifica Spesa",
        ),
        rightWidget: null,
      ),
 
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B2FF)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LOCALITÀ
                    AppWidgets.dropdownField(
                      label: "Località",
                      value: _localitaScelta,
                      options: _listaLocalita,
                      icon: Icons.place,
                      onChanged: (v) => setState(() => _localitaScelta = v),
                    ),
                    const SizedBox(height: 20),

                    // DATA
                    AppWidgets.dateField(
                      label: "Data",
                      date: _dataSelezionata,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dataSelezionata,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() => _dataSelezionata = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // VALUTA
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LABEL
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "Valuta",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // BOTTONI VALUTA
                        Row(
                          children: _listaValute.map((v) {
                            final bool isSelected = _valutaScelta == v;

                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected
                                        ? const Color(0xFF1E3A5F)
                                        : Colors.white,
                                    foregroundColor: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    setState(() => _valutaScelta = v);

                                    double nuovoTasso = await _getExchangeRate(
                                        _valutaScelta, _valutaTarget);

                                    setState(() {
                                      _tassoAnteprima =
                                          nuovoTasso > 0 ? nuovoTasso : 1.0;
                                    });
                                  },
                                  child: Text(
                                    v,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // SPESA
                    AppWidgets.inputField(
                      label: "Spesa",
                      controller: _spesaController,
                      icon: Icons.euro,
                     keyboardType:
                           const TextInputType.numberWithOptions(decimal: true, signed: true),
                    ),

                    // ANTEPRIMA COSTO
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline,
                              size: 14, color: Color(0xFF00B2FF)),
                          const SizedBox(width: 5),
                          Builder(builder: (context) {
                            final double? spesaInserita = double.tryParse(
                              _spesaController.text.replaceAll(',', '.'),
                            );
                            final double anteprima = (spesaInserita ?? 0) *
                                (_tassoAnteprima > 0 ? _tassoAnteprima : 1.0);

                            return Text(
                              "Costo stimato: ${anteprima.toStringAsFixed(2)} $_valutaTarget",
                              style: const TextStyle(
                                color: Color(0xFF00B2FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TIPOLOGIA
                    AppWidgets.dropdownField(
                      label: "Tipologia",
                      value: _tipologiaScelta,
                      options: _listaTipologie,
                      icon: Icons.category,
                      onChanged: (v) => setState(() => _tipologiaScelta = v),
                    ),
                    const SizedBox(height: 20),

                    // CAUSALE
                    AppWidgets.inputField(
                      label: "Causale",
                      controller: _causaleController,
                      icon: Icons.edit,
                     maxLines: 3,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

      // Bottom Bar
      bottomNavigationBar: AppWidgets.actionBar(
        actions: [
          AppWidgets.actionButton(
            icon: Icons.arrow_back,
            label: "Annulla",
            onTap: () => Navigator.pop(context),
          ),
          AppWidgets.actionButton(
            icon: Icons.save,
            label: "Salva",
            onTap: _salvaSpesa,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text,
          style: const TextStyle(
              color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  void _salvaSpesa() async {
    if (_formKey.currentState!.validate()) {
      final double? spesaInput =
          double.tryParse(_spesaController.text.replaceAll(',', '.'));
      if (spesaInput == null) return;

      setState(() => _isLoading =
          true); // Avvia caricamento durante la ricerca internet[cite: 5]

      // Ricerca del tasso di cambio reale su internet[cite: 5]
      double tassoReale = await _getExchangeRate(_valutaScelta, _valutaTarget);

      if (tassoReale == 0.0) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text("Errore: Impossibile recuperare il tasso di cambio.")),
          );
        }
        return;
      }

      // Calcolo basato sul tasso reale: Spesa * Tasso = Importo locale[cite: 5]
      double importoCalcolato = spesaInput * tassoReale;

      final dataSpesa = {
        'gruppo_id': widget.gruppoId,
        'evento_id': widget.eventoId,
        'data': _dataSelezionata.toIso8601String(),
        'localita': _localitaScelta,
        'valuta_origine': _valutaScelta,
        'importo': double.parse(importoCalcolato.toStringAsFixed(2)),
        'tipologia': _tipologiaScelta,
        'causale': _causaleController.text,
        'valuta_target': _valutaTarget,
        'tasso_cambio': tassoReale,
        'spesa': spesaInput,
      };

      try {
        if (widget.spesaIniziale == null) {
          await _supabase.from('spese').insert(dataSpesa);
        } else {
          await _supabase
              .from('spese')
              .update(dataSpesa)
              .eq('id', widget.spesaIniziale!['id']);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Errore durante il salvataggio: $e")),
          );
        }
      }
    }
  }
}
