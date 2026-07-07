import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/spesa.dart';
import '../../exceptions/app_exception.dart';
import '../supabase_service.dart';

/// Repository per gestire le Spese
class SpeseRepository {
  final SupabaseService _supabaseService = SupabaseService();

  /// Ottiene tutte le spese di un evento
  Future<List<Spesa>> getByEventoId(String eventoId) async {
    try {
      final response = await _supabaseService
          .from('spese')
          .select()
          .eq('evento_id', eventoId)
          .order('data', ascending: false);

      return (response as List)
          .map((s) => Spesa.fromMap(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene tutte le spese di un gruppo
  Future<List<Spesa>> getByGruppoId(String gruppoId) async {
    try {
      final response = await _supabaseService
          .from('spese')
          .select()
          .eq('gruppo_id', gruppoId)
          .order('data', ascending: false);

      return (response as List)
          .map((s) => Spesa.fromMap(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene una spesa per ID
  Future<Spesa?> getById(String id) async {
    try {
      final response = await _supabaseService
          .from('spese')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Spesa.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Crea una nuova spesa
  Future<Spesa> create({
    required String eventoId,
    required String gruppoId,
    required DateTime data,
    String? localita,
    String? tipologia,
    String? causale,
    required double spesa,
    required String valutaOrigine,
    required double importo,
    required String valutaTarget,
    required double tassoCambio,
  }) async {
    try {
      final data_map = {
        'evento_id': eventoId,
        'gruppo_id': gruppoId,
        'data': data.toIso8601String(),
        'localita': localita,
        'tipologia': tipologia,
        'causale': causale,
        'spesa': spesa,
        'valuta_origine': valutaOrigine,
        'importo': importo,
        'valuta_target': valutaTarget,
        'tasso_cambio': tassoCambio,
      };

      final response =
          await _supabaseService.from('spese').insert(data_map).select();

      return Spesa.fromMap(response[0] as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Aggiorna una spesa
  Future<Spesa> update(
    String id, {
    DateTime? data,
    String? localita,
    String? tipologia,
    String? causale,
    double? spesa,
    String? valutaOrigine,
    double? importo,
    String? valutaTarget,
    double? tassoCambio,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (data != null) updates['data'] = data.toIso8601String();
      if (localita != null) updates['localita'] = localita;
      if (tipologia != null) updates['tipologia'] = tipologia;
      if (causale != null) updates['causale'] = causale;
      if (spesa != null) updates['spesa'] = spesa;
      if (valutaOrigine != null) updates['valuta_origine'] = valutaOrigine;
      if (importo != null) updates['importo'] = importo;
      if (valutaTarget != null) updates['valuta_target'] = valutaTarget;
      if (tassoCambio != null) updates['tasso_cambio'] = tassoCambio;

      final response = await _supabaseService
          .from('spese')
          .update(updates)
          .eq('id', id)
          .select();

      return Spesa.fromMap(response[0] as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Elimina una spesa
  Future<void> delete(String id) async {
    try {
      await _supabaseService.from('spese').delete().eq('id', id);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ascolta i cambiamenti delle spese in tempo reale
  Stream<List<Spesa>> watchByEventoId(String eventoId) {
    try {
      return _supabaseService
          .from('spese')
          .stream(primaryKey: ['id'])
          .eq('evento_id', eventoId)
          .order('data', ascending: false)
          .map((spese) => (spese as List)
              .map((s) => Spesa.fromMap(s as Map<String, dynamic>))
              .toList());
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ascolta i cambiamenti di una singola spesa
  Stream<Spesa?> watchById(String id) {
    try {
      return _supabaseService
          .from('spese')
          .stream(primaryKey: ['id'])
          .eq('id', id)
          .map((spese) {
            if (spese.isEmpty) return null;
            return Spesa.fromMap(spese[0] as Map<String, dynamic>);
          });
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene il totale delle spese per un evento
  Future<double> getTotalByEventoId(String eventoId) async {
    try {
      final spese = await getByEventoId(eventoId);
      return spese.fold<double>(0, (sum, spesa) => sum + spesa.importo);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene il totale delle spese per un gruppo
  Future<double> getTotalByGruppoId(String gruppoId) async {
    try {
      final spese = await getByGruppoId(gruppoId);
      return spese.fold<double>(0, (sum, spesa) => sum + spesa.importo);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene le spese per tipologia
  Future<List<Spesa>> getByTipologia(String eventoId, String tipologia) async {
    try {
      final response = await _supabaseService
          .from('spese')
          .select()
          .eq('evento_id', eventoId)
          .eq('tipologia', tipologia)
          .order('data', ascending: false);

      return (response as List)
          .map((s) => Spesa.fromMap(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene le spese per località
  Future<List<Spesa>> getByLocalita(String eventoId, String localita) async {
    try {
      final response = await _supabaseService
          .from('spese')
          .select()
          .eq('evento_id', eventoId)
          .eq('localita', localita)
          .order('data', ascending: false);

      return (response as List)
          .map((s) => Spesa.fromMap(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene le spese in un intervallo di date
  Future<List<Spesa>> getByDateRange(
    String eventoId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabaseService
          .from('spese')
          .select()
          .eq('evento_id', eventoId)
          .gte('data', startDate.toIso8601String())
          .lte('data', endDate.toIso8601String())
          .order('data', ascending: false);

      return (response as List)
          .map((s) => Spesa.fromMap(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene il numero totale di spese per evento
  Future<int> countByEventoId(String eventoId) async {
    try {
      final response = await _supabaseService
          .from('spese')
          .select('id')
          .eq('evento_id', eventoId);

      return response.length;
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene la spesa media per gruppo
  Future<double> getAverageByEventoId(String eventoId) async {
    try {
      final total = await getTotalByEventoId(eventoId);
      final count = await countByEventoId(eventoId);

      if (count == 0) return 0;
      return total / count;
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }
}