import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/app_widgets.dart';
import '../services/valute_info_service.dart';

class ValutePage extends StatefulWidget {
  final dynamic eventoId;

  const ValutePage({
    super.key,
    required this.eventoId,
  });

  @override
  State<ValutePage> createState() => _ValutePageState();
}

class _ValutePageState extends State<ValutePage> {
  final supabase = Supabase.instance.client;

  final TextEditingController valutaController = TextEditingController();

  List<Map<String, dynamic>> valute = [];
  bool loading = true;

  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadValute();
    ValuteInfoService.load();
  }

  Future<void> _loadValute() async {
    setState(() => loading = true);

    try {
      final data = await supabase
          .from('valute')
          .select()
          .eq('evento_id', widget.eventoId)
          .order('valuta');

      setState(() {
        valute = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      debugPrint("Errore caricamento valute: $e");
      setState(() => loading = false);
    }
  }

  // ⭐ Ricerca valute tramite ValuteService
  void _searchValute(String query) {
    query = query.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    isSearching = true;

    final matches = ValuteInfoService.search(query);

    matches.sort((a, b) => a['code'].toString().compareTo(b['code'].toString()));

    setState(() {
      searchResults = matches
          .map((c) => {
                'code': c['code'],
                'name': c['name'],
                'countries': c['countries'],
              })
          .toList();
    });
  }

  // ⭐ Aggiunta da ricerca con controllo duplicato
  Future<void> _addValutaFromSearch(String code) async {
    final sigla = code.trim().toUpperCase();

    final exists = valute.any((v) => v['valuta'] == sigla);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("La valuta $sigla è già presente nell'evento")),
      );
      return;
    }

    await supabase.from('valute').insert({
      'valuta': sigla,
      'evento_id': widget.eventoId,
    });

    valutaController.clear();
    setState(() {
      searchResults = [];
      isSearching = false;
    });

    _loadValute();
  }

  Future<void> _deleteValuta(int id) async {
    await supabase.from('valute').delete().eq('id', id);
    _loadValute();
  }

  // ⭐ Evidenziazione del match
  Widget highlightMatch(String text, String query) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final start = lowerText.indexOf(lowerQuery);
    if (start == -1) {
      return Text(text);
    }

    final end = start + query.length;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, start),
            style: const TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: text.substring(start, end),
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: text.substring(end),
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidgets.appBar(
        leftWidget: null,
        titleWidget: const Text(
          "Valute dell'Evento",
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 0,
              color: Colors.blue.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: valutaController,
                      onChanged: _searchValute,
                      decoration: const InputDecoration(
                        labelText: "Cerca Valuta o Nazione",
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),

                    if (isSearching && searchResults.isNotEmpty)
                      Container(
                        height: 250,
                        margin: const EdgeInsets.only(top: 10),
                        child: Card(
                          elevation: 2,
                          child: ListView.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (_, index) {
                              final item = searchResults[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      highlightMatch(
                                          "${item['code']} - ${item['name']}",
                                          valutaController.text),
                                      const SizedBox(height: 1),
                                      highlightMatch(
                                          item['countries'].join(", "),
                                          valutaController.text),
                                    ],
                                  ),
                                  onTap: () => _addValutaFromSearch(item['code']),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: valute.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final item = valute[index];

                      return ListTile(
                        title: Text(
                          item['valuta'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () => _deleteValuta(item['id']),
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
