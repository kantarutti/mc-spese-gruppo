import 'package:supabase_flutter/supabase_flutter.dart';

class UtentiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 1.  Cerca un utente per nome (ricerca parziale)
  Future<Map<String, dynamic>?> searchByName(String name) async {
    final response = await _supabase
        .from('utenti')
        .select()
        .ilike('nome', '%$name%')
        .maybeSingle();

    return response;
  }

  /// 2. Cerca un utente per numero di telefono
  Future<Map<String, dynamic>?> searchByPhone(String phone) async {
    final response = await _supabase
        .from('utenti')
        .select()
        .eq('cellulare', phone.trim())
        .maybeSingle();

    return response;
  }

  /// 3. Recupera un utente tramite ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final response = await _supabase
        .from('utenti')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

  /// 4. Crea un nuovo utente
  Future<Map<String, dynamic>> createUser({
    required String nome,
    required String cellulare,
    required String codicePersonale,
    String? gruppo,
  }) async {
    final response = await _supabase.from('utenti').insert({
      'nome': nome,
      'cellulare': cellulare,
      'PIN': codicePersonale,
//      'gruppo': gruppo,
      'ruolo': 'Invitato',       
      'utente_registrato': false,      
    }).select().single();

    return response;
  }

  /// 5. Aggiorna nome o telefono dell’utente
  Future<void> updateUser({
    required String userId,
    String? nome,
    String? cellulare,
  }) async {
    final data = <String, dynamic>{};

    if (nome != null) data['nome'] = nome;
    if (cellulare != null) data['cellulare'] = cellulare;

    if (data.isEmpty) return;

    await _supabase
        .from('utenti')
        .update(data)
        .eq('id', userId);
  }
}
