import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gruppo_model.dart';

class GruppiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Carica tutti i gruppi di un evento mappati come GruppoModel e ordinati
  Future<List<GruppoModel>> loadGruppi(dynamic eventoId) async {
    final response = await _supabase
        .from('gruppi')
        .select()
        .eq('evento_id', eventoId);

    final List<GruppoModel> data = (response as List)
        .map((json) => GruppoModel.fromMap(json))
        .toList();

    // Ordinamento:
    // 1. protected = TRUE → primo
    // 2. gli altri → ordine alfabetico sul nome del gruppo
    data.sort((a, b) {
      if (a.protected && !b.protected) return -1;
      if (!a.protected && b.protected) return 1;
      return a.gruppo.compareTo(b.gruppo);
    });

    return data;
  }

  /// Inserisce un nuovo gruppo e restituisce il suo ID
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

  /// Elimina un gruppo tramite RPC
  Future<void> deleteGruppo(dynamic gruppoId) async {
    await _supabase.rpc('fn_gruppo_delete', params: {'p_gruppo_id': gruppoId});
  }
}