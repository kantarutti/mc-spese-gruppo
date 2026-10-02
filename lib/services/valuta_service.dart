import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/valuta_model.dart';

class ValutaService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ValutaModel>> getValute(dynamic eventoId) async {
    final data = await _supabase
        .from('valute')
        .select()
        .eq('evento_id', eventoId)
        .order('valuta');

    return (data as List)
        .map((json) => ValutaModel.fromJson(json))
        .toList();
  }

  Future<void> addValuta(String valuta, dynamic eventoId) async {
    await _supabase.from('valute').insert({
      'evento_id': eventoId,
      'valuta': valuta,
    });
  }

  Future<void> deleteValuta(int id) async {
    await _supabase.from('valute').delete().eq('id', id);
  }
}