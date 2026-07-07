import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ValutePage extends StatefulWidget {
  final dynamic eventoId;
  const ValutePage({super.key, required this.eventoId});

  @override
  State<ValutePage> createState() => _ValutePageState();
}

class _ValutePageState extends State<ValutePage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _controller = TextEditingController();
  static const Color azzurroIntenso = Color(0xFF00B2FF);
  List<dynamic> _valute = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  // Caricamento dati identico a Località per garantire l'aggiornamento UI
  Future<void> _carica() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('valute')
          .select()
          .eq('evento_id', widget.eventoId)
          .order('valuta');
      setState(() {
        _valute = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Errore caricamento: $e");
    }
  }

  void _mostraModifica(Map item) {
    final editController = TextEditingController(text: item['valuta']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifica Valuta'),
        content: TextField(
          controller: editController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Sigla Valuta'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () async {
              await supabase
                  .from('valute')
                  .update({'valuta': editController.text.toUpperCase().trim()})
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
      // AppBar coerente con EventView e Località
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Configurazione Valute', 
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
              color: azzurroIntenso.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Nuova Valuta (es. USD)',
                        prefixIcon: Icon(Icons.currency_exchange),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_controller.text.isEmpty) return;
                        await supabase.from('valute').insert({
                          'valuta': _controller.text.toUpperCase().trim(),
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
                    itemCount: _valute.length,
                    separatorBuilder: (c, i) => const Divider(height: 1),
                    itemBuilder: (c, i) => ListTile(
                      title: Text(_valute[i]['valuta'], 
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _mostraModifica(_valute[i]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () async {
                              await supabase.from('valute').delete().eq('id', _valute[i]['id']);
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
      // NavBar vuota per coerenza estetica
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