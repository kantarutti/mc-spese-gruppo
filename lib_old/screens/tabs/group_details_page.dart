import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'group_expense_page.dart'; // Import per la navigazione

class GroupDetailsPage extends StatefulWidget {
  final dynamic gruppoId;
  final VoidCallback onBack;

  const GroupDetailsPage({super.key, required this.gruppoId, required this.onBack});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  final _supabase = Supabase.instance.client;
  final NumberFormat _nf = NumberFormat("#,##0.00", "it_IT");

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _supabase.from('gruppi').stream(primaryKey: ['id']).eq('id', widget.gruppoId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: CircularProgressIndicator());
        
        final g = snapshot.data!.first;
        final dynamic eventoId = g['evento_id']; // Recuperato per la navigazione

        final double uscite = (g['uscite'] ?? 0).toDouble();
        final double giroconti = (g['giroconti'] ?? 0).toDouble();
        final double saldo = (g['saldo'] ?? 0).toDouble();
        final double costoGruppo = (g['costo_gruppo'] ?? 0).toDouble();
        final double conguaglio = (g['conguaglio'] ?? 0).toDouble();
        final int numeroPersone = g['numero_persone'] ?? 0;
        final String valutaTarget = g['valuta_target'] ?? 'EUR';

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) CANCELLATA l'etichetta 'Gruppo' - mostro solo il titolo
                _buildHeader("", "${g['gruppo'] ?? ''}    x $numeroPersone"),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDataRow(
                        label: "Uscite",
                        value: uscite,
                        icon: Icons.shopping_cart,
                        iconColor: const Color(0xFFC62828),
                        textColor: const Color(0xFFC62828),
                      ),
                    ),
                    Expanded(
                      child: _buildDataRow(
                        label: "Giroconti",
                        value: giroconti,
                        icon: giroconti >= 0 ? Icons.file_download : Icons.file_upload,
                        iconColor: giroconti >= 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                        textColor: giroconti >= 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),

                _buildDataRow(
                  label: "Saldo",
                  value: saldo,
                  icon: Icons.money_sharp,
                  iconColor: saldo <= 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                  textColor: saldo <= 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                ),

                // 2) SPOSTATO Conguaglio a destra di Costo Gruppo sulla stessa riga
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDataRow(
                        label: "Costo Gruppo",
                        value: costoGruppo,
                        icon: Icons.group,
                        iconColor: const Color(0xFF1976D2),
                        textColor: const Color(0xFF1976D2),
                      ),
                    ),
                    Expanded(
                      child: _buildConguaglioRow(conguaglio),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("LISTA SPESE", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.grey, size: 20),
                      onPressed: () => _nuovaSpesa(eventoId),
                    ),
                  ],
                ),
                const Divider(),
                
                _buildSpeseTable(widget.gruppoId, valutaTarget, eventoId),
              ],
            ),
          ),

        );
      },
    );
  }

  // Funzione per navigare all'inserimento
  void _nuovaSpesa(dynamic eventoId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupExpensePage(
          gruppoId: widget.gruppoId,
          eventoId: eventoId,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  // Widget per la Tabella Spese con righe cliccabili per l'edit
  Widget _buildSpeseTable(dynamic gruppoId, String valutaTarget, dynamic eventoId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _supabase
          .from('spese')
          .stream(primaryKey: ['id'])
          .eq('gruppo_id', gruppoId)
          .order('data', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final spese = snapshot.data!;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            horizontalMargin: 0,
            showCheckboxColumn: false,
            columns: [
              const DataColumn(label: Text('Data', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text(valutaTarget, style: const TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('Località', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('Tipologia', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('Causale', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: spese.map((s) {
              DateTime data = DateTime.parse(s['data']);
              return DataRow(
                onSelectChanged: (_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupExpensePage(
                        gruppoId: widget.gruppoId,
                        eventoId: eventoId,
                        spesaIniziale: s,
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },
                cells: [
                  DataCell(Text(DateFormat('dd/MM/yyyy').format(data))),
                  DataCell(Text(_nf.format(s['importo'] ?? 0))),
                  DataCell(Text(s['localita'] ?? '')),
                  DataCell(Text(s['tipologia'] ?? '')),
                  DataCell(Text(s['causale'] ?? '')),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String label, String fullTitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
          ],
          Text(
            fullTitle, 
            style: const TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333)
            )
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow({
    required String label,
    required double value,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  _nf.format(value),
                  style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConguaglioRow(double valore) {
    final bool isPositive = valore >= 0;
    final String labelConguaglio = isPositive ? "Avere: " : "Dare: ";
    final Color color = isPositive ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final IconData icon = isPositive ? Icons.thumb_up : Icons.remove_circle;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Conguaglio", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  "$labelConguaglio ${_nf.format(valore.abs())}",
                  style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}