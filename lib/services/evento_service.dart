import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/evento_model.dart';

class EventoService {
  final supabase = Supabase.instance.client;

  // Funzione di supporto interna per il parsing sicuro delle date
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> caricaDatiEvento(dynamic eventoId) async {
    try {
      final response = await supabase
          .from('eventi')
          .select()
          .eq('id', eventoId)
          .maybeSingle();

      if (response == null) return null;

      // Creiamo una copia della mappa per poter normalizzare le date
      final Map<String, dynamic> datiModificati = Map.from(response);
      
      // Sostituiamo le stringhe grezze con oggetti DateTime reali
      datiModificati['data_inizio'] = _parseDate(response['data_inizio']);
      datiModificati['data_fine'] = _parseDate(response['data_fine']);

      return datiModificati;
    } catch (e) {
      print("Errore caricamento dati evento: $e");
      return null;
    }
  }

  Future<List<String>> loadLocalita(dynamic eventoId) async {
    try {
      final data = await supabase
          .from('localita')
          .select()
          .eq('evento_id', eventoId)
          .order('localita');

      return List<String>.from(data.map((e) => e['localita'].toString()));
    } catch (e) {
      print("Errore caricamento località: $e");
      return [];
    }
  }

  Future<List<String>> loadValute(dynamic eventoId) async {
    try {
      final data = await supabase
          .from('valute')
          .select()
          .eq('evento_id', eventoId)
          .order('valuta');

      return List<String>.from(data.map((e) => e['valuta'].toString()));
    } catch (e) {
      print("Errore caricamento valute: $e");
      return [];
    }
  }

  Future<String> inviaEmailRiepilogo(dynamic eventoId, String emailFallback) async {
    String emailDestinatario = emailFallback;

    try {
      // 1. Recuperiamo l'amministratore_id dell'evento
      final eventoRes = await supabase
          .from('eventi')
          .select('amministratore_id')
          .eq('id', eventoId)
          .maybeSingle();

      if (eventoRes != null && eventoRes['amministratore_id'] != null) {
        // 2. Cerchiamo l'email dell'utente amministratore
        final utenteRes = await supabase
            .from('utenti')
            .select('email')
            .eq('id', eventoRes['amministratore_id'])
            .maybeSingle();

        if (utenteRes != null && utenteRes['email'] != null) {
          emailDestinatario = utenteRes['email'].toString();
        }
      }
    } catch (e) {
      print("Errore recupero email amministratore, uso fallback: $e");
    }

    // 3. Invocazione della Edge Function passando l'email individuata
    await supabase.functions.invoke(
      'send-event-email',
      body: {
        'evento_id': eventoId,
        'emailDestinatario': emailDestinatario,
      },
    );

    // 4. Restituiamo l'email così il widget può mostrarla nello SnackBar
    return emailDestinatario;
  }

  Future<void> eliminaEvento(dynamic eventoId) async {
  final response = await supabase
      .from('eventi')
      .delete()
      .eq('id', eventoId);
      }

  Future<void> salvaEvento({
    required dynamic eventoId,
    required String nome,
    required String? tipoEvento,
    required DateTime? dataInizio,
    required DateTime? dataFine,
    required String? valutaOrigine,
    required String? valutaTarget,
    required String? localita,
//    String? amministratore, 
  }) async {
    await supabase.from('eventi').update({
      'nome': nome,
      'tipo_evento': tipoEvento,
      'data_inizio': dataInizio?.toIso8601String(),
      'data_fine': dataFine?.toIso8601String(),
      'valuta_origine': valutaOrigine,
      'valuta_target': valutaTarget,
//      'amministratore': amministratore,
      'localita': localita,
    }).eq('id', eventoId);
  }

  Future<void> aggiornaStatoEvento({
    required dynamic eventoId, 
    required String nuovoStato,
  }) async {
    await supabase
        .from('eventi')
        .update({'stato': nuovoStato})
        .eq('id', eventoId);
  }

  Future<String> calcolaStatoCorrente(DateTime inizio, DateTime? fine) async {
    final response = await supabase.rpc(
      'fn_evento_calcola_stato',
      params: {
        'inizio': inizio.toIso8601String(),
        'fine': fine?.toIso8601String(),
      },
    );

    if (response == null) {
      return "Preparazione";
    }

    return response.toString();
  }

  Future<EventoModel?> getEventoById(dynamic eventoId) async {
    final response = await supabase
        .from('eventi')
        .select()
        .eq('id', eventoId)
        .maybeSingle();

    if (response == null) return null;
    return EventoModel.fromMap(response);
  }

}