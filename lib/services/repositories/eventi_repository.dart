import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_service.dart';
import '../../models/models.dart';

/// Repository per gestire gli eventi
class EventiRepository {
  final SupabaseService _supabaseService = SupabaseService();

  static const String _tableName = 'eventi';

  /// Ottiene tutti gli eventi
  Future<List<Evento>> getAll() async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select();
      
      return (response as List<dynamic>)
          .map((e) => Evento.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Errore nel caricamento degli eventi: $e');
    }
  }

  /// Ottiene un evento per ID
  Future<Evento?> getById(String id) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Evento.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Errore nel caricamento dell\'evento: $e');
    }
  }

  /// Ottiene gli eventi per gruppo
  Future<List<Evento>> getByGruppoId(String gruppoId) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .eq('gruppo_id', gruppoId);

      return (response as List<dynamic>)
          .map((e) => Evento.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Errore nel caricamento degli eventi: $e');
    }
  }

  /// Crea un nuovo evento
  Future<Evento> create(Evento evento) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .insert(evento.toJson())
          .select()
          .single();

      return Evento.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Errore nella creazione dell\'evento: $e');
    }
  }

  /// Aggiorna un evento
  Future<Evento> update(Evento evento) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .update(evento.toJson())
          .eq('id', evento.id)
          .select()
          .single();

      return Evento.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Errore nell\'aggiornamento dell\'evento: $e');
    }
  }

  /// Elimina un evento
  Future<void> delete(String id) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Errore nell\'eliminazione dell\'evento: $e');
    }
  }

  /// Ascolta i cambiamenti degli eventi in tempo reale
  Stream<List<Evento>> watchAll() {
    try {
      return _supabaseService.client
          .from(_tableName)
          .stream(primaryKey: ['id'])
          .map((data) => (data as List<dynamic>)
              .map((e) => Evento.fromJson(e as Map<String, dynamic>))
              .toList());
    } catch (e) {
      throw Exception('Errore nel watching degli eventi: $e');
    }
  }

  /// Ascolta i cambiamenti degli eventi di un gruppo
  Stream<List<Evento>> watchByGruppoId(String gruppoId) {
    try {
      return _supabaseService.client
          .from(_tableName)
          .stream(primaryKey: ['id'])
          .eq('gruppo_id', gruppoId)
          .map((data) => (data as List<dynamic>)
              .map((e) => Evento.fromJson(e as Map<String, dynamic>))
              .toList());
    } catch (e) {
      throw Exception('Errore nel watching degli eventi: $e');
    }
  }

  /// Conta gli eventi per gruppo
  Future<int> countByGruppoId(String gruppoId) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .eq('gruppo_id', gruppoId);

      return (response as List<dynamic>).length;
    } catch (e) {
      throw Exception('Errore nel conteggio degli eventi: $e');
    }
  }

  /// Cerca gli eventi per nome
  Future<List<Evento>> searchByName(String name) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .ilike('nome', '%$name%');

      return (response as List<dynamic>)
          .map((e) => Evento.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Errore nella ricerca degli eventi: $e');
    }
  }
}