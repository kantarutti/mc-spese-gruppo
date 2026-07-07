import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tabs/home_tab.dart';
import 'tabs/groups_tab.dart';
import 'tabs/group_details_page.dart'; 
import 'event_list_page.dart';
import 'tabs/giroconti_tab.dart';
import 'tabs/stats_tab.dart';

class EventViewPage extends StatefulWidget {
  final dynamic eventoId;
  const EventViewPage({super.key, required this.eventoId});

  @override
  State<EventViewPage> createState() => _EventViewPageState();
}

class _EventViewPageState extends State<EventViewPage> {
  final _supabase = Supabase.instance.client;
  int _currentIndex = 0;
  dynamic _selectedGruppoId; // Stato per gestire la navigazione interna al Tab Spese
  static const Color azzurroIntenso = Color(0xFF00B2FF);

  @override
  Widget build(BuildContext context) {
    // Logica per decidere cosa mostrare nel corpo della Shell
    Widget currentBody;

    switch (_currentIndex) {
      case 0:
        currentBody = HomeTab(eventoId: widget.eventoId);
        break;
      case 1:
        if (_selectedGruppoId == null) {
          // Pagina 1: Lista Gruppi
          currentBody = GroupsTab(
            eventoId: widget.eventoId,
            onGruppoTap: (id) => setState(() => _selectedGruppoId = id),
          );
        } else {
          // Pagina 2: Dettagli Gruppo (Totali + Lista Spese)
          currentBody = GroupDetailsPage(
            gruppoId: _selectedGruppoId,
            onBack: () => setState(() => _selectedGruppoId = null),
          );
        }
        break;
      case 2:
        currentBody = GirocontiTab(eventoId: widget.eventoId);
        break;
      case 3:
        // Collegamento alla pagina delle statistiche
        currentBody = StatsTab(eventoId: widget.eventoId);
        break;
      default:
        currentBody = HomeTab(eventoId: widget.eventoId);
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.list, color: Colors.white),
          onPressed: () {
            if (_currentIndex == 1 && _selectedGruppoId != null) {
              // Se sono nel dettaglio, il tasto indietro della Shell mi riporta alla lista gruppi
              setState(() => _selectedGruppoId = null);
            } else {
              // Altrimenti esco dall'evento
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const EventListPage()),
                (route) => false,
              );
            }
          },
        ),
        title: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _supabase.from('eventi').stream(primaryKey: ['id']).eq('id', widget.eventoId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text('...');
            final ev = snapshot.data!.first;
            return Text(ev['nome'] ?? '', 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24));
          },
        ),
        backgroundColor: azzurroIntenso,
        centerTitle: true,
        elevation: 0,
      ),
      body: currentBody,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: azzurroIntenso,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _selectedGruppoId = null; // Resetta la navigazione interna quando cambi Tab
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Spese'),
          BottomNavigationBarItem(icon: Icon(Icons.sync_alt), label: 'Giroconti'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Grafici'),
        ],
      ),
    );
  }
}