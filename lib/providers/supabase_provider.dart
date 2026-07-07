import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider centralizzato per l'istanza di Supabase
/// Fornisce accesso al client Supabase in tutta l'app
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider per la sessione corrente (user loggato)
/// Ascolta i cambiamenti di autenticazione in tempo reale
final authSessionProvider = StreamProvider<Session?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange.map((event) => event.session);
});

/// Provider per lo stato di caricamento autenticazione
final authLoadingProvider = StateProvider<bool>((ref) => false);
