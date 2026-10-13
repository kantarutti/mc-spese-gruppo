import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'event_edit/evento_edit_page.dart';
import 'event_view/evento_view_shell.dart'; // ⭐ IMPORT RIPRISTINATO
import 'user/login_page.dart';
import 'user/profile_page.dart';

import '../config/app_colors.dart';
import '../config/app_widgets.dart';
import '../navigation/route_observer.dart';
import '../widgets/evento_card.dart';

// ⭐ IMPORT PER IL TUTORIAL
import '../../services/tutorial_service.dart';
import '../../services/message_builder.dart';
import '../../widgets/bubble_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
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

  late Stream<List<Map<String, dynamic>>> _eventsStream = Stream.value([]);

  // ⭐ VARIABILE PER IL TUTORIAL
  bool showTutorial = true;

  @override
  void initState() {
    super.initState();

    // ⭐ CARICO IL TUTORIAL
    Future.microtask(() async {
      showTutorial = await TutorialService.shouldShow("tutorial_home");
      setState(() {});
    });

    _loadEvents();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _nomeNuovoEventoController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
//    Future.microtask(() {
    setState(() {
      _eventsStream = _supabase
          .from('eventi_con_stato')
          .stream(primaryKey: ['id']).order('data_inizio', ascending: false);
    });
//    });
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCell = prefs.getString('cellulare');

    if (savedCell == null) {
      if (!mounted) return;
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
      final prefs = await SharedPreferences.getInstance();
      final utenteId = prefs.getString('utente_id');

      final insertResult = await _supabase
          .from('eventi')
          .insert({
            'nome': _nomeNuovoEventoController.text,
            'tipo_evento': _tipoSelezionato,
            'amministratore_id': utenteId,
          })
          .select()
          .single();

      final eventoId = insertResult['id'];

      if (mounted) {
        Navigator.pop(context);

        final refresh = await Navigator.push(
          context,
          MaterialPageRoute(
            // Alla creazione di un nuovo evento, solitamente vuoi configurarlo subito (quindi Edit)
            // Se preferisci la shell, puoi cambiare qui con EventViewShell(eventoId: eventoId)
            builder: (_) => EventoEditPage(eventoId: eventoId),
          ),
        );

        if (refresh == true) {
          _loadEvents();
        }
      }
    } catch (e) {
      debugPrint("Errore creazione attività: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppWidgets.appBar(
            leftWidget: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () async {
                // ⭐ Aspettiamo il ritorno dalla pagina profilo e aggiorniamo lo stato
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
                if (mounted) {
                  setState(
                      () {}); // ⭐ Forza il rebuild immediato con la nuova lingua
                }
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
            titleWidget: Text(
              'le_mie_attivita'.tr(),
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
                return const Center(child: Text("Nessun attività creata"));
              }

              return ListView.builder(
                itemCount: eventi.length,
                itemBuilder: (context, index) {
                  final ev = eventi[index];

                  return EventoCard.eventCard(
                    titolo: ev['nome'] ?? 'Senza nome',
                    dateRange:
                        _formattaDate(ev['data_inizio'], ev['data_fine']),
                    luogo: ev['localita'] ?? 'Località N/D',
                    stato: ev['stato'] ?? 'Sconosciuto',
                    icon: _tipiEvento[ev['tipo_evento']] ?? Icons.event,
                    onTap: () async {
                      // ⭐ ORA PUNTA CORRETTAMENTE A EVENT VIEWSHELL
                      final refresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventoViewShell(eventoId: ev['id']),
                        ),
                      );

                      if (refresh == true) {
                        _loadEvents();
                      }
                    },
                  );
                },
              );
            },
          ),
          bottomNavigationBar: AppWidgets.actionBar(
            actions: [
              AppWidgets.actionButton(
                icon: Icons.add,
                label: 'nuova_attivita'.tr(),
                onTap: _mostraPopupCreazione,
              ),
              AppWidgets.actionButton(
                icon: Icons.info,
                label: "",
                onTap: () async {
                  await TutorialService.reset("tutorial_home");

                  showTutorial =
                      await TutorialService.shouldShow("tutorial_home");

                  setState(() {});
                },
              ),
            ],
          ),
        ),

        // ⭐ FUMETTO TUTORIAL
        if (showTutorial)
          BubbleWidget(
            title: tutorialHomeTitle(),
            text: tutorialHomeText(),
            onClose: () => setState(() => showTutorial = false),
            onDontShowAgain: () async {
              await TutorialService.disable("tutorial_home");
              setState(() => showTutorial = false);
            },
          ),
      ],
    );
  }
}
