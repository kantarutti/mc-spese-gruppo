import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/app_widgets.dart';
import '../../widgets/evento_card.dart';

class GirocontiEditTab extends StatefulWidget {
  final dynamic eventoId;
  final Map<String, dynamic>? giroconto;

  const GirocontiEditTab({
    super.key,
    required this.eventoId,
    this.giroconto,
  });

  @override
  State<GirocontiEditTab> createState() => _GirocontiEditPageState();
}

class _GirocontiEditPageState extends State<GirocontiEditTab> {
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
  List<String> _opzioniValuta = [];

  bool _isLoading = true;

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

    final valuteRes = await _supabase
        .from('valute')
        .select('valuta')
        .eq('evento_id', widget.eventoId);

    setState(() {
      _gruppi = List<Map<String, dynamic>>.from(gruppiRes);
      _valutaTarget = eventoRes['valuta_target'] ?? 'EUR';

      _opzioniValuta =
          valuteRes.map<String>((v) => v['valuta'].toString()).toList();

      if (_opzioniValuta.isEmpty) _opzioniValuta = ['EUR'];

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
      final res = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/$_valutaOrigine'),
      );

      if (res.statusCode == 200) {
        setState(() {
          _tassoCambio =
              (jsonDecode(res.body)['rates'][_valutaTarget] ?? 1.0).toDouble();
          _aggiornaCalcolo();
        });
      }
    } catch (_) {}
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppWidgets.appBar(
        leftWidget: null,
        titleWidget: Text(
          widget.giroconto == null ? 'nuovo_giroconto'.tr() : 'modifica_giroconto'.tr(),
        ),
        rightWidget: null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DA
              AppWidgets.dropdownField(
                label: 'da'.tr(),
                value: _daGruppoId == null
                    ? null
                    : _gruppi
                        .firstWhere((g) => g['id'] == _daGruppoId)['gruppo'],
                options: _gruppi.map((g) => g['gruppo'].toString()).toList(),
                icon: Icons.group,
                onChanged: (nomeGruppo) {
                  final id = _gruppi
                      .firstWhere((g) => g['gruppo'] == nomeGruppo)['id'];
                  setState(() => _daGruppoId = id);
                },
              ),

              const SizedBox(height: 20),

              // A
              AppWidgets.dropdownField(
                label: 'a'.tr(),
                value: _aGruppoId == null
                    ? null
                    : _gruppi
                        .firstWhere((g) => g['id'] == _aGruppoId)['gruppo'],
                options: _gruppi.map((g) => g['gruppo'].toString()).toList(),
                icon: Icons.group,
                onChanged: (nomeGruppo) {
                  final id = _gruppi
                      .firstWhere((g) => g['gruppo'] == nomeGruppo)['id'];
                  setState(() => _aGruppoId = id);
                },
              ),

              const SizedBox(height: 20),

              // DATA
              AppWidgets.dateField(
                label: 'col_data'.tr(),
                date: _selectedData,
                onTap: _pickData,
              ),
              const SizedBox(height: 20),

              // VALUTA
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'valuta'.tr(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Row(
                children: _opzioniValuta.map((v) {
                  final bool isSelected = _valutaOrigine == v;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _valutaOrigine = v);
                          _fetchExchangeRate();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1E3A5F)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF00B2FF)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              v,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // IMPORTO
              AppWidgets.inputField(
                label: 'importo'.tr(),
                controller: _importoController,
                icon: Icons.euro,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _aggiornaCalcolo(),
              ),

              // COSTO STIMATO
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 20, color: Color(0xFF1E3A5F)),
                    const SizedBox(width: 8),
                    Text(
                      "${'giroconto_stimato'.tr()}: ${_risultatoConvertito.toStringAsFixed(2)} $_valutaTarget",
                      style: const TextStyle(
                        color: Color(0xFF00B2FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppWidgets.actionBar(
        actions: [
          AppWidgets.actionButton(
            icon: Icons.arrow_back,
            label: 'annulla'.tr(),
            onTap: () => Navigator.pop(context),
          ),
          AppWidgets.actionButton(
            icon: Icons.save,
            label: 'salva'.tr(),
            onTap: _salva,
          ),
        ],
      ),
    );
  }

  Future<void> _pickData() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedData,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

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