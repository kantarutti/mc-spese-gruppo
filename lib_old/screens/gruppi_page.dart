import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GruppiPage extends StatefulWidget {
  final dynamic eventoId;
  const GruppiPage({super.key, required this.eventoId});

  @override
  State<GruppiPage> createState() => _GruppiPageState();
}

class _GruppiPageState extends State<GruppiPage> {
  final _supabase = Supabase.instance.client;
  static const Color azzurroIntenso = Color(0xFF00B2FF);
  
  List<dynamic> _gruppi = [];
  bool _isLoading = true;
  final _nController = TextEditingController();
  final _pController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabase
          .from('gruppi')
          .select()
          .eq('evento_id', widget.eventoId)
          .order('gruppo'); // AGGIORNATO: ordinamento per 'gruppo'
      
      if (!mounted) return;
      
      setState(() {
        _gruppi = data;
        _isLoading = false;
      });
      
      // Aggiorna il totale persone nell'evento principale
      int tot = data.fold(0, (s, item) => s + (item['numero_persone'] as int? ?? 0));
      await _supabase.from('eventi').update({'persone': tot}).eq('id', widget.eventoId);
      
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Errore caricamento gruppi: $e");
    }
  }

  void _mostraDialogModifica(Map gruppo) {
    final editN = TextEditingController(text: gruppo['gruppo']); // AGGIORNATO: usa 'gruppo'
    final editP = TextEditingController(text: gruppo['numero_persone'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifica Gruppo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editN, 
              decoration: const InputDecoration(labelText: 'Nome Gruppo'),
              textCapitalization: TextCapitalization.words,
            ),
            TextField(
              controller: editP, 
              decoration: const InputDecoration(labelText: 'Numero Persone'), 
              keyboardType: TextInputType.number
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () async {
              await _supabase.from('gruppi').update({
                'gruppo': editN.text.trim(), // AGGIORNATO: colonna 'gruppo'
                'numero_persone': int.parse(editP.text.isEmpty ? '0' : editP.text),
              }).eq('id', gruppo['id']);
              if (!mounted) return;
              Navigator.pop(context);
              _carica();
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Gestione Gruppi', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: azzurroIntenso,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: Column(
        children: [
          // Parte superiore: Inserimento
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 0,
              color: azzurroIntenso.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nController, 
                      decoration: const InputDecoration(
                        labelText: 'Nome Gruppo',
                        prefixIcon: Icon(Icons.group_add_outlined),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    TextField(
                      controller: _pController, 
                      decoration: const InputDecoration(
                        labelText: 'Numero partecipanti',
                        prefixIcon: Icon(Icons.person_outline),
                      ), 
                      keyboardType: TextInputType.number
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_nController.text.isEmpty) return;
                        await _supabase.from('gruppi').insert({
                          'evento_id': widget.eventoId,
                          'gruppo': _nController.text.trim(), // AGGIORNATO: colonna 'gruppo'
                          'numero_persone': int.parse(_pController.text.isEmpty ? '0' : _pController.text),
                        });
                        _nController.clear(); 
                        _pController.clear();
                        _carica();
                      }, 
                      icon: const Icon(Icons.add),
                      label: const Text('Aggiungi alla lista'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lista Gruppi
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _gruppi.length,
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemBuilder: (context, i) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: azzurroIntenso.withOpacity(0.1),
                      child: const Icon(Icons.people, color: azzurroIntenso),
                    ),
                    title: Text(_gruppi[i]['gruppo'] ?? 'N/D', // AGGIORNATO: usa 'gruppo'
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text("${_gruppi[i]['numero_persone']} partecipanti"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue), 
                          onPressed: () => _mostraDialogModifica(_gruppi[i])
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent), 
                          onPressed: () async {
                            await _supabase.from('gruppi').delete().eq('id', _gruppi[i]['id']);
                            _carica();
                          }
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: azzurroIntenso,
        items: const [
          BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
          BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
        ],
      ),
    );
  }
}