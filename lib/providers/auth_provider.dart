import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';
import 'supabase_provider.dart';

/// Provider per l'utente corrente loggato
/// Legge dal DB basandosi sulla sessione di autenticazione
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final session = await ref.watch(authSessionProvider.future);
  
  if (session == null) {
    return null;
  }

  try {
    final supabase = ref.watch(supabaseProvider);
    final response = await supabase
        .from('utenti')
        .select()
        .eq('id', session.user.id)
        .maybeSingle();

    if (response != null) {
      return AppUser.fromMap(response);
    }
    return null;
  } catch (e) {
    print('Errore caricamento utente: $e');
    return null;
  }
});

/// Provider per il logout
/// Esegue il logout e invalida i provider dipendenti
final logoutProvider = FutureProvider((ref) async {
  final supabase = ref.watch(supabaseProvider);
  await supabase.auth.signOut();
  // Invalida il provider dell'utente corrente
  ref.invalidate(currentUserProvider);
});

/// Provider per il login con cellulare e codice
final loginProvider = FutureProvider.family<AppUser?, LoginParams>(
  (ref, params) async {
    final supabase = ref.watch(supabaseProvider);
    
    try {
      final response = await supabase
          .from('utenti')
          .select()
          .eq('cellulare', params.cellulare.trim())
          .maybeSingle();

      if (response == null) {
        throw 'Utente non trovato';
      }

      if (response['codice_personale'] != params.codice) {
        throw 'Codice personale errato';
      }

      // Invalida il provider dell'utente per forzare il refresh
      ref.invalidate(currentUserProvider);
      
      return AppUser.fromMap(response);
    } catch (e) {
      rethrow;
    }
  },
);

/// Parametri per il login
class LoginParams {
  final String cellulare;
  final String codice;

  LoginParams({
    required this.cellulare,
    required this.codice,
  });
}
