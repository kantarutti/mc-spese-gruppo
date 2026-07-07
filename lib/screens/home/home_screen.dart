import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/eventi_provider.dart';
import '../../utils/formatters.dart';

/// Screen Home
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  String _formatDateRange(DateTime? dataInizio, DateTime? dataFine) {
    if (dataInizio == null && dataFine == null) return 'Data non disponibile';

    final inizio = dataInizio != null ? DateFormatter.format(dataInizio) : '';
    final fine = dataFine != null ? DateFormatter.format(dataFine) : '';

    if (inizio == fine || dataFine == null) {
      return inizio;
    }

    return '$inizio - $fine';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventiAsyncValue = ref.watch(eventiProvider);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Benvenuto!',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Gestisci le spese di gruppo in modo semplice',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: eventiAsyncValue.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Errore nel caricamento eventi',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (eventi) {
                  if (eventi.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Nessun evento disponibile',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Column(
                    children: eventi.map((evento) {
                      final dataFormattata = _formatDateRange(
                        evento.dataInizio,
                        evento.dataFine,
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(
                              Icons.event,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            evento.nome,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Luogo: ${evento.localitaId ?? 'non disponibile'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dataFormattata,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/evento-dettaglio',
                              arguments: evento,
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _DashboardCard(
                    icon: Icons.event,
                    title: 'Eventi',
                    subtitle: 'Crea e gestisci eventi',
                  ),
                  const SizedBox(height: 16),
                  _DashboardCard(
                    icon: Icons.groups,
                    title: 'Gruppi',
                    subtitle: 'Organizza i partecipanti',
                  ),
                  const SizedBox(height: 16),
                  _DashboardCard(
                    icon: Icons.receipt,
                    title: 'Spese',
                    subtitle: 'Traccia tutte le spese',
                  ),
                  const SizedBox(height: 16),
                  _DashboardCard(
                    icon: Icons.people,
                    title: 'Partecipanti',
                    subtitle: 'Gestisci i partecipanti',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
