import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/partecipante.dart';
import '../../exceptions/app_exception.dart';
import '../supabase_service.dart';

/// Repository per gestire i Partecipanti
class PartecipantiRepository {
  final SupabaseService _supabaseService = SupabaseService();

  /// Ottiene tutti i partecipanti di un evento
  Future<List<Partecipante>> getByEventoId(String eventoId) async {
    try {
      final response = await _supabaseService
          .from('partecipanti')
          .select()
          .eq('evento_id', eventoId)
          .order('cellulare');

      return (response as List)
          .map((p) => Partecipante.fromMap(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene tutti i partecipanti di un gruppo
  Future<List<Partecipante>> getByGruppoId(String gruppoId) async {
    try {
      final response = await _supabaseService
          .from('partecipanti')
          .select()
          .eq('gruppo_id', gruppoId)
          .order('cellulare');

      return (response as List)
          .map((p) => Partecipante.fromMap(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene un partecipante per ID
  Future<Partecipante?> getById(String id) async {
    try {
      final response = await _supabaseService
          .from('partecipanti')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Partecipante.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Crea un nuovo partecipante
  Future<Partecipante> create({
    required String eventoId,
    required String cellulare,
    required String gruppoId,
  }) async {
    try {
      final data = {
        'evento_id': eventoId,
        'cellulare': cellulare,
        'gruppo_id': gruppoId,
      };

      final response = await _supabaseService
          .from('partecipanti')
          .insert(data)
          .select();

      return Partecipante.fromMap(response[0] as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Aggiorna un partecipante
  Future<Partecipante> update(
    String id, {
    String? cellulare,
    String? gruppoId,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (cellulare != null) updates['cellulare'] = cellulare;
      if (gruppoId != null) updates['gruppo_id'] = gruppoId;

      final response = await _supabaseService
          .from('partecipanti')
          .update(updates)
          .eq('id', id)
          .select();

      return Partecipante.fromMap(response[0] as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Elimina un partecipante
  Future<void> delete(String id) async {
    try {
      await _supabaseService.from('partecipanti').delete().eq('id', id);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ascolta i cambiamenti dei partecipanti in tempo reale
  Stream<List<Partecipante>> watchByEventoId(String eventoId) {
    try {
      return _supabaseService
          .from('partecipanti')
          .stream(primaryKey: ['id'])
          .eq('evento_id', eventoId)
          .order('cellulare')
          .map((partecipanti) => (partecipanti as List)
              .map((p) => Partecipante.fromMap(p as Map<String, dynamic>))
              .toList());
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ascolta i cambiamenti di un singolo partecipante
  Stream<Partecipante?> watchById(String id) {
    try {
      return _supabaseService
          .from('partecipanti')
          .stream(primaryKey: ['id'])
          .eq('id', id)
          .map((partecipanti) {
            if (partecipanti.isEmpty) return null;
            return Partecipante.fromMap(partecipanti[0] as Map<String, dynamic>);
          });
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene il numero totale di partecipanti per evento
  Future<int> countByEventoId(String eventoId) async {
    try {
      final response = await _supabaseService
          .from('partecipanti')
          .select('id')
          .eq('evento_id', eventoId);

      return response.length;
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene il numero totale di partecipanti per gruppo
  Future<int> countByGruppoId(String gruppoId) async {
    try {
      final response = await _supabaseService
          .from('partecipanti')
          .select('id')
          .eq('gruppo_id', gruppoId);

      return response.length;
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Verifica se un cellulare esiste già nel gruppo
  Future<bool> cellulareEsisteInGruppo(
    String gruppoId,
    String cellulare,
  ) async {
    try {
      final response = await _supabaseService
          .from('partecipanti')
          .select('id')
          .eq('gruppo_id', gruppoId)
          .eq('cellulare', cellulare)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Verifica se un cellulare esiste già nell'evento
  Future<bool> cellulareEsisteInEvento(
    String eventoId,
    String cellulare,
  ) async {
    try {
      final response = await _supabaseService
          .from('partecipanti')
          .select('id')
          .eq('evento_id', eventoId)
          .eq('cellulare', cellulare)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene un partecipante per cellulare
  Future<Partecipante?> getBycellulare(String cellulare) async {
    try {
      final response = await _supabaseService
          .from('partecipanti')
          .select()
          .eq('cellulare', cellulare)
          .maybeSingle();

      if (response == null) return null;
      return Partecipante.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }
}