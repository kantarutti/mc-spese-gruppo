import 'package:supabase_flutter/supabase_flutter.dart';

class EventService {
  final supabase = Supabase.instance.client;

  Future<void> salvaEvento({
    required dynamic eventoId,
    required String nome,
    required String? tipoEvento,
    required DateTime? dataInizio,
    required DateTime? dataFine,
    required String? valutaOrigine,
    required String? valutaTarget,
    required String? localita,
    String? organizzatore, 
  }) async {
    await supabase.from('eventi').update({
      'nome': nome,
      'tipo_evento': tipoEvento,
      'data_inizio': dataInizio?.toIso8601String(),
      'data_fine': dataFine?.toIso8601String(),
      'valuta_origine': valutaOrigine,
      'valuta_target': valutaTarget,
      'organizzatore': organizzatore,
      'localita' : localita,
    }).eq('id', eventoId);
  }
}
