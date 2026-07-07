import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocalitaPage extends StatefulWidget {
  final dynamic eventoId;
  const LocalitaPage({super.key, required this.eventoId});

  @override
  State<LocalitaPage> createState() => _LocalitaPageState();
}

class _LocalitaPageState extends State<LocalitaPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _controller = TextEditingController();
  static const Color azzurroIntenso = Color(0xFF00B2FF); // Colore coerente
  List<dynamic> _localita = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    setState(() => _isLoading = true);
    final data = await supabase
        .from('localita')
        .select()
        .eq('evento_id', widget.eventoId)
        .order('localita');
    setState(() {
      _localita = data;
      _isLoading = false;
    });
  }

  void _mostraModifica(Map item) {
    final editController = TextEditingController(text: item['localita']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifica Località'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(labelText: 'Nome Località'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () async {
              await supabase
                  .from('localita')
                  .update({'localita': editController.text.trim()})
                  .eq('id', item['id']);
              if (!mounted) return;
              Navigator.pop(context);
              _carica();
            },
            child: const Text('Salva'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 1) AppBar identica a EventViewPage
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Località dell\'Evento', 
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 0,
              color: Colors.deepPurple.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Nuova Località',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_controller.text.isEmpty) return;
                        await supabase.from('localita').insert({
                          'localita': _controller.text.trim(),
                          'evento_id': widget.eventoId
                        });
                        _controller.clear();
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _localita.length,
                    separatorBuilder: (c, i) => const Divider(height: 1),
                    itemBuilder: (c, i) => ListTile(
                      title: Text(_localita[i]['localita']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _mostraModifica(_localita[i]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () async {
                              await supabase.from('localita').delete().eq('id', _localita[i]['id']);
                              _carica();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      // 2) NavBar vuota (solo estetica) per coerenza
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: azzurroIntenso,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
          BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
        ],
      ),
    );
  }
}