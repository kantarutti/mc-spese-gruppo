import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/evento.dart';
import 'supabase_provider.dart';

/// Provider per il caricamento di un singolo evento
final eventoDetailProvider =
    FutureProvider.family<Evento, String>((ref, eventoId) async {
  final supabase = ref.watch(supabaseProvider);

  try {
    final response = await supabase
        .from('eventi')
        .select()
        .eq('id', eventoId)
        .single();

    return Evento.fromMap(response as Map<String, dynamic>);
  } catch (e) {
    print('Errore caricamento evento: $e');
    rethrow;
  }
});

/// Provider per l'aggiornamento di un evento
final updateEventProvider = FutureProvider.family<void, UpdateEventParams>(
  (ref, params) async {
    final supabase = ref.watch(supabaseProvider);

    try {
      await supabase
          .from('eventi')
          .update(params.toMap())
          .eq('id', params.id);

      // Invalida il provider del dettaglio evento
      ref.invalidate(eventoDetailProvider);
      ref.invalidate(eventoDetailProvider(params.id));
    } catch (e) {
      print('Errore aggiornamento evento: $e');
      rethrow;
    }
  },
);

/// Parametri per l'aggiornamento di un evento
class UpdateEventParams {
  final String id;
  final String? nome;
  final String? localita;
  final DateTime? dataInizio;
  final DateTime? dataFine;
  final String? organizzatore;
  final int? persone;
  final String? valutaOrigine;
  final String? valutaTarget;
  final String? stato;

  UpdateEventParams({
    required this.id,
    this.nome,
    this.localita,
    this.dataInizio,
    this.dataFine,
    this.organizzatore,
    this.persone,
    this.valutaOrigine,
    this.valutaTarget,
    this.stato,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (nome != null) map['nome'] = nome;
    if (localita != null) map['localita'] = localita;
    if (dataInizio != null) map['data_inizio'] = dataInizio!.toIso8601String();
    if (dataFine != null) map['data_fine'] = dataFine!.toIso8601String();
    if (organizzatore != null) map['organizzatore'] = organizzatore;
    if (persone != null) map['persone'] = persone;
    if (valutaOrigine != null) map['valuta_origine'] = valutaOrigine;
    if (valutaTarget != null) map['valuta_target'] = valutaTarget;
    if (stato != null) map['stato'] = stato;
    return map;
  }
}
