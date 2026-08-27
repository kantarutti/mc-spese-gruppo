import 'package:supabase_flutter/supabase_flutter.dart';
import 'amici_service.dart';
import 'utenti_service.dart';
import 'auth_service.dart';

class PersoneService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AmiciService _amiciService = AmiciService();
  final UtentiService _utentiService = UtentiService();

  Future<Map<String, dynamic>> gestisciPersona({
    required String nome,
    required String telefono,
    required String eventoId,
    required String? gruppoId,
  }) async {
    final ownerId = Supabase.instance.client.auth.currentUser!.id;
    final ownerName = AuthService.currentUser!.nome;

    // 1. Provo a cercare l’utente per telefono
    final existingUser = await _utentiService.searchByPhone(telefono);

    Map<String, dynamic> user;
    String userId;
    String nomePersona = "";

    if (existingUser != null) {
      user = existingUser;
      userId = existingUser['id'];
      nomePersona = existingUser['nome'];
    } else {
      // 2. Se non esiste, lo creo
      user = await _utentiService.createUser(
        nome: nome,
        cellulare: telefono,
        codicePersonale: _generaCodice(),
      );
      userId = user['id'];
      nomePersona = user['nome'];
    }

    // 3. Creo la relazione amici (se non esiste)
    await _amiciService.createFriendship(
      ownerId: ownerId,
      ownerName: ownerName,
      friendId: userId,
      friendName: nomePersona,
      cellulare: telefono,
    );

    // 4. Inserisco la persona nell’evento
    await _supabase.from('persone').insert({
      'evento_id': eventoId,
      'user_id': userId,
      'cellulare': telefono,
      'gruppo_id': gruppoId, // ⭐ AGGIUNTO
      'persona': nomePersona // ⭐ AGGIUNTO
    });

    return user;
  }

  String _generaCodice() {
    return DateTime.now().millisecondsSinceEpoch.toString().substring(7);
  }

  Future<void> deletePersona(dynamic personaId) async {
    await _supabase.from('persone').delete().eq('id', personaId);
  }

  Future<List<Map<String, dynamic>>> loadPersone(dynamic gruppoId) async {
    final response = await _supabase
        .from('persone')
        .select()
        .eq('gruppo_id', gruppoId)
        .order('persona', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> insertPersona({
    required String nome,
    required String telefono,
    required String eventoId,
    required String? gruppoId,
  }) async {
    await gestisciPersona(
      nome: nome,
      telefono: telefono,
      eventoId: eventoId,
      gruppoId: gruppoId,
    );
  }
}
