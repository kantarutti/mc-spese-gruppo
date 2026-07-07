import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/localita.dart';
import '../../exceptions/app_exception.dart';
import '../supabase_service.dart';

/// Repository per gestire le Località
class LocalitaRepository {
  final SupabaseService _supabaseService = SupabaseService();

  /// Ottiene tutte le località di un evento
  Future<List<Localita>> getByEventoId(String eventoId) async {
    try {
      final response = await _supabaseService.client
          .from('localita')
          .select()
          .eq('evento_id', eventoId)
          .order('localita');

      return (response as List)
          .map((l) => Localita.fromMap(l as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene una località per ID
  Future<Localita?> getById(String id) async {
    try {
      final response = await _supabaseService.client
          .from('localita')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Localita.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Crea una nuova località
  Future<Localita> create({
    required String eventoId,
    required String nome,
  }) async {
    try {
      final data = {
        'evento_id': eventoId,
        'localita': nome,
      };

      final response = await _supabaseService.client
          .from('localita')
          .insert(data)
          .select();

      return Localita.fromMap(response[0] as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Aggiorna una località
  Future<Localita> update(String id, {required String nome}) async {
    try {
      final updates = {'localita': nome};

      final response = await _supabaseService.client
          .from('localita')
          .update(updates)
          .eq('id', id)
          .select();

      return Localita.fromMap(response[0] as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Elimina una località
  Future<void> delete(String id) async {
    try {
      await _supabaseService.client
          .from('localita')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ascolta i cambiamenti delle località in tempo reale
  Stream<List<Localita>> watchByEventoId(String eventoId) {
    try {
      return _supabaseService.client
          .from('localita')
          .stream(primaryKey: ['id'])
          .eq('evento_id', eventoId)
          .order('localita')
          .map((localita) => (localita as List)
              .map((l) => Localita.fromMap(l as Map<String, dynamic>))
              .toList());
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene il numero totale di località per evento
  Future<int> countByEventoId(String eventoId) async {
    try {
      final response = await _supabaseService.client
          .from('localita')
          .select('id')
          .eq('evento_id', eventoId);

      return response.length;
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Verifica se una località esiste già per l'evento
  Future<bool> nomeEsiste(String eventoId, String nome) async {
    try {
      final response = await _supabaseService.client
          .from('localita')
          .select('id')
          .eq('evento_id', eventoId)
          .eq('localita', nome)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }
}
