import 'package:supabase_flutter/supabase_flutter.dart';

class AmiciService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 1. Verifica se esiste già la relazione
  Future<bool> existsFriendship(String ownerId, String friendId) async {
    final response = await _supabase
        .from('amici')
        .select('id')
        .eq('owner_id', ownerId)
        .eq('friend_id', friendId)
        .maybeSingle();
    return response != null;
  }

  /// 2. Crea la relazione se NON esiste
Future<void> createFriendship({
  required String ownerId,
  required String ownerName,
  required String friendId,
  required String friendName,
  required String cellulare,
}) async {
  final supabase = Supabase.instance.client;

  // 1️⃣ Inserisco l’amico nei miei contatti (se non esiste)
  final existing = await supabase
      .from('amici')
      .select('id')
      .eq('owner_id', ownerId)
      .eq('friend_id', friendId)
      .maybeSingle();

  if (existing == null) {
    await supabase.from('amici').insert({
      'owner_id': ownerId,
      'owner_name': ownerName,
      'friend_id': friendId,
      'friend_name': friendName,
      'friend_cellulare': cellulare,
    });
  }

  // 2️⃣ Inserisco ME nei suoi contatti (se non esiste)
  final reverseExisting = await supabase
      .from('amici')
      .select('id')
      .eq('owner_id', friendId)
      .eq('friend_id', ownerId)
      .maybeSingle();

  if (reverseExisting == null) {
    await supabase.from('amici').insert({
      'owner_id': friendId,
      'owner_name': friendName,
      'friend_id': ownerId,
      'friend_name': ownerName,
      'friend_cellulare': cellulare,
    });
  }
}

  /// 3. Recupera la lista amici dell’utente
  Future<List<Map<String, dynamic>>> getFriends(String ownerId) async {
    final response = await _supabase
        .from('amici')
        .select()
        .eq('owner_id', ownerId)
        .order('friend_name', ascending: true);
    return response;
  }

  /// 4. Cerca amici per nome (ricerca parziale, restituisce lista)
  Future<List<Map<String, dynamic>>> searchFriendsByName(
      String ownerId, String name) async {
    final response = await _supabase
        .from('amici')
        .select()
        .eq('owner_id', ownerId)
        .ilike('friend_name', '%$name%')
        .order('friend_name', ascending: true);

    return response;
  }
}
