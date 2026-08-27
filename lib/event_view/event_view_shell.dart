import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../home_page.dart';
import 'event_view_tab.dart';
import 'groups_tab.dart';
import 'group_details_tab.dart';
import 'giroconti_tab.dart';
import 'stats_tab.dart';
import '../config/app_widgets.dart';

import '../user/login_page.dart';
import '../config/app_colors.dart';

class EventViewShell extends StatefulWidget {
  final dynamic eventoId;

  const EventViewShell({
    super.key,
    required this.eventoId,
  });

  @override
  State<EventViewShell> createState() => _EventViewShellState();
}

class _EventViewShellState extends State<EventViewShell> {
  final _supabase = Supabase.instance.client;

  int _currentIndex = 1; // 1 = EventTab (default)
  dynamic _selectedGruppoId;

  static const Color azzurroIntenso = Color(0xFF00B2FF);

  IconData _getEventIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'viaggio':
        return Icons.flight;
      case 'gita':
        return Icons.directions_car;
      case 'pranzo - cena':
        return Icons.restaurant;
      case 'festa':
        return Icons.celebration;
      case 'lavoro':
        return Icons.work;
      default:
        return Icons.redeem;
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 1:
        return EventTab(eventoId: widget.eventoId);

      case 2:
        if (_selectedGruppoId == null) {
          return GroupsTab(
            eventoId: widget.eventoId,
            onGruppoTap: (id) {
              setState(() => _selectedGruppoId = id);
            },
          );
        } else {
          return GroupDetailsTab(
            gruppoId: _selectedGruppoId,
            onBack: () {
              setState(() => _selectedGruppoId = null);
            },
          );
        }

      case 3:
        return GirocontiTab(eventoId: widget.eventoId);

      case 4:
        return StatsTab(eventoId: widget.eventoId);

      default:
        return EventTab(eventoId: widget.eventoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidgets.appBar(
        leftWidget: null,

        titleWidget: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _supabase
              .from('eventi')
              .stream(primaryKey: ['id'])
              .eq('id', widget.eventoId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text(
                'Evento',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              );
            }

            final ev = snapshot.data!.first;
            final nome = ev['nome'] ?? '';
            final tipo = ev['tipo_evento'] ?? 'evento';

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getEventIcon(tipo),
                  color: Colors.white,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Text(
                  nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            );
          },
        ),

        rightWidget: InkWell(
  borderRadius: BorderRadius.circular(50),
  onTap: () async {
    await _supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  },
  child: Container(
    decoration: BoxDecoration(
      color: AppColors.primaryColor,
      shape: BoxShape.circle,
    ),
    padding: const EdgeInsets.all(8),
    child: const Icon(Icons.logout, color: Colors.white),
  ),
),

      ),

      body: _buildBody(),

      bottomNavigationBar: AppWidgets.navBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
            return;
          }

          setState(() {
            _currentIndex = index;
            _selectedGruppoId = null;
          });
        },
      ),
    );
  }
}
