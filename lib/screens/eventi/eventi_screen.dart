import 'package:flutter/material.dart';

/// Screen Gestione Eventi
class EventiScreen extends StatefulWidget {
  const EventiScreen({Key? key}) : super(key: key);

  @override
  State<EventiScreen> createState() => _EventiScreenState();
}

class _EventiScreenState extends State<EventiScreen> {
  final List<Map<String, String>> _eventi = [
    {'nome': 'Cena Weekend', 'data': '15 Luglio 2026', 'persone': '8'},
    {'nome': 'Gita Montagna', 'data': '22 Luglio 2026', 'persone': '12'},
    {'nome': 'Festival Musica', 'data': '30 Luglio 2026', 'persone': '20'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventi'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _eventi.length,
        itemBuilder: (context, index) {
          final evento = _eventi[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(
                Icons.event,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(evento['nome'] ?? ''),
              subtitle: Text('${evento['data']} • ${evento['persone']} persone'),
              trailing: Icon(Icons.arrow_forward, color: Colors.grey[400]),
              onTap: () {
                // Naviga ai dettagli dell'evento
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Apri form creazione evento
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
