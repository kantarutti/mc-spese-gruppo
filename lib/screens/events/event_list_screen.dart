import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/evento.dart';
import '../../providers/eventi_provider.dart';
import 'event_manage_screen.dart';

class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key});

  static const Color azzurroIntenso = Color(0xFF00B2FF);

  final Map<String, IconData> _tipiEvento = const {
    'Viaggio': Icons.flight,
    'Gita': Icons.directions_car,
    'Evento': Icons.event,
    'Pranzo - Cena': Icons.restaurant,
    'Festa': Icons.celebration,
    'Regalo': Icons.redeem,
  };

  String _formattaDate(DateTime? inizio, DateTime? fine) {
    if (inizio == null) return "Data non definita";
    final df = DateFormat('dd/MM/yyyy');
    try {
      final dataIniz = df.format(inizio);
      if (fine == null) return dataIniz;
      final dataFine = df.format(fine);
      return "$dataIniz - $dataFine";
    } catch (e) {
      return inizio.toString();
    }
  }

  void _mostraPopupCreazione(BuildContext context, WidgetRef ref) {
    final nomeController = TextEditingController();
    String tipoSelezionato = 'Viaggio';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Nuovo Evento',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: "Nome dell'evento",
                    hintText: 'es. Weekend a Roma',
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: tipoSelezionato,
                  decoration: const InputDecoration(labelText: 'Tipo di evento'),
                  items: [
                    DropdownMenuItem(
                      value: 'Viaggio',
                      child: Row(
                        children: [
                          Icon(Icons.flight, color: azzurroIntenso, size: 20),
                          const SizedBox(width: 10),
                          const Text('Viaggio'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Gita',
                      child: Row(
                        children: [
                          Icon(Icons.directions_car,
                              color: azzurroIntenso, size: 20),
                          const SizedBox(width: 10),
                          const Text('Gita'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Evento',
                      child: Row(
                        children: [
                          Icon(Icons.event, color: azzurroIntenso, size: 20),
                          const SizedBox(width: 10),
                          const Text('Evento'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Pranzo - Cena',
                      child: Row(
                        children: [
                          Icon(Icons.restaurant,
                              color: azzurroIntenso, size: 20),
                          const SizedBox(width: 10),
                          const Text('Pranzo - Cena'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Festa',
                      child: Row(
                        children: [
                          Icon(Icons.celebration,
                              color: azzurroIntenso, size: 20),
                          const SizedBox(width: 10),
                          const Text('Festa'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Regalo',
                      child: Row(
                        children: [
                          Icon(Icons.redeem, color: azzurroIntenso, size: 20),
                          const SizedBox(width: 10),
                          const Text('Regalo'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => tipoSelezionato = val);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ANNULLA'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.isEmpty) return;

                try {
                  // Chiama il provider di creazione
                  final eventoId = await ref.read(
                    createEventProvider(
                      CreateEventParams(
                        nome: nomeController.text,
                        tipoEvento: tipoSelezionato,
                      ),
                    ).future,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    // Naviga a EventManageScreen con l'ID evento creato
                    if (eventoId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EventManageScreen(eventoId: eventoId),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Errore: $e')),
                    );
                  }
                }
              },
              child: const Text('CREA', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventiAsync = ref.watch(eventiStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'I Miei Eventi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: azzurroIntenso,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () {
            // TODO: Navigare a ProfilePage
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // TODO: Implementare logout
            },
          ),
        ],
      ),
      body: eventiAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Errore: $error'),
        ),
        data: (eventi) {
          if (eventi.isEmpty) {
            return const Center(child: Text('Nessun evento creato.'));
          }

          return ListView.builder(
            itemCount: eventi.length,
            itemBuilder: (context, index) {
              final ev = eventi[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: azzurroIntenso,
                    child: Icon(
                      _tipiEvento[ev.tipoEvento] ?? Icons.event,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    ev.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${ev.localita ?? 'Località N/D'}\n${_formattaDate(ev.dataInizio, ev.dataFine)}",
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Naviga a EventManageScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EventManageScreen(eventoId: ev.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: azzurroIntenso,
        onPressed: () => _mostraPopupCreazione(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
