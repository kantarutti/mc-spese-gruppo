import 'package:flutter/material.dart';

/// Screen Home
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
