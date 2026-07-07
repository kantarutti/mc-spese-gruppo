import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/evento.dart';
import 'supabase_provider.dart';

/// Provider per la lista di tutti gli eventi dell'utente loggato
/// Ritorna un FutureProvider che carica gli eventi dal DB
final eventiProvider = FutureProvider<List<Evento>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  
  try {
    final response = await supabase
        .from('eventi')
        .select()
        .order('data_inizio', ascending: false);
    
    return (response as List)
        .map((e) => Evento.fromMap(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('Errore caricamento eventi: $e');
    rethrow;
  }
});

/// Provider per Stream di eventi (aggiornamento in tempo reale)
final eventiStreamProvider = StreamProvider<List<Evento>>((ref) async* {
  final supabase = ref.watch(supabaseProvider);
  
  yield* supabase
      .from('eventi')
      .stream(primaryKey: ['id'])
      .order('data_inizio', ascending: false)
      .map((events) => events
          .map((e) => Evento.fromMap(e as Map<String, dynamic>))
          .toList());
});

/// Provider per il caricamento dello stato durante creazione nuovo evento
final creatingEventProvider = StateProvider<bool>((ref) => false);

/// Provider per creare un nuovo evento
final createEventProvider = FutureProvider.family<String?, CreateEventParams>(
  (ref, params) async {
    final supabase = ref.watch(supabaseProvider);
    ref.read(creatingEventProvider.notifier).state = true;
    
    try {
      final response = await supabase
          .from('eventi')
          .insert({
            'nome': params.nome,
            'tipo_evento': params.tipoEvento,
            'stato': 'Creazione',
          })
          .select()
          .single();
      
      // Invalida il provider della lista eventi per forzare refresh
      ref.invalidate(eventiStreamProvider);
      ref.invalidate(eventiProvider);
      
      return response['id'] as String;
    } catch (e) {
      print('Errore creazione evento: $e');
      rethrow;
    } finally {
      ref.read(creatingEventProvider.notifier).state = false;
    }
  },
);

/// Parametri per la creazione di un nuovo evento
class CreateEventParams {
  final String nome;
  final String tipoEvento;

  CreateEventParams({
    required this.nome,
    required this.tipoEvento,
  });
}
