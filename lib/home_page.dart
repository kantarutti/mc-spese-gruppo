import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'event_edit/event_edit_page.dart';
import 'event_view/event_view_shell.dart';
import 'user/login_page.dart';
import 'user/profile_page.dart';

import 'config/app_colors.dart';
import 'config/app_widgets.dart';
import 'navigation/route_observer.dart';


  // ------------------------------------------------------------
  // 1️⃣ CLASSI
  // ------------------------------------------------------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {

  // ------------------------------------------------------------
  // 1️⃣ VARIABILI E CONTROLLER
  // ------------------------------------------------------------

  final _supabase = Supabase.instance.client;

  final Map<String, int> _prioritaStato = {
    'Preparazione': 1,
    'In Corso': 2,
    'Concluso': 3,
    'Chiuso': 4,
  };

  final TextEditingController _nomeNuovoEventoController =
      TextEditingController();

  String _tipoSelezionato = 'Viaggio';

  final Map<String, IconData> _tipiEvento = {
    'Viaggio': Icons.flight,
    'Gita': Icons.directions_car,
    'Evento': Icons.event,
    'Pranzo - Cena': Icons.restaurant,
    'Festa': Icons.celebration,
    'Regalo': Icons.redeem,
  };

  late Stream<List<Map<String, dynamic>>> _eventsStream =
      Stream.value([]); // stream vuoto iniziale


  // ------------------------------------------------------------
  // 2️⃣ METODI DEL CICLO DI VITA
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    Future.microtask(() {
      setState(() {
        _eventsStream = _supabase
            .from('eventi_con_stato')
            .stream(primaryKey: ['id'])
            .order('data_inizio', ascending: false);
      });
    });
  }


  // ------------------------------------------------------------
  // 3️⃣ METODI PERSONALIZZATI
  // ------------------------------------------------------------

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCell = prefs.getString('cellulare');

    if (savedCell == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    _eventsStream = _supabase
        .from('eventi_visibili')
        .stream(primaryKey: ['id'])
        .eq('persona_cellulare', savedCell)
        .order('data_inizio', ascending: false);

    setState(() {});
  }

  String _formattaDate(dynamic inizio, dynamic fine) {
    if (inizio == null) return "Data non definita";

    final df = DateFormat('dd/MM/yyyy');

    try {
      final dataIniz = df.format(DateTime.parse(inizio.toString()));
      if (fine == null) return dataIniz;

      final dataFine = df.format(DateTime.parse(fine.toString()));
      if (dataIniz == dataFine) return dataIniz;

      return "$dataIniz - $dataFine";
    } catch (_) {
      return inizio.toString();
    }
  }

  void _mostraPopupCreazione() {
    _nomeNuovoEventoController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Nuovo Evento',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomeNuovoEventoController,
                decoration: const InputDecoration(
                  labelText: 'Nome dell\'evento',
                  hintText: 'es. Weekend a Roma',
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _tipoSelezionato,
                decoration: const InputDecoration(labelText: 'Tipo di evento'),
                items: _tipiEvento.keys.map((String tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Row(
                      children: [
                        Icon(_tipiEvento[tipo],
                            color: AppColors.secondaryColor, size: 20),
                        const SizedBox(width: 10),
                        Text(tipo),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => _tipoSelezionato = val);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ANNULLA'),
            ),
            ElevatedButton(
              onPressed: _creaEventoEApriManage,
              child: const Text('CREA'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _creaEventoEApriManage() async {
    if (_nomeNuovoEventoController.text.isEmpty) return;

    try {
      final insertResult = await _supabase
          .from('eventi')
          .insert({
            'nome': _nomeNuovoEventoController.text,
            'tipo_evento': _tipoSelezionato,
            'organizzatore_id': _supabase.auth.currentUser!.id,
          })
          .select()
          .single();

      final eventoId = insertResult['id'];

      final eventoCompleto =
          await _supabase.from('eventi').select().eq('id', eventoId).single();

      if (mounted) {
Navigator.pop(context);

final refresh = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => EventEditPage(evento: eventoCompleto),
  ),
);

if (refresh == true) {
  _loadEvents();
}

      }
    } catch (e) {
      debugPrint("Errore creazione evento: $e");
    }
  }


  // ------------------------------------------------------------
  // 4️⃣ BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidgets.appBar(
        leftWidget: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
        titleWidget: const Text(
          'I Miei Eventi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        rightWidget: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () async {
            await _supabase.auth.signOut();
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.logout, color: Colors.white),
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Errore: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final eventi = snapshot.data!;

          eventi.sort((a, b) {
            final statoA = a['stato'] ?? '';
            final statoB = b['stato'] ?? '';

            final prioA = _prioritaStato[statoA] ?? 999;
            final prioB = _prioritaStato[statoB] ?? 999;

            if (prioA != prioB) return prioA.compareTo(prioB);

            final dataA =
                DateTime.tryParse(a['data_inizio'] ?? '') ?? DateTime(2100);
            final dataB =
                DateTime.tryParse(b['data_inizio'] ?? '') ?? DateTime(2100);

            return dataA.compareTo(dataB);
          });

          if (eventi.isEmpty) {
            return const Center(child: Text("Nessun evento creato."));
          }

          return ListView.builder(
            itemCount: eventi.length,
            itemBuilder: (context, index) {
              final ev = eventi[index];

              return AppWidgets.eventCard(
                titolo: ev['nome'] ?? 'Senza nome',
                dateRange: _formattaDate(ev['data_inizio'], ev['data_fine']),
                luogo: ev['localita'] ?? 'Località N/D',
                stato: ev['stato'] ?? 'Sconosciuto',
                icon: _tipiEvento[ev['tipo_evento']] ?? Icons.event,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventViewShell(eventoId: ev['id']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: AppWidgets.actionBar(
        actions: [
          AppWidgets.actionButton(
            icon: Icons.power_input, 
            label: "",
                 onTap: () {},
          ),
             AppWidgets.actionButton(
            icon: Icons.add,
            label: "Nuovo Evento",
            onTap: _mostraPopupCreazione,
          ),
        ],
      ),
    );
  }
}
