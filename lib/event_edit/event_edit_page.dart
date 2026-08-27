import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_widgets.dart';
import '../services/event_service.dart';
import '../widgets/event_widgets.dart';

import 'localita_page.dart';
import 'valute_page.dart';
import 'gruppi_page.dart';

class EventEditPage extends StatefulWidget {
  final Map<String, dynamic> evento;

  const EventEditPage({
    super.key,
    required this.evento,
  });

  @override
  State<EventEditPage> createState() => EventEditPageState();
}

class EventEditPageState extends State<EventEditPage> {
  final supabase = Supabase.instance.client;

  late TextEditingController nomeController;

  String? tipoEvento;
  DateTime? dataInizio;
  DateTime? dataFine;

  List<String> localitaDisponibili = [];
  String? localitaSelezionata;

  String? valutaOrigine;
  String? valutaTarget;
  List<String> valuteDisponibili = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    nomeController = TextEditingController(text: widget.evento['nome'] ?? '');
    tipoEvento = widget.evento['tipo_evento'];

    dataInizio = _parseDate(widget.evento['data_inizio']);
    dataFine = _parseDate(widget.evento['data_fine']);

    valutaOrigine = widget.evento['valuta_origine'];
    valutaTarget = widget.evento['valuta_target'];

    _caricaDatiEvento();
  }

  Future<void> _caricaDatiEvento() async {
    await Future.wait([
      _loadLocalita(),
      _loadValute(),
    ]);

    setState(() => loading = false);
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadLocalita() async {
    final data = await supabase
        .from('localita')
        .select()
        .eq('evento_id', widget.evento['id'])
        .order('localita');

    localitaDisponibili =
        List<String>.from(data.map((e) => e['localita'].toString()));

    localitaSelezionata = widget.evento['localita'];
  }

  Future<void> _loadValute() async {
    final data = await supabase
        .from('valute')
        .select()
        .eq('evento_id', widget.evento['id'])
        .order('valuta');

    valuteDisponibili =
        List<String>.from(data.map((e) => e['valuta'].toString()));
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? dataInizio : dataFine;
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          // 1️⃣ Calcolo intervallo attuale (se esiste)
          int? intervallo;
          if (dataInizio != null && dataFine != null) {
            intervallo = dataFine!.difference(dataInizio!).inDays;
          }

          // 2️⃣ Imposto la nuova data inizio
          dataInizio = picked;

          // 3️⃣ Se non ho data fine → copio la data inizio
          if (dataFine == null) {
            dataFine = picked;
            return;
          }

          // 4️⃣ Se ho un intervallo valido → applico l’intervallo PRIMA
          if (intervallo != null && intervallo >= 0) {
            dataFine = picked.add(Duration(days: intervallo));
            return;
          }

          // 5️⃣ Se arrivo qui, significa che non c’è intervallo valido
          //    quindi garantisco almeno che dataFine >= dataInizio
          if (dataFine!.isBefore(picked)) {
            dataFine = picked;
          }
        } else {
          // 6️⃣ Validazione: data fine NON può essere prima della data inizio
          if (dataInizio != null && picked.isBefore(dataInizio!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    "La data fine non può essere precedente alla data inizio"),
              ),
            );
            return;
          }

          // 7️⃣ Imposto la data fine valida
          dataFine = picked;
        }
      });
    }
  }

  Future<void> salva() async {
    final service = EventService();

    await service.salvaEvento(
      eventoId: widget.evento['id'],
      nome: nomeController.text.trim(),
      tipoEvento: tipoEvento,
      localita: localitaSelezionata,
      dataInizio: dataInizio,
      dataFine: dataFine,
      valutaOrigine: valutaOrigine,
      valutaTarget: valutaTarget,
      organizzatore: widget.evento['organizzatore'],
    );

    if (!mounted) return;

//    ScaffoldMessenger.of(context).showSnackBar(
//      const SnackBar(content: Text("Evento salvato con successo")),
//    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppWidgets.appBar(
        leftWidget: null,
        titleWidget: const Text(
          "Gestione Evento",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        rightWidget: null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NOME EVENTO
            EventWidgets.inputField(
              label: "Nome",
              controller: nomeController,
              icon: Icons.event,
              onChanged: (_) => salva(),
            ),
            const SizedBox(height: 20),

            // TIPO EVENTO
            EventWidgets.dropdownField(
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
                salva(); // ⭐ salvataggio automatico
              },
              icon: Icons.category,
            ),
            const SizedBox(height: 20),

            // LOCALITÀ
            EventWidgets.dropdownField(
              label: "Località",
              value: localitaSelezionata,
              options: localitaDisponibili,

              onChanged: (v) {
                setState(() => localitaSelezionata = v);
                salva(); // ⭐ salvataggio automatico
              },
              icon: Icons.place,

              //            onChanged: (v) => setState(() => localitaSelezionata = v),
              //            icon: Icons.place,
            ),
            const SizedBox(height: 20),

            // DATE
            Row(
              children: [
                Expanded(
                  child: EventWidgets.dateField(
                    label: "Data Inizio",
                    date: dataInizio,
                    onTap: () async {
                      await _pickDate(isStart: true);
                      salva(); // ⭐ salvataggio automatico
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EventWidgets.dateField(
                    label: "Data Fine",
                    date: dataFine,
                    onTap: () async {
                      await _pickDate(isStart: false);
                      salva(); // ⭐ salvataggio automatico
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // VALUTE
            Row(
              children: [
                Expanded(
                  child: EventWidgets.valutaField(
                    label: "Valuta Spese",
                    value: valutaOrigine,
                    options: valuteDisponibili,
                    onChanged: (v) {
                      setState(() => valutaOrigine = v);
                      salva(); // ⭐ salvataggio automatico
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EventWidgets.valutaField(
                    label: "Valuta Conteggi",
                    value: valutaTarget,
                    options: valuteDisponibili,
                    onChanged: (v) {
                      setState(() => valutaTarget = v);
                      salva(); // ⭐ salvataggio automatico
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // CAMPI STATICI
            EventWidgets.readOnlyField(
              label: "Stato",
              value: widget.evento['stato'] ?? "N/D",
              icon: Icons.flag,
            ),
            const SizedBox(height: 30),

            // 🔥 PULSANTI SECONDARI (Località / Valute / Gruppi)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildActionChip(
                      icon: Icons.map,
                      label: 'Località',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LocalitaPage(eventoId: widget.evento['id']),
                          ),
                        );
                        await _loadLocalita();
                        setState(() {});
                      },
                    ),
                    _buildActionChip(
                      icon: Icons.currency_exchange,
                      label: 'Valute',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ValutePage(eventoId: widget.evento['id']),
                          ),
                        );
                        await _loadValute();
                        setState(() {});
                      },
                    ),
                    _buildActionChip(
                      icon: Icons.group_work,
                      label: 'Teams',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                GruppiPage(eventoId: widget.evento['id']),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppWidgets.actionBar(
        actions: [
          AppWidgets.actionButton(
            icon: Icons.arrow_back,
            label: "Indietro",
            onTap: () => Navigator.pop(context, true),
          ),
          AppWidgets.actionButton(
            icon: Icons.delete,
            label: "Cancella",
            onTap: () async {
              final conferma = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Conferma"),
                  content: const Text("Vuoi davvero cancellare questo evento?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Annulla"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Cancella"),
                    ),
                  ],
                ),
              );

              if (conferma == true) {
                try {
                  await supabase.rpc(
                    'delete_evento', // <-- NOME DELLA FUNZIONE IN SUPABASE
                    params: {'event_id': widget.evento['id']},
                  );

                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home', // <-- rotta della tua HomePage
                      (route) => false,
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Errore cancellazione evento: $e")),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    const Color azzurroIntenso = Color(0xFF00B2FF);

    return ActionChip(
      avatar: Icon(icon, size: 20, color: azzurroIntenso),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      onPressed: onTap,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: azzurroIntenso),
      ),
    );
  }
}
