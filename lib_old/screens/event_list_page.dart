import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'event_manage_page.dart';
import 'event_view_page.dart';
import 'profile_setup_page.dart';
import 'login_page.dart';
import 'profile_page.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final _supabase = Supabase.instance.client;
  
  // Controller e variabili per il nuovo popup di creazione
  final TextEditingController _nomeNuovoEventoController = TextEditingController();
  String _tipoSelezionato = 'Viaggio';

  final Map<String, IconData> _tipiEvento = {
    'Viaggio': Icons.flight,
    'Gita': Icons.directions_car,
    'Evento': Icons.event,
    'Pranzo - Cena': Icons.restaurant,
    'Festa': Icons.celebration,
    'Regalo': Icons.redeem,
  };

  final Stream<List<Map<String, dynamic>>> _eventsStream = Supabase.instance.client
      .from('eventi')
      .stream(primaryKey: ['id'])
      .order('data_inizio', ascending: false);

  String _formattaDate(dynamic inizio, dynamic fine) {
    if (inizio == null) return "Data non definita";
    final df = DateFormat('dd/MM/yyyy');
    try {
      final dataIniz = df.format(DateTime.parse(inizio.toString()));
      if (fine == null) return dataIniz;
      final dataFine = df.format(DateTime.parse(fine.toString()));
      return "$dataIniz - $dataFine";
    } catch (e) {
      return inizio.toString();
    }
  }

  // Funzione Quick-Add: inserisce solo nome e tipo, il resto lo fa il Trigger DB
  void _mostraPopupCreazione() {
    _nomeNuovoEventoController.clear();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuovo Evento', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        Icon(_tipiEvento[tipo], color: const Color(0xFF00B2FF), size: 20),
                        const SizedBox(width: 10),
                        Text(tipo),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => _tipoSelezionato = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULLA')),
            ElevatedButton(
              onPressed: _creaEventoEApriManage,
              child: const Text('CREA', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _creaEventoEApriManage() async {
    if (_nomeNuovoEventoController.text.isEmpty) return;

    try {
      final nuovoEvento = await _supabase.from('eventi').insert({
        'nome': _nomeNuovoEventoController.text,
        'tipo_evento': _tipoSelezionato,
        'stato': 'Creazione',
      }).select().single();

      if (mounted) {
        Navigator.pop(context); // Chiude il Dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventManagePage(evento: nuovoEvento)),
        );
      }
    } catch (e) {
      debugPrint("Errore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I Miei Eventi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00B2FF),
        centerTitle: true,
        // Icona profilo a sinistra
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
        ),
        // Icona logout a destra
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _supabase.auth.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Errore: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final eventi = snapshot.data!;
          if (eventi.isEmpty) return const Center(child: Text("Nessun evento creato."));

          return ListView.builder(
            itemCount: eventi.length,
            itemBuilder: (context, index) {
              final ev = eventi[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF00B2FF),
                    child: Icon(_tipiEvento[ev['tipo_evento']] ?? Icons.event, color: Colors.white),
                  ),
                  title: Text(ev['nome'] ?? 'Senza nome', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${ev['localita'] ?? 'Località N/D'}\n${_formattaDate(ev['data_inizio'], ev['data_fine'])}"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EventViewPage(eventoId: ev['id']))),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00B2FF),
        onPressed: _mostraPopupCreazione,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}