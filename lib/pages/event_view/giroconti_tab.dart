import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart'; // ⭐ IMPORT AGGIUNTO
import 'giroconti_edit_tab.dart';
import '../../config/app_widgets.dart';
import '../../config/app_colors.dart';

class GirocontiTab extends StatefulWidget {
  final dynamic eventoId;

  const GirocontiTab({super.key, required this.eventoId});

  @override
  State<GirocontiTab> createState() => _GirocontiTabState();
}

class _GirocontiTabState extends State<GirocontiTab> {
  String _valutaTarget = "...";

  @override
  void initState() {
    super.initState();
    _fetchEventoInfo();
  }

  Future<void> _fetchEventoInfo() async {
    final res = await Supabase.instance.client
        .from('eventi')
        .select('valuta_target')
        .eq('id', widget.eventoId)
        .single();
    if (mounted) {
      setState(() => _valutaTarget = res['valuta_target'] ?? 'EUR');
    }
  }

  Future<void> _navigaEAggiorna(BuildContext context,
      [Map<String, dynamic>? giroconto]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GirocontiEditTab(
          eventoId: widget.eventoId,
          giroconto: giroconto,
        ),
      ),
    );
    setState(() {});
  }

  Future<String> _getGroupName(dynamic gruppoId) async {
    try {
      final res = await Supabase.instance.client
          .from('gruppi')
          .select('gruppo')
          .eq('id', gruppoId)
          .single();
      return res['gruppo'] ?? 'N/D';
    } catch (e) {
      return 'Errore';
    }
  }

  @override
  Widget build(BuildContext context) {
    final _supabase = Supabase.instance.client;
    final _nf = NumberFormat("#,##0.00", "it_IT");

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "label_giroconti".tr(), // ⭐ TRADOTTO
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Text(_valutaTarget,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabase
                  .from('giroconti')
                  .stream(primaryKey: ['id'])
                  .eq('evento_id', widget.eventoId)
                  .order('data_giroconto', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final giroconti = snapshot.data ?? [];

                if (giroconti.isEmpty) {
                  return Center(
                    child: Text(
                      "nessun_giroconto_trovato".tr(), // ⭐ TRADOTTO
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  itemCount: giroconti.length,
                  itemBuilder: (context, index) {
                    final item = giroconti[index];
                    final double importoGiroconto =
                        (item['giroconto'] ?? 0).toDouble();
                    final DateTime data =
                        DateTime.parse(item['data_giroconto']);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 1,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        onTap: () => _navigaEAggiorna(context, item),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primaryColor,
                          child: const Icon(Icons.swap_horiz, color: Colors.white),
                        ),

 title: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    FutureBuilder<String>(
      future: _getGroupName(item['da_gruppo_id']),
      builder: (context, res) => Text(
        "${'da'.tr()}: ${res.data ?? "..."}", // ⭐ TRADOTTO (es. "DA:" / "FROM:")
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFFC62828)),
        overflow: TextOverflow.ellipsis,
      ),
    ),
    const SizedBox(height: 2),
    FutureBuilder<String>(
      future: _getGroupName(item['a_gruppo_id']),
      builder: (context, res) => Text(
        "${'a'.tr()}: ${res.data ?? "..."}", // ⭐ TRADOTTO (es. "A:" / "TO:")
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF2E7D32)),
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
),                       
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _nf.format(importoGiroconto),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(data),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppWidgets.whiteBar(
        left: null,
        center: AppWidgets.whiteButton(
          icon: Icons.add,
          label: "inserisci".tr(), // ⭐ TRADOTTO
          onTap: () => _navigaEAggiorna(context),
        ),
        right: null,
      ),
    );
  }
}