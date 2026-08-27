import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class GroupsTab extends StatelessWidget {
  final dynamic eventoId;
  final Function(dynamic) onGruppoTap; // Callback per cambiare vista nella shell

  const GroupsTab({super.key, required this.eventoId, required this.onGruppoTap});

  @override
  Widget build(BuildContext context) {
    final _supabase = Supabase.instance.client;
    final _nf = NumberFormat("#,##0.00", "it_IT");

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _supabase.from('gruppi').stream(primaryKey: ['id']).eq('evento_id', eventoId).order('gruppo'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final gruppi = snapshot.data ?? [];
        if (gruppi.isEmpty) return const Center(child: Text("Nessun gruppo trovato."));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 15),
          itemCount: gruppi.length,
          itemBuilder: (context, index) {
            final g = gruppi[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFF00B2FF), child: Icon(Icons.group, color: Colors.white)),
                title: Text(g['gruppo'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${g['numero_persone']} Persone"),
                //trailing: const Icon(Icons.chevron_right),

// RIGHE DA MODIFICARE (circa riga 31)
trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Builder(
      builder: (context) {
        final double conguaglio = (g['conguaglio'] ?? 0).toDouble();
        final bool isPositive = conguaglio >= 0;
        final Color color = isPositive ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
        final IconData icon = isPositive ? Icons.thumb_up : Icons.remove_circle;
        final String label = isPositive ? "Avere" : "Dare";

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              _nf.format(conguaglio.abs()),
              style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    ),
    const SizedBox(width: 8),
    const Icon(Icons.chevron_right, color: Colors.grey),
  ],
),

                onTap: () => onGruppoTap(g['id']), // Avvisa la Shell
              ),
            );
          },
        );
      },
    );
  }
}