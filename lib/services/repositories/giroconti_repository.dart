import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/giroconto.dart';
import '../../exceptions/app_exception.dart';
import '../supabase_service.dart';

/// Repository per gestire i Giroconti (trasferimenti tra gruppi)
class GircontiRepository {
  final SupabaseService _supabaseService = SupabaseService();

  /// Ottiene tutti i giroconti di un evento
  Future<List<Giroconto>> getByEventoId(String eventoId) async {
    try {
      final response = await _supabaseService.client
          .from('giroconti')
          .select()
          .eq('evento_id', eventoId)
          .order('data_giroconto', ascending: false);

      return (response as List)
          .map((g) => Giroconto.fromMap(g as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene i giroconti da un gruppo
  Future<List<Giroconto>> getByDaGruppoId(String daGruppoId) async {
    try {
      final response = await _supabaseService.client
          .from('giroconti')
          .select()
          .eq('da_gruppo_id', daGruppoId)
          .order('data_giroconto', ascending: false);

      return (response as List)
          .map((g) => Giroconto.fromMap(g as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene i giroconti verso un gruppo
  Future<List<Giroconto>> getByAGruppoId(String aGruppoId) async {
    try {
      final response = await _supabaseService.client
          .from('giroconti')
          .select()
          .eq('a_gruppo_id', aGruppoId)
          .order('data_giroconto', ascending: false);

      return (response as List)
          .map((g) => Giroconto.fromMap(g as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene un giroconto per ID
  Future<Giroconto?> getById(String id) async {
    try {
      final response = await _supabaseService.client
          .from('giroconti')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Giroconto.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Crea un nuovo giroconto
  Future<Giroconto> create({
    required String eventoId,
    required String daGruppoId,
    required String aGruppoId,
    required DateTime dataGiroconto,
    required double importo,
    required String valutaOrigine,
    required double giroconto,
    required String valutaTarget,
    required double tassoCambio,
  }) async {
    try {
      final data = {
        'evento_id': eventoId,
        'da_gruppo_id': daGruppoId,
        'a_gruppo_id': aGruppoId,
        'data_giroconto': dataGiroconto.toIso8601String(),
        'importo': importo,
        'valuta_origine': valutaOrigine,
        'giroconto': giroconto,
        'valuta_target': valutaTarget,
        'tasso_cambio': tassoCambio,
      };

      final response = await _supabaseService.client
          .from('giroconti')
          .insert(data)
          .select();

      return Giroconto.fromMap(response[0] as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Aggiorna un giroconto
  Future<Giroconto> update(
    String id, {
    DateTime? dataGiroconto,
    double? importo,
    String? valutaOrigine,
    double? giroconto,
    String? valutaTarget,
    double? tassoCambio,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (dataGiroconto != null) updates['data_giroconto'] = dataGiroconto.toIso8601String();
      if (importo != null) updates['importo'] = importo;
      if (valutaOrigine != null) updates['valuta_origine'] = valutaOrigine;
      if (giroconto != null) updates['giroconto'] = giroconto;
      if (valutaTarget != null) updates['valuta_target'] = valutaTarget;
      if (tassoCambio != null) updates['tasso_cambio'] = tassoCambio;

      final response = await _supabaseService.client
          .from('giroconti')
          .update(updates)
          .eq('id', id)
          .select();

      return Giroconto.fromMap(response[0] as Map<String, dynamic>);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Elimina un giroconto
  Future<void> delete(String id) async {
    try {
      await _supabaseService.client
          .from('giroconti')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ascolta i cambiamenti dei giroconti in tempo reale
  Stream<List<Giroconto>> watchByEventoId(String eventoId) {
    try {
      return _supabaseService.client
          .from('giroconti')
          .stream(primaryKey: ['id'])
          .eq('evento_id', eventoId)
          .order('data_giroconto', ascending: false)
          .map((giroconti) => (giroconti as List)
              .map((g) => Giroconto.fromMap(g as Map<String, dynamic>))
              .toList());
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ascolta i cambiamenti di un singolo giroconto
  Stream<Giroconto?> watchById(String id) {
    try {
      return _supabaseService.client
          .from('giroconti')
          .stream(primaryKey: ['id'])
          .eq('id', id)
          .map((giroconti) {
            if (giroconti.isEmpty) return null;
            return Giroconto.fromMap(giroconti[0] as Map<String, dynamic>);
          });
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene il totale dei giroconti per un evento
  Future<double> getTotalByEventoId(String eventoId) async {
    try {
      final giroconti = await getByEventoId(eventoId);
      return giroconti.fold<double>(0, (sum, g) => sum + g.giroconto);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene il totale in uscita da un gruppo
  Future<double> getTotalDaGruppoId(String daGruppoId) async {
    try {
      final giroconti = await getByDaGruppoId(daGruppoId);
      return giroconti.fold<double>(0, (sum, g) => sum + g.giroconto);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene il totale in entrata verso un gruppo
  Future<double> getTotalAGruppoId(String aGruppoId) async {
    try {
      final giroconti = await getByAGruppoId(aGruppoId);
      return giroconti.fold<double>(0, (sum, g) => sum + g.giroconto);
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene i giroconti in un intervallo di date
  Future<List<Giroconto>> getByDateRange(
    String eventoId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabaseService.client
          .from('giroconti')
          .select()
          .eq('evento_id', eventoId)
          .gte('data_giroconto', startDate.toIso8601String())
          .lte('data_giroconto', endDate.toIso8601String())
          .order('data_giroconto', ascending: false);

      return (response as List)
          .map((g) => Giroconto.fromMap(g as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Ottiene il numero totale di giroconti per evento
  Future<int> countByEventoId(String eventoId) async {
    try {
      final response = await _supabaseService.client
          .from('giroconti')
          .select('id')
          .eq('evento_id', eventoId);

      return response.length;
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// Verifica se esiste un giroconto tra i due gruppi
  Future<bool> esiste(
    String eventoId,
    String daGruppoId,
    String aGruppoId,
  ) async {
    try {
      final response = await _supabaseService.client
          .from('giroconti')
          .select('id')
          .eq('evento_id', eventoId)
          .eq('da_gruppo_id', daGruppoId)
          .eq('a_gruppo_id', aGruppoId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }
}
