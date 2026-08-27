import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_widgets.dart';

class GirocontiEditTab extends StatefulWidget {
  final dynamic eventoId;
  final Map<String, dynamic>? giroconto;

  const GirocontiEditTab({super.key, required this.eventoId, this.giroconto});

  @override
  State<GirocontiEditTab> createState() => _GirocontoEditPageState();
}

class _GirocontoEditPageState extends State<GirocontiEditTab> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final _importoController = TextEditingController();
  final _dataController = TextEditingController();

  DateTime _selectedData = DateTime.now();
  dynamic _daGruppoId;
  dynamic _aGruppoId;
  String _valutaOrigine = 'EUR';
  String _valutaTarget = 'EUR';
  double _tassoCambio = 1.0;
  double _risultatoConvertito = 0.0;
  List<Map<String, dynamic>> _gruppi = [];
  bool _isLoading = true;

  // ⭐ VALUTE DINAMICHE
  List<String> _opzioniValuta = [];

  @override
  void initState() {
    super.initState();
    _inizializzaDati();
  }

  Future<void> _inizializzaDati() async {
    final gruppiRes = await _supabase
        .from('gruppi')
        .select('id, gruppo')
        .eq('evento_id', widget.eventoId)
        .order('gruppo');

    final eventoRes = await _supabase
        .from('eventi')
        .select('valuta_target')
        .eq('id', widget.eventoId)
        .single();

    // ⭐ PRENDO LE VALUTE PER QUESTO EVENTO
    final valuteRes = await _supabase
        .from('valute')
        .select('valuta')
        .eq('evento_id', widget.eventoId);

    setState(() {
      _gruppi = List<Map<String, dynamic>>.from(gruppiRes);
      _valutaTarget = eventoRes['valuta_target'] ?? 'EUR';

      // ⭐ LISTA VALUTE DINAMICA
      _opzioniValuta =
          valuteRes.map<String>((v) => v['valuta'].toString()).toList();

      if (_opzioniValuta.isEmpty) {
        _opzioniValuta = ['EUR']; // fallback di sicurezza
      }

      if (widget.giroconto != null) {
        final g = widget.giroconto!;
        _daGruppoId = g['da_gruppo_id'];
        _aGruppoId = g['a_gruppo_id'];
        _selectedData = DateTime.parse(g['data_giroconto']);
        _valutaOrigine = g['valuta_origine'] ?? _valutaTarget;
        _tassoCambio = (g['tasso_cambio'] ?? 1.0).toDouble();
        _importoController.text = g['importo'].toString();
        _risultatoConvertito = (g['giroconto'] ?? 0).toDouble();
      } else {
        _valutaOrigine = _valutaTarget;
      }

      _dataController.text = DateFormat('dd/MM/yyyy').format(_selectedData);
      _isLoading = false;
    });

    if (widget.giroconto == null) _fetchExchangeRate();
  }

  Future<void> _fetchExchangeRate() async {
    if (_valutaOrigine == _valutaTarget) {
      setState(() {
        _tassoCambio = 1.0;
        _aggiornaCalcolo();
      });
      return;
    }
    try {
      final res = await http.get(Uri.parse(
          'https://api.exchangerate-api.com/v4/latest/$_valutaOrigine'));
      if (res.statusCode == 200) {
        setState(() {
          _tassoCambio =
              (jsonDecode(res.body)['rates'][_valutaTarget] ?? 1.0).toDouble();
          _aggiornaCalcolo();
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _aggiornaCalcolo() {
    final double imp =
        double.tryParse(_importoController.text.replaceAll(',', '.')) ?? 0;
    setState(() {
      _risultatoConvertito = imp * _tassoCambio;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppWidgets.appBar(
        leftWidget: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        titleWidget: Text(
          widget.giroconto == null ? "Nuovo Giroconto" : "Modifica Giroconto",
        ),
        rightWidget: const SizedBox(width: 40),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildLabel("Da"),
                  _buildRoundedDropdown(
                      _daGruppoId, (val) => setState(() => _daGruppoId = val)),
                  const SizedBox(height: 20),
                  _buildLabel("A"),
                  _buildRoundedDropdown(
                      _aGruppoId, (val) => setState(() => _aGruppoId = val)),
                  const SizedBox(height: 20),
                  _buildLabel("Data *"),
                  _buildRoundedTextField(
                    controller: _dataController,
                    readOnly: true,
                    suffixIcon: const Icon(Icons.calendar_month_outlined),
                    onTap: _pickData,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Valuta *"),
                  Row(
                    children: _opzioniValuta.map((v) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _buildValutaButton(v),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Importo *"),
                  _buildRoundedTextField(
                    controller: _importoController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (_) => _aggiornaCalcolo(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 20, color: Color(0xFF1E3A5F)),
                        const SizedBox(width: 8),
                        Text(
                          "Giroconto stimato: ${_risultatoConvertito.toStringAsFixed(2)} $_valutaTarget",
                          style: const TextStyle(
                            color: Color(0xFF00B2FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppWidgets.actionBar(
        actions: [
          AppWidgets.actionButton(
            icon: Icons.close,
            label: "Annulla",
            onTap: () => Navigator.pop(context),
          ),
          AppWidgets.actionButton(
            icon: Icons.save,
            label: "Salva",
            onTap: _salva,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.bold)),
      );

  Widget _buildRoundedTextField({
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    TextAlign textAlign = TextAlign.start,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textAlign: textAlign,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        fillColor: const Color(0xFFF5F5F5),
        filled: true,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  Widget _buildRoundedDropdown(dynamic value, Function(dynamic) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          style: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          items: _gruppi
              .map((g) => DropdownMenuItem(
                  value: g['id'],
                  child: Text(g['gruppo'],
                      style: const TextStyle(fontWeight: FontWeight.bold))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildValutaButton(String valuta) {
    bool isSelected = _valutaOrigine == valuta;
    return GestureDetector(
      onTap: () {
        setState(() => _valutaOrigine = valuta);
        _fetchExchangeRate();
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A5F) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color:
                  isSelected ? const Color(0xFF00B2FF) : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(valuta,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Future<void> _pickData() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedData,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        _selectedData = picked;
        _dataController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _salva() async {
    if (_daGruppoId == null ||
        _aGruppoId == null ||
        _importoController.text.isEmpty) return;

    final data = {
      'evento_id': widget.eventoId,
      'da_gruppo_id': _daGruppoId,
      'a_gruppo_id': _aGruppoId,
      'data_giroconto': _selectedData.toIso8601String(),
      'valuta_origine': _valutaOrigine,
      'importo': double.parse(_importoController.text.replaceAll(',', '.')),
      'valuta_target': _valutaTarget,
      'tasso_cambio': _tassoCambio,
      'giroconto': _risultatoConvertito,
    };

    if (widget.giroconto == null) {
      await _supabase.from('giroconti').insert(data);
    } else {
      await _supabase
          .from('giroconti')
          .update(data)
          .eq('id', widget.giroconto!['id']);
    }
    if (mounted) Navigator.pop(context);
  }
}
