import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/valuta.dart';
import '../../exceptions/app_exception.dart';
import '../supabase_service.dart';

/// Repository per gestire le Valute
class ValutaRepository {
  final SupabaseService _supabaseService = SupabaseService();

  /// Ottiene tutte le valute di un evento
  Future<List<Valuta>> getByEventoId(String eventoId) async {
    try {
      final response = await _supabaseService
          .from('valuta')
          .select()
          .eq('evento_id', eventoId)
          .order('valuta');

      return (response as List)
          .map((v) => Valuta.fromMap(v as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene una valuta per ID
  Future<Valuta?> getById(String id) async {
    try {
      final response = await _supabaseService
          .from('valuta')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Valuta.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Crea una nuova valuta
  Future<Valuta> create({
    required String eventoId,
    required String codice,
  }) async {
    try {
      final data = {
        'evento_id': eventoId,
        'valuta': codice.toUpperCase(),
      };

      final response =
          await _supabaseService.from('valuta').insert(data).select();

      return Valuta.fromMap(response[0] as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Aggiorna una valuta
  Future<Valuta> update(String id, {required String codice}) async {
    try {
      final updates = {'valuta': codice.toUpperCase()};

      final response = await _supabaseService
          .from('valuta')
          .update(updates)
          .eq('id', id)
          .select();

      return Valuta.fromMap(response[0] as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Elimina una valuta
  Future<void> delete(String id) async {
    try {
      await _supabaseService.from('valuta').delete().eq('id', id);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ascolta i cambiamenti delle valute in tempo reale
  Stream<List<Valuta>> watchByEventoId(String eventoId) {
    try {
      return _supabaseService
          .from('valuta')
          .stream(primaryKey: ['id'])
          .eq('evento_id', eventoId)
          .order('valuta')
          .map((valute) => (valute as List)
              .map((v) => Valuta.fromMap(v as Map<String, dynamic>))
              .toList());
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene il numero totale di valute per evento
  Future<int> countByEventoId(String eventoId) async {
    try {
      final response = await _supabaseService
          .from('valuta')
          .select('id')
          .eq('evento_id', eventoId);

      return response.length;
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Verifica se una valuta esiste già per l'evento
  Future<bool> codiceEsiste(String eventoId, String codice) async {
    try {
      final response = await _supabaseService
          .from('valuta')
          .select('id')
          .eq('evento_id', eventoId)
          .eq('valuta', codice.toUpperCase())
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene le valute più comuni (top 10)
  Future<List<String>> getCommonCurrencies() async {
    // Lista di valute comuni - potrebbe venire da una costante
    const common = [
      'EUR',
      'USD',
      'GBP',
      'JPY',
      'CHF',
      'CAD',
      'AUD',
      'NZD',
      'CNY',
      'INR'
    ];
    return common;
  }
}