import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/localita_model.dart';

class LocalitaService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<LocalitaModel>> getLocalita(dynamic eventoId) async {
    final data = await _supabase
        .from('localita')
        .select()
        .eq('evento_id', eventoId)
        .order('localita');

    return (data as List)
        .map((json) => LocalitaModel.fromJson(json))
        .toList();
  }

  Future<void> addLocalita(String localita, dynamic eventoId) async {
    await _supabase.from('localita').insert({
      'localita': localita,
      'evento_id': eventoId,
    });
  }

  Future<void> updateLocalita(int id, String nuovaLocalita) async {
    await _supabase
        .from('localita')
        .update({'localita': nuovaLocalita})
        .eq('id', id);
  }

  Future<void> deleteLocalita(int id) async {
    await _supabase.from('localita').delete().eq('id', id);
  }
}