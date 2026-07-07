import 'package:flutter/material.dart';

import '../../models/evento.dart';
import '../../utils/formatters.dart';

class EventoDettaglioScreen extends StatelessWidget {
  final Evento evento;

  const EventoDettaglioScreen({
    Key? key,
    required this.evento,
  }) : super(key: key);

  String _safeFormatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio evento'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailItem(label: 'ID', value: evento.id),
          _DetailItem(label: 'Nome', value: evento.nome),
          _DetailItem(label: 'Descrizione', value: evento.descrizione ?? '-'),
          _DetailItem(label: 'Tipo', value: evento.tipo),
          _DetailItem(label: 'Stato', value: evento.stato),
          _DetailItem(label: 'Gruppo ID', value: evento.gruppoId),
          _DetailItem(label: 'Località ID', value: evento.localitaId ?? '-'),
          _DetailItem(label: 'Valuta', value: evento.valuta),
          _DetailItem(label: 'Data inizio', value: _safeFormatDate(evento.dataInizio)),
          _DetailItem(
            label: 'Data fine',
            value: _safeFormatDate(evento.dataFine),
          ),
          _DetailItem(label: 'Creato il', value: _safeFormatDate(evento.createdAt)),
          _DetailItem(label: 'Aggiornato il', value: _safeFormatDate(evento.updatedAt)),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
