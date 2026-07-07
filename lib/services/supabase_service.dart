import 'package:supabase_flutter/supabase_flutter.dart';

/// Servizio per gestire la connessione a Supabase
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  /// Ottiene l'istanza di Supabase
  SupabaseClient get client => Supabase.instance.client;

  /// Ottiene la sessione corrente
  Session? get currentSession => client.auth.currentSession;

  /// Ottiene l'utente corrente
  User? get currentUser => client.auth.currentUser;

  /// Verifica se l'utente è autenticato
  bool get isAuthenticated => currentUser != null;

  /// Ottiene un reference a una tabella
  PostgrestFilterBuilder from(String table) {
    return client.from(table).select();
  }

  /// Inserisce dati in una tabella
  Future<List<dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client.from(table).insert([data]).select();
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Inserisce più righe
  Future<List<dynamic>> insertMultiple(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final response = await client.from(table).insert(data).select();
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Aggiorna dati in una tabella
  Future<List<dynamic>> update(
    String table,
    Map<String, dynamic> data,
    String columnName,
    dynamic value,
  ) async {
    try {
      final response = await client
          .from(table)
          .update(data)
          .eq(columnName, value)
          .select();
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Elimina dati da una tabella
  Future<void> delete(
    String table,
    String columnName,
    dynamic value,
  ) async {
    try {
      await client.from(table).delete().eq(columnName, value);
    } catch (e) {
      rethrow;
    }
  }

  /// Ottiene tutti i dati da una tabella
  Future<List<dynamic>> getAll(String table) async {
    try {
      final response = await client.from(table).select();
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Ottiene un singolo record
  Future<Map<String, dynamic>?> getSingle(
    String table,
    String columnName,
    dynamic value,
  ) async {
    try {
      final response = await client
          .from(table)
          .select()
          .eq(columnName, value)
          .maybeSingle();
      return response as Map<String, dynamic>?;
    } catch (e) {
      rethrow;
    }
  }

  /// Ascolta i cambiamenti in tempo reale
  Stream<List<Map<String, dynamic>>> listen(
    String table, {
    String? filter,
    dynamic filterValue,
  }) {
    try {
      final query = client.from(table).stream(primaryKey: ['id']);

      if (filter != null && filterValue != null) {
        return query
            .eq(filter, filterValue)
            .map((data) => List<Map<String, dynamic>>.from(data));
      }

      return query.map((data) => List<Map<String, dynamic>>.from(data));
    } catch (e) {
      throw Exception('Errore nel listening: $e');
    }
  }

  /// Ascolta un singolo record
  Stream<Map<String, dynamic>?> listenSingle(
    String table,
    String columnName,
    dynamic value,
  ) {
    try {
      return client
          .from(table)
          .stream(primaryKey: ['id'])
          .eq(columnName, value)
          .map((data) {
        if (data.isEmpty) return null;
        return Map<String, dynamic>.from(data.first);
      });
    } catch (e) {
      throw Exception('Errore nel listening: $e');
    }
  }

  /// Esegue una query personalizzata con filtri
  Future<List<dynamic>> query(
    String table,
    List<({String column, dynamic value})> filters,
  ) async {
    try {
      var query = client.from(table).select();

      for (final filter in filters) {
        query = query.eq(filter.column, filter.value);
      }

      final response = await query;
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Conta il numero di record
  Future<int> count(
    String table, {
    String? filterColumn,
    dynamic filterValue,
  }) async {
    try {
      var query = client.from(table).select();

      if (filterColumn != null && filterValue != null) {
        query = query.eq(filterColumn, filterValue);
      }

      final response = await query;
      
      // Conta manualmente i risultati
      if (response is List) {
        return response.length;
      }
      return 0;
    } catch (e) {
      rethrow;
    }
  }

  /// Effettua il logout
  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Verifica la connessione
  Future<bool> checkConnection() async {
    try {
      final response = await client.from('eventi').select().limit(1);
      return response.isNotEmpty || response.isEmpty; // Sempre true se non crasha
    } catch (e) {
      return false;
    }
  }
}