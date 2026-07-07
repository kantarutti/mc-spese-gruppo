import '../supabase_service.dart';
import '../../models/models.dart';

/// Repository per gestire i gruppi
class GruppiRepository {
  final SupabaseService _supabaseService = SupabaseService();

  static const String _tableName = 'gruppi';

  /// Ottiene tutti i gruppi
  Future<List<Gruppo>> getAll() async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select();

      return (response as List<dynamic>)
          .map((e) => Gruppo.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Errore nel caricamento dei gruppi: $e');
    }
  }

  /// Ottiene un gruppo per ID
  Future<Gruppo?> getById(String id) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Gruppo.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Errore nel caricamento del gruppo: $e');
    }
  }

  /// Ottiene i gruppi per evento
  Future<List<Gruppo>> getByEventoId(String eventoId) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .eq('evento_id', eventoId);

      return (response as List<dynamic>)
          .map((e) => Gruppo.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Errore nel caricamento dei gruppi: $e');
    }
  }

  /// Crea un nuovo gruppo
  Future<Gruppo> create(Gruppo gruppo) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .insert(gruppo.toMap())
          .select()
          .single();

      return Gruppo.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Errore nella creazione del gruppo: $e');
    }
  }

  /// Aggiorna un gruppo
  Future<Gruppo> update(Gruppo gruppo) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .update(gruppo.toMap())
          .eq('id', gruppo.id)
          .select()
          .single();

      return Gruppo.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Errore nell\'aggiornamento del gruppo: $e');
    }
  }

  /// Elimina un gruppo
  Future<void> delete(String id) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Errore nell\'eliminazione del gruppo: $e');
    }
  }

  /// Ascolta i cambiamenti dei gruppi in tempo reale
  Stream<List<Gruppo>> watchAll() {
    try {
      return _supabaseService.client
          .from(_tableName)
          .stream(primaryKey: ['id'])
          .map((data) => (data as List<dynamic>)
              .map((e) => Gruppo.fromMap(e as Map<String, dynamic>))
              .toList());
    } catch (e) {
      throw Exception('Errore nel watching dei gruppi: $e');
    }
  }

  /// Ascolta i cambiamenti dei gruppi di un evento
  Stream<List<Gruppo>> watchByEventoId(String eventoId) {
    try {
      return _supabaseService.client
          .from(_tableName)
          .stream(primaryKey: ['id'])
          .eq('evento_id', eventoId)
          .map((data) => (data as List<dynamic>)
              .map((e) => Gruppo.fromMap(e as Map<String, dynamic>))
              .toList());
    } catch (e) {
      throw Exception('Errore nel watching dei gruppi: $e');
    }
  }

  /// Conta i gruppi per evento
  Future<int> countByEventoId(String eventoId) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .eq('evento_id', eventoId);

      return (response as List<dynamic>).length;
    } catch (e) {
      throw Exception('Errore nel conteggio dei gruppi: $e');
    }
  }

  /// Cerca i gruppi per nome
  Future<List<Gruppo>> searchByName(String name) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .ilike('gruppo', '%$name%');

      return (response as List<dynamic>)
          .map((e) => Gruppo.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Errore nella ricerca dei gruppi: $e');
    }
  }

  /// Aggiorna solo i campi di calcolo (uscite, saldo, conguaglio)
  Future<Gruppo> updateCalculations(
    String id, {
    required double uscite,
    required double giroconti,
    required double saldo,
    required double costoGruppo,
    required double conguaglio,
  }) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .update({
            'uscite': uscite,
            'giroconti': giroconti,
            'saldo': saldo,
            'costo_gruppo': costoGruppo,
            'conguaglio': conguaglio,
          })
          .eq('id', id)
          .select()
          .single();

      return Gruppo.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Errore nell\'aggiornamento dei calcoli: $e');
    }
  }
}