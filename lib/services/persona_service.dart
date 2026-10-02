import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'amico_service.dart';
import 'utenti_service.dart';

class PersonaService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AmicoService _amicoService = AmicoService();
  final UtentiService _utentiService = UtentiService();

  Future<Map<String, dynamic>> gestisciPersona({
    required String nome,
    required String telefono,
    required String eventoId,
    required String? gruppoId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final ownerId = prefs.getString('utente_id');
    final ownerName = prefs.getString('utente_nome') ?? "Utente";
    final ownerCellulare = prefs.getString('cellulare') ?? "";

    if (ownerId == null) {
      return {
        "success": false,
        "isAlreadyPresent": false,
        "message": "Nessun utente attivo. Devi effettuare il login."
      };
    }

    // Controlliamo preventivamente se la persona è già inserita in questo evento
    final personaEsistente = await _supabase
        .from('persone')
        .select('id')
        .eq('evento_id', eventoId)
        .eq('cellulare', telefono)
        .maybeSingle();

    if (personaEsistente != null) {
      return {
        "success": false,
        "isAlreadyPresent": true,
        "message": "Questa persona è già inserita nell'evento."
      };
    }

    final existingUser = await _utentiService.searchByPhone(telefono);

    Map<String, dynamic> user;
    String userId;
    String nomePersona = "";

    if (existingUser != null) {
      user = existingUser;
      userId = existingUser['id'];
      nomePersona = existingUser['nome'];
    } else {
      user = await _utentiService.createUser(
        nome: nome,
        cellulare: telefono,
        codicePersonale: _generaCodice(),
      );
      userId = user['id'];
      nomePersona = user['nome'];
    }

    try {
      await _amicoService.createFriendship(
        ownerId: ownerId,
        ownerName: ownerName,
        friendId: userId,
        friendName: nomePersona,
        cellulare: telefono,
      );

      await _amicoService.createFriendship(
        ownerId: userId,
        ownerName: nomePersona,
        friendId: ownerId,
        friendName: ownerName,
        cellulare: ownerCellulare,
      );
    } catch (e) {
      print("Errore non bloccante nella creazione amicizia: $e");
    }

    try {
      await _supabase.from('persone').insert({
        'evento_id': eventoId,
        'user_id': ownerId,
        'cellulare': telefono,
        'gruppo_id': gruppoId,
        'persona': nomePersona
      });
    } catch (e) {
      // Intercetta eventuali violazioni di unicità concorrenti (es. unique constraint)
      return {
        "success": false,
        "isAlreadyPresent": true,
        "message": "Questa persona è già inserita nell'evento."
      };
    }

    return {
      "success": true,
      "isAlreadyPresent": false,
      "user": user,
      "message": "Persona aggiunta con successo."
    };
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

  Future<Map<String, dynamic>> insertPersona({
    required String nome,
    required String telefono,
    required String eventoId,
    required String? gruppoId,
  }) async {
    return await gestisciPersona(
      nome: nome,
      telefono: telefono,
      eventoId: eventoId,
      gruppoId: gruppoId,
    );
  }
}