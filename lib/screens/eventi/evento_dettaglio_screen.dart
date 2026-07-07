import 'package:flutter/material.dart';
import '../../models/evento.dart';

/// Screen Dettaglio Evento
class EventoDettaglioScreen extends StatelessWidget {
  final Evento evento;

  const EventoDettaglioScreen({Key? key, required this.evento}) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non disponibile';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(evento.nome),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.event, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            evento.nome,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(evento.stato),
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dettagli',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _InfoRow(label: 'ID', value: evento.id),
                    _InfoRow(label: 'Nome', value: evento.nome),
                    _InfoRow(label: 'Tipo', value: evento.tipo),
                    _InfoRow(label: 'Stato', value: evento.stato),
                    _InfoRow(label: 'Valuta', value: evento.valuta),
                    if (evento.descrizione != null && evento.descrizione!.isNotEmpty)
                      _InfoRow(label: 'Descrizione', value: evento.descrizione!),
                    _InfoRow(label: 'Data inizio', value: _formatDate(evento.dataInizio)),
                    _InfoRow(label: 'Data fine', value: _formatDate(evento.dataFine)),
                    if (evento.localitaId != null)
                      _InfoRow(label: 'Luogo', value: evento.localitaId!),
                    _InfoRow(label: 'Gruppo ID', value: evento.gruppoId),
                    _InfoRow(label: 'Creato il', value: _formatDate(evento.createdAt)),
                    _InfoRow(label: 'Aggiornato il', value: _formatDate(evento.updatedAt)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
