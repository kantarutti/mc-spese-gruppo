import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import '../services/auth_service.dart';

// Formatter Morbido: +[prefisso libero] [spazio] XXX XXX XXXXXX
class MorbidoTelefonoFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;

    // Forza il '+' sempre all'inizio
    if (text.isEmpty || !text.startsWith('+')) {
      return const TextEditingValue(
        text: '+',
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    // Se l'utente cancella tutto tranne il +, ci fermiamo
    if (text == '+') return newValue;

    // Troviamo la posizione del primo spazio (fine del prefisso internazionale)
    int firstSpaceIndex = text.indexOf(' ');

    if (firstSpaceIndex == -1) {
      // L'utente sta ancora scrivendo il prefisso internazionale, non formattiamo nulla
      return newValue;
    }

    // Se c'è lo spazio, formattiamo solo quello che viene DOPO
    String prefix = text.substring(0, firstSpaceIndex + 1);
    String remaining = text.substring(firstSpaceIndex + 1).replaceAll(' ', '');
    String formattedRemaining = '';

    for (int i = 0; i < remaining.length; i++) {
      if (i == 3 || i == 6) formattedRemaining += ' ';
      if (i < 12) formattedRemaining += remaining[i]; // Limite massimo per il numero
    }

    String result = prefix + formattedRemaining;
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

class PartecipantiPage extends StatefulWidget {
  final dynamic eventoId;
  const PartecipantiPage({super.key, required this.eventoId});

  @override
  State<PartecipantiPage> createState() => _PartecipantiPageState();
}

class _PartecipantiPageState extends State<PartecipantiPage> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController(text: '+');
  final _nomeController = TextEditingController();
  final _cellulareController = TextEditingController(text: '+');
  
  String? _gruppoSelezionatoId;
  List<Map<String, dynamic>> _gruppi = [];
  bool _isLoading = false;
  bool _utenteTrovato = false;

  static const Color azzurroApp = Color(0xFF00B2FF);

  @override
  void initState() {
    super.initState();
    _caricaGruppi();
  }

  String _generaCodiceRandom() {
    var rng = Random();
    return (rng.nextInt(900000) + 100000).toString();
  }

  Future<void> _caricaGruppi() async {
    // Aggiornato: seleziona 'id' e 'gruppo' per coerenza con il DB
    final data = await _supabase.from('gruppi').select('id, gruppo').eq('evento_id', widget.eventoId).order('gruppo');
    setState(() => _gruppi = List<Map<String, dynamic>>.from(data));
  }

  void _mostraPopupInvito(String nomeInvitato, String codice, String nomeEvento) {
    final nomeOrganizzatore = AuthService.currentUser?.nome ?? "Un tuo amico";
    
    final messaggio = "Ciao $nomeInvitato,\n"
        "$nomeOrganizzatore ti ha invitato a partecipare all'evento *$nomeEvento*.\n"
        "Accedi all'app *MC Spese di Gruppo* con il tuo numero di telefono ed il seguente codice provvisorio: *$codice*";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Invito", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(messaggio),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: messaggio));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Messaggio copiato!")));
            },
            icon: const Icon(Icons.copy),
            label: const Text("COPIA"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CHIUDI"),
          ),
        ],
      ),
    );
  }

  Future<void> _cercaUtente() async {
    final search = _searchController.text.trim().replaceAll(' ', '');
    if (search == '+') return;
    setState(() => _isLoading = true);
    try {
      final res = await _supabase.from('utenti').select().eq('cellulare', search).maybeSingle();
      if (res != null) {
        setState(() {
          _nomeController.text = res['nome'] ?? '';
          _cellulareController.text = _searchController.text;
          _utenteTrovato = true;
        });
      } else {
        setState(() {
          _nomeController.clear();
          _cellulareController.text = _searchController.text;
          _utenteTrovato = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _aggiungiPartecipante() async {
    if (_cellulareController.text.length < 5 || _nomeController.text.isEmpty || _gruppoSelezionatoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Compila tutti i campi")));
      return;
    }
    final cellulare = _cellulareController.text.trim().replaceAll(' ', '');
    final codice = _generaCodiceRandom();
    final nomeInvitato = _nomeController.text.trim();

    try {
      final eventoRes = await _supabase.from('eventi').select('nome').eq('id', widget.eventoId).single();
      final nomeEvento = eventoRes['nome'] ?? "Evento";

      if (!_utenteTrovato) {
        await _supabase.from('utenti').insert({
          'cellulare': cellulare,
          'nome': nomeInvitato,
          'codice_personale': codice,
          'ruolo': 'Invitato',
          'primo_accesso': true,
        });
      }

      await _supabase.from('partecipanti').insert({
        'evento_id': widget.eventoId,
        'cellulare': cellulare,
        'gruppo_id': _gruppoSelezionatoId,
      });

      if (!_utenteTrovato) {
        _mostraPopupInvito(nomeInvitato, codice, nomeEvento);
      }
      
      _searchController.text = '+';
      _nomeController.clear();
      _cellulareController.text = '+';
      setState(() { _gruppoSelezionatoId = null; _utenteTrovato = false; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Partecipanti", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: azzurroApp,
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [MorbidoTelefonoFormatter()],
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: azzurroApp), 
                    hintText: "Esempio: +39 [spazio] 333...",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: azzurroApp), 
                      onPressed: _cercaUtente
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildInputDati(Icons.person, "Nome", _nomeController, isReadOnly: _utenteTrovato),
                _buildInputDati(Icons.smartphone, "Cellulare", _cellulareController, isReadOnly: _utenteTrovato, useFormatter: true),
                DropdownButtonFormField<String>(
                  value: _gruppoSelezionatoId,
                  hint: const Text("Seleziona Gruppo"),
                  // Aggiornato: usa g['gruppo'] invece di g['nome']
                  items: _gruppi.map((g) => DropdownMenuItem(value: g['id'].toString(), child: Text(g['gruppo'] ?? 'N/D'))).toList(),
                  onChanged: (v) => setState(() => _gruppoSelezionatoId = v),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _aggiungiPartecipante,
                  style: ElevatedButton.styleFrom(backgroundColor: azzurroApp, minimumSize: const Size(double.infinity, 45)),
                  child: const Text("AGGIUNGI", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder(
              stream: _supabase.from('partecipanti').stream(primaryKey: ['id']).eq('evento_id', widget.eventoId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data as List;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final p = docs[i];
                    return ListTile(
                      leading: const CircleAvatar(backgroundColor: azzurroApp, child: Icon(Icons.person, color: Colors.white)),
                      title: FutureBuilder(
                        future: _supabase.from('utenti').select().eq('cellulare', p['cellulare']).maybeSingle(),
                        builder: (context, res) {
                          final u = res.data;
                          return Row(
                            children: [
                              Expanded(child: Text(u?['nome'] ?? p['cellulare'], style: const TextStyle(fontWeight: FontWeight.bold))),
                              IconButton(
                                icon: const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                                onPressed: () async {
                                  final evRes = await _supabase.from('eventi').select('nome').eq('id', widget.eventoId).single();
                                  _mostraPopupInvito(u?['nome'] ?? "Invitato", u?['codice_personale'] ?? "N/A", evRes['nome']);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () async => await _supabase.from('partecipanti').delete().eq('id', p['id']),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputDati(IconData icon, String label, TextEditingController controller, {required bool isReadOnly, bool useFormatter = false}) {
    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      inputFormatters: useFormatter ? [MorbidoTelefonoFormatter()] : [],
      decoration: InputDecoration(prefixIcon: Icon(icon, color: azzurroApp), labelText: label),
    );
  }
}