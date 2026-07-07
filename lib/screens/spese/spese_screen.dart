import 'package:flutter/material.dart';

/// Screen Registrazione Spese
class SpeseScreen extends StatefulWidget {
  const SpeseScreen({Key? key}) : super(key: key);

  @override
  State<SpeseScreen> createState() => _SpeseScreenState();
}

class _SpeseScreenState extends State<SpeseScreen> {
  final List<Map<String, dynamic>> _spese = [
    {
      'descrizione': 'Cena al ristorante',
      'importo': 120.50,
      'data': '15 Lug',
      'pagante': 'Marco',
      'gruppo': 'Gruppo A'
    },
    {
      'descrizione': 'Taxi andata',
      'importo': 25.00,
      'data': '15 Lug',
      'pagante': 'Luca',
      'gruppo': 'Gruppo B'
    },
    {
      'descrizione': 'Hotel',
      'importo': 450.00,
      'data': '22 Lug',
      'pagante': 'Anna',
      'gruppo': 'Gruppo 1'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spese'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _spese.length,
        itemBuilder: (context, index) {
          final spesa = _spese[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(
                Icons.receipt,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(spesa['descrizione']),
              subtitle: Text('${spesa['pagante']} • ${spesa['data']}'),
              trailing: Text(
                '€ ${spesa['importo'].toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // Mostra dettagli spesa
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Apri form registrazione spesa
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
