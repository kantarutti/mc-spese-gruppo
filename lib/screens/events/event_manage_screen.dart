import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/evento.dart';
import '../../providers/evento_detail_provider.dart';

class EventManageScreen extends ConsumerStatefulWidget {
  final String eventoId;

  const EventManageScreen({super.key, required this.eventoId});

  @override
  ConsumerState<EventManageScreen> createState() => _EventManageScreenState();
}

class _EventManageScreenState extends ConsumerState<EventManageScreen> {
  static const Color azzurroIntenso = Color(0xFF00B2FF);

  late TextEditingController _nomeController;
  late TextEditingController _localitaController;
  late TextEditingController _dataInizioController;
  late TextEditingController _dataFineController;
  late TextEditingController _organizzatoreController;
  late TextEditingController _personeController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _localitaController = TextEditingController();
    _dataInizioController = TextEditingController();
    _dataFineController = TextEditingController();
    _organizzatoreController = TextEditingController();
    _personeController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _localitaController.dispose();
    _dataInizioController.dispose();
    _dataFineController.dispose();
    _organizzatoreController.dispose();
    _personeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _salvaEvento(Evento evento) async {
    try {
      // Converte le date da stringa a DateTime
      DateTime? dataInizio;
      DateTime? dataFine;
      
      if (_dataInizioController.text.isNotEmpty) {
        dataInizio = DateFormat('dd/MM/yyyy').parse(_dataInizioController.text);
      }
      if (_dataFineController.text.isNotEmpty) {
        dataFine = DateFormat('dd/MM/yyyy').parse(_dataFineController.text);
      }

      final params = UpdateEventParams(
        id: widget.eventoId,
        nome: _nomeController.text,
        localita: _localitaController.text,
        dataInizio: dataInizio,
        dataFine: dataFine,
        organizzatore: _organizzatoreController.text,
        persone: int.tryParse(_personeController.text) ?? 0,
      );

      await ref.read(updateEventProvider(params).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento salvato!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventoAsync = ref.watch(eventoDetailProvider(widget.eventoId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dettaglio Evento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: azzurroIntenso,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: eventoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Errore: $error'),
        ),
        data: (evento) {
          // Popola i controller al primo caricamento
          if (_nomeController.text.isEmpty) {
            _nomeController.text = evento.nome;
            _localitaController.text = evento.localita ?? '';
            _dataInizioController.text = evento.dataInizio != null
                ? DateFormat('dd/MM/yyyy').format(evento.dataInizio!)
                : '';
            _dataFineController.text = evento.dataFine != null
                ? DateFormat('dd/MM/yyyy').format(evento.dataFine!)
                : '';
            _organizzatoreController.text = evento.organizzatore ?? '';
            _personeController.text = evento.persone.toString();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titolo evento
                Center(
                  child: Text(
                    evento.nome,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: azzurroIntenso,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // Nome Evento
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Evento',
                    prefixIcon: Icon(Icons.event, color: azzurroIntenso),
                  ),
                ),
                const SizedBox(height: 16),

                // Tipo Evento
                TextField(
                  enabled: false,
                  controller: TextEditingController(text: evento.tipoEvento),
                  decoration: const InputDecoration(
                    labelText: 'Tipo Evento',
                    prefixIcon: Icon(Icons.flight, color: azzurroIntenso),
                  ),
                ),
                const SizedBox(height: 16),

                // Localita
                TextField(
                  controller: _localitaController,
                  decoration: const InputDecoration(
                    labelText: 'Località',
                    prefixIcon: Icon(Icons.location_on, color: azzurroIntenso),
                  ),
                ),
                const SizedBox(height: 16),

                // Data Inizio
                TextField(
                  controller: _dataInizioController,
                  readOnly: true,
                  onTap: () => _selectDate(context, _dataInizioController),
                  decoration: const InputDecoration(
                    labelText: 'Data Inizio',
                    prefixIcon: Icon(Icons.calendar_today, color: azzurroIntenso),
                  ),
                ),
                const SizedBox(height: 16),

                // Data Fine
                TextField(
                  controller: _dataFineController,
                  readOnly: true,
                  onTap: () => _selectDate(context, _dataFineController),
                  decoration: const InputDecoration(
                    labelText: 'Data Fine',
                    prefixIcon: Icon(Icons.calendar_today, color: azzurroIntenso),
                  ),
                ),
                const SizedBox(height: 16),

                // Organizzatore
                TextField(
                  controller: _organizzatoreController,
                  decoration: const InputDecoration(
                    labelText: 'Organizzatore',
                    prefixIcon: Icon(Icons.person, color: azzurroIntenso),
                  ),
                ),
                const SizedBox(height: 16),

                // Numero Persone
                TextField(
                  controller: _personeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Numero Persone',
                    prefixIcon: Icon(Icons.group, color: azzurroIntenso),
                  ),
                ),
                const SizedBox(height: 16),

                // Stato
                TextField(
                  enabled: false,
                  controller: TextEditingController(text: evento.stato),
                  decoration: const InputDecoration(
                    labelText: 'Stato',
                    prefixIcon: Icon(Icons.info, color: azzurroIntenso),
                  ),
                ),
                const SizedBox(height: 32),

                // Spesa Totale (read-only)
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Spesa Totale',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${evento.totaleSpesa.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Pulsante Salva
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _salvaEvento(evento),
                    child: const Text(
                      'SALVA EVENTO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: azzurroIntenso,
        onPressed: () {
          // TODO: Navigare a SpeseScreen
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
