import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/amico_model.dart';

class AmicoService {
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
    // 1️⃣ Inserisco l’amico nei miei contatti (se non esiste)
    final existing = await _supabase
        .from('amici')
        .select('id')
        .eq('owner_id', ownerId)
        .eq('friend_id', friendId)
        .maybeSingle();

    if (existing == null) {
      final nuovoAmico = Amico(
        id: '',
        ownerId: ownerId,
        friendId: friendId,
        ownerName: ownerName,
        friendName: friendName,
        friendCellulare: cellulare,
      );
      
      final mapData = nuovoAmico.toMap();
      mapData.remove('id'); 
      mapData.remove('created_at');

      await _supabase.from('amici').insert(mapData);
    }

    // 2️⃣ Inserisco ME nei suoi contatti (se non esiste)
    final reverseExisting = await _supabase
        .from('amici')
        .select('id')
        .eq('owner_id', friendId)
        .eq('friend_id', ownerId)
        .maybeSingle();

    if (reverseExisting == null) {
      final amicoInverso = Amico(
        id: '',
        ownerId: friendId,
        friendId: ownerId,
        ownerName: friendName,
        friendName: ownerName,
        friendCellulare: cellulare,
      );

      final mapDataReverse = amicoInverso.toMap();
      mapDataReverse.remove('id');
      mapDataReverse.remove('created_at');

      await _supabase.from('amici').insert(mapDataReverse);
    }
  }

  /// 3. Recupera la lista amici dell’utente tipizzata con il Model
  Future<List<Amico>> getFriends(String ownerId) async {
    final response = await _supabase
        .from('amici')
        .select()
        .eq('owner_id', ownerId)
        .order('friend_name', ascending: true);

    return (response as List).map((item) => Amico.fromMap(item)).toList();
  }

  /// 4. Cerca amici per nome (ricerca parziale, restituisce lista di Amico)
  Future<List<Amico>> searchFriendsByName(
      String ownerId, String name) async {
    final response = await _supabase
        .from('amici')
        .select()
        .eq('owner_id', ownerId)
        .ilike('friend_name', '%$name%')
        .order('friend_name', ascending: true);

    return (response as List).map((item) => Amico.fromMap(item)).toList();
  }
}