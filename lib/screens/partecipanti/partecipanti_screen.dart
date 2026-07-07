import 'package:flutter/material.dart';

/// Screen Gestione Partecipanti
class ParticipantiScreen extends StatefulWidget {
  const ParticipantiScreen({Key? key}) : super(key: key);

  @override
  State<ParticipantiScreen> createState() => _ParticipantiScreenState();
}

class _ParticipantiScreenState extends State<ParticipantiScreen> {
  final List<Map<String, String>> _partecipanti = [
    {'nome': 'Marco', 'cellulare': '+39 320 123 4567', 'gruppo': 'Gruppo A'},
    {'nome': 'Luca', 'cellulare': '+39 333 456 7890', 'gruppo': 'Gruppo B'},
    {'nome': 'Anna', 'cellulare': '+39 345 678 9012', 'gruppo': 'Gruppo 1'},
    {'nome': 'Sara', 'cellulare': '+39 366 789 0123', 'gruppo': 'Gruppo A'},
    {'nome': 'Giovanni', 'cellulare': '+39 389 012 3456', 'gruppo': 'Gruppo B'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partecipanti'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _partecipanti.length,
        itemBuilder: (context, index) {
          final partecipante = _partecipanti[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  partecipante['nome']![0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(partecipante['nome'] ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(partecipante['cellulare'] ?? ''),
                  Text(
                    partecipante['gruppo'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    child: Text('Modifica'),
                  ),
                  const PopupMenuItem(
                    child: Text('Elimina'),
                  ),
                ],
              ),
              onTap: () {
                // Mostra dettagli partecipante
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Apri form aggiunta partecipante
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
