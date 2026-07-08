import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider centralizzato per l'istanza di Supabase
/// Fornisce accesso al client Supabase in tutta l'app
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider per la sessione corrente (user loggato)
/// Ascolta i cambiamenti di autenticazione in tempo reale
/// Include logica di refresh token automatico
final authSessionProvider = StreamProvider<Session?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  
  return supabase.auth.onAuthStateChange.map((event) {
    // Quando il token sta per scadere, Supabase lo rinnova automaticamente
    // Questo listener garantisce che la sessione rimanga sempre valida
    if (event.session != null) {
      final expiresAt = event.session!.expiresAt;
      if (expiresAt != null) {
        final now = DateTime.now();
        final difference = expiresAt.difference(now).inSeconds;
        
        // Se il token sta per scadere tra meno di 60 secondi, lo rinnova
        if (difference < 60 && difference > 0) {
          supabase.auth.refreshSession();
        }
      }
    }
    
    return event.session;
  });
});

/// Provider per lo stato di caricamento autenticazione
final authLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider per il token di accesso corrente
final accessTokenProvider = FutureProvider<String?>((ref) async {
  final session = await ref.watch(authSessionProvider.future);
  return session?.accessToken;
});
