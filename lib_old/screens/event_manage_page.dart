import 'package:flutter/material.dart';
import 'valute_page.dart';
import 'localita_page.dart';
import 'gruppi_page.dart';
import 'partecipanti_page.dart';
import 'event_edit_page.dart';

class EventManagePage extends StatefulWidget {
  final Map<String, dynamic>? evento;
  const EventManagePage({super.key, this.evento});

  @override
  State<EventManagePage> createState() => _EventManagePageState();
}

class _EventManagePageState extends State<EventManagePage> {
  static const Color azzurroIntenso = Color(0xFF00B2FF);
  final GlobalKey<EventEditPageState> _editKey = GlobalKey<EventEditPageState>();

  // Aggiungiamo questa funzione per gestire il salvataggio tramite la Key
  void _salvaSpesa() {
    // Cerchiamo di chiamare il metodo di salvataggio. 
    // Assicurati che in EventEditPage il metodo sia pubblico (senza _)
    // Se il metodo si chiama in un altro modo, cambia '.salva()' qui sotto.
    (_editKey.currentState as dynamic)?.salva(); 
  }

  @override
  Widget build(BuildContext context) {
    final dynamic eventoId = widget.evento?['id'];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Gestione Evento', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      automaticallyImplyLeading: false,
         toolbarHeight: 70,
         centerTitle: true,
        backgroundColor: azzurroIntenso,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            EventEditPage(key: _editKey, evento: widget.evento, isEmbedded: true),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildActionChip(context, Icons.map, 'Località', () => Navigator.push(context, MaterialPageRoute(builder: (c) => LocalitaPage(eventoId: eventoId))).then((_) => _editKey.currentState?.caricaDatiEvento(eventoId))),
                  _buildActionChip(context, Icons.currency_exchange, 'Valute', () => Navigator.push(context, MaterialPageRoute(builder: (c) => ValutePage(eventoId: eventoId))).then((_) => _editKey.currentState?.caricaDatiEvento(eventoId))),
                  _buildActionChip(context, Icons.group_work, 'Gruppi', () => Navigator.push(context, MaterialPageRoute(builder: (c) => GruppiPage(eventoId: eventoId)))),
                  _buildActionChip(context, Icons.person_add_alt_1, 'Partecipanti', () => Navigator.push(context, MaterialPageRoute(builder: (c) => PartecipantiPage(eventoId: eventoId)))),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 2.0,
            ),
          ),
        ),
        child: BottomAppBar(
          elevation: 0,
          color: azzurroIntenso,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Annulla",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: _salvaSpesa, // Ora punta alla funzione locale
                    child: const Text(
                      "Salva",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 20, color: azzurroIntenso),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      onPressed: onTap,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: azzurroIntenso)),
    );
  }
}