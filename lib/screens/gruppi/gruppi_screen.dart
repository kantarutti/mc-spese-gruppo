import 'package:flutter/material.dart';

/// Screen Gestione Gruppi
class GruppiScreen extends StatefulWidget {
  const GruppiScreen({Key? key}) : super(key: key);

  @override
  State<GruppiScreen> createState() => _GruppiScreenState();
}

class _GruppiScreenState extends State<GruppiScreen> {
  final List<Map<String, String>> _gruppi = [
    {'nome': 'Gruppo A', 'evento': 'Cena Weekend', 'persone': '4', 'saldo': '€ 150,00'},
    {'nome': 'Gruppo B', 'evento': 'Cena Weekend', 'persone': '4', 'saldo': '€ 180,50'},
    {'nome': 'Gruppo 1', 'evento': 'Gita Montagna', 'persone': '6', 'saldo': '€ 320,00'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gruppi'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _gruppi.length,
        itemBuilder: (context, index) {
          final gruppo = _gruppi[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        gruppo['nome'] ?? '',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          gruppo['saldo'] ?? '',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Evento: ${gruppo['evento']}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Persone: ${gruppo['persone']}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Apri form creazione gruppo
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
