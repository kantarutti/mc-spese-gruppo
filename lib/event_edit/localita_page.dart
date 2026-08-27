import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_widgets.dart';

class LocalitaPage extends StatefulWidget {
  final dynamic eventoId;

  const LocalitaPage({
    super.key,
    required this.eventoId,
  });

  @override
  State<LocalitaPage> createState() => _LocalitaPageState();
}

class _LocalitaPageState extends State<LocalitaPage> {
  final supabase = Supabase.instance.client;

  final TextEditingController nomeController = TextEditingController();

  List<Map<String, dynamic>> localita = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalita();
  }

  Future<void> _loadLocalita() async {
    setState(() => loading = true);

    final data = await supabase
        .from('localita')
        .select()
        .eq('evento_id', widget.eventoId)
        .order('localita');

    setState(() {
      localita = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  Future<void> _addLocalita() async {
    final nome = nomeController.text.trim();
    if (nome.isEmpty) return;

    await supabase.from('localita').insert({
      'localita': nome,
      'evento_id': widget.eventoId,
    });

    nomeController.clear();
    _loadLocalita();
  }

  void _editLocalita(Map<String, dynamic> item) {
    final controller = TextEditingController(text: item['localita']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Modifica Località"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nome Località"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            onPressed: () async {
              await supabase
                  .from('localita')
                  .update({'localita': controller.text.trim()})
                  .eq('id', item['id']);

              if (!mounted) return;
              Navigator.pop(context);
              _loadLocalita();
            },
            child: const Text("Salva"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLocalita(int id) async {
    await supabase.from('localita').delete().eq('id', id);
    _loadLocalita();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidgets.appBar(
        leftWidget: null,
        titleWidget: const Text(
          "Località dell'Evento",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        rightWidget: null,
      ),

      body: Column(
        children: [
          // FORM DI INSERIMENTO
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 0,
              color: Colors.deepPurple.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: "Nuova Località",
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _addLocalita,
                      icon: const Icon(Icons.add),
                      label: const Text("Aggiungi alla lista"),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // LISTA LOCALITÀ
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: localita.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final item = localita[index];

                      return ListTile(
                        title: Text(item['localita']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editLocalita(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () => _deleteLocalita(item['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: AppWidgets.actionBar(
        actions: [
          AppWidgets.actionButton(
            icon: Icons.arrow_back,
            label: "Indietro",
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
