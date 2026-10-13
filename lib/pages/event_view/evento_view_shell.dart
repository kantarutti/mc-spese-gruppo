import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart'; // ⭐ IMPORT FONDAMENTALE PER .tr()

import '../home_page.dart';
import '../user/login_page.dart';
import '../../config/app_colors.dart';

import 'evento_view_tab.dart';
import 'groups_tab.dart';
import 'group_details_tab.dart';
import 'giroconti_tab.dart';
import 'stats_tab.dart';
import '../../config/app_widgets.dart';

class EventoViewShell extends StatefulWidget {
  final dynamic eventoId;

  const EventoViewShell({
    super.key,
    required this.eventoId,
  });

  @override
  State<EventoViewShell> createState() => _EventoViewShellState();
}

class _EventoViewShellState extends State<EventoViewShell> {
  final _supabase = Supabase.instance.client;

  int _currentIndex = 1; // 1 = EventoViewTab (default)
  dynamic _selectedGruppoId;

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
        return EventoViewTab(eventoId: widget.eventoId);

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
        return EventoViewTab(eventoId: widget.eventoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _supabase
          .from('eventi')
          .stream(primaryKey: ['id'])
          .eq('id', widget.eventoId),
      builder: (context, snapshot) {
        bool isChiuso = false;
        String nome = 'Attività';
        String tipo = 'attivita';

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final ev = snapshot.data!.first;
          nome = ev['nome'] ?? '';
          tipo = ev['tipo_evento'] ?? 'attivita';
          final stato = ev['stato']?.toString().toLowerCase() ?? '';
          isChiuso = (stato == 'chiuso');
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppWidgets.appBar(
            leftWidget: null,
            titleWidget: Row(
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
          bottomNavigationBar: AppWidgets.eventBar(
            currentIndex: _currentIndex,
            isChiuso: isChiuso,
            onTap: (index) {
              if (index == 0) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
                return;
              }

              // Se l'evento è chiuso e l'utente tenta di cliccare sul Case 2 o 3, blocchiamo l'azione
              if (isChiuso && (index == 2 || index == 3)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("attivita_chiusa_msg".tr()),
                    duration: const Duration(seconds: 2),
                  ),
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
      },
    );
  }
}