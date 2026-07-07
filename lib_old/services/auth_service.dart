import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static AppUser? currentUser;

  // Carica i dati dell'utente nel modello globale (usato all'avvio)
  static Future<void> refreshCurrentUser(String uid) async {
    try {
      final response = await Supabase.instance.client
          .from('utenti')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (response != null) {
        // Il modello AppUser.fromMap dovrà ora leggere 'gruppo' invece di 'nome_gruppo'
        currentUser = AppUser.fromMap(response);
      }
    } catch (e) {
      print("Errore refresh utente: $e");
    }
  }

  Future<String?> login(String cell, String codice) async {
    try {
      // Nota: la ricerca nel DB deve corrispondere al formato salvato
      final response = await _supabase
          .from('utenti')
          .select()
          .eq('cellulare', cell.trim())
          .maybeSingle();

      if (response == null) {
        return "Utente non trovato. Verifica il numero.";
      }

      if (response['codice_personale'] == codice) {
        // currentUser caricato con il nuovo mapping (campo 'gruppo')
        currentUser = AppUser.fromMap(response);
        return null;
      } else {
        return "Codice personale errato.";
      }
    } catch (e) {
      return "Errore durante il login: $e";
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    currentUser = null;
  }
}