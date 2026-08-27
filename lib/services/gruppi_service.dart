import 'package:supabase_flutter/supabase_flutter.dart';

class GruppiService {
  final SupabaseClient _supabase = Supabase.instance.client;

/// Carica tutti i gruppi di un evento
Future<List<Map<String, dynamic>>> loadGruppi(dynamic eventoId) async {
  final response = await _supabase
      .from('gruppi')
      .select()
      .eq('evento_id', eventoId);

  final data = List<Map<String, dynamic>>.from(response);

  // ⭐ Ordinamento:
  // 1. protected = TRUE → primo
  // 2. gli altri → ordine alfabetico
  data.sort((a, b) {
    final ap = a['protected'] == true;
    final bp = b['protected'] == true;

    // Se A è protetto e B no → A prima
    if (ap && !bp) return -1;

    // Se B è protetto e A no → B prima
    if (!ap && bp) return 1;

    // Se nessuno è protetto → ordine alfabetico
    return (a['gruppo'] ?? '').compareTo(b['gruppo'] ?? '');
  });

  return data;
}

  /// Inserisce un nuovo gruppo
Future<dynamic> insertGruppo({
  required dynamic eventoId,
  required String nomeGruppo,
  required int numeroPersone,
}) async {
  final response = await _supabase
      .from('gruppi')
      .insert({
        'evento_id': eventoId,
        'gruppo': nomeGruppo,
        'numero_persone': numeroPersone,
      })
      .select('id')
      .single();

  return response['id'];
}

  /// Aggiorna un gruppo esistente
  Future<void> updateGruppo({
    required dynamic gruppoId,
    required String nome,
    required int numeroPersone,
  }) async {
    await _supabase
        .from('gruppi')
        .update({
          'gruppo': nome,
          'numero_persone': numeroPersone,
        })
        .eq('id', gruppoId);
  }

  /// Elimina un gruppo
  Future<void> deleteGruppo(dynamic gruppoId) async {
await _supabase.rpc('delete_gruppo', params: {'p_gruppo_id': gruppoId});
  }

}
