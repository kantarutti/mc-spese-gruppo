import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

/// Provider per leggere gli eventi da Supabase
final eventiProvider = FutureProvider<List<Evento>>((ref) async {
  final supabase = Supabase.instance.client;
  
  try {
    final response = await supabase
        .from('eventi')
        .select()
        .order('data_inizio', ascending: true);
    
    final eventi = (response as List<dynamic>)
        .map((e) => Evento.fromJson(e as Map<String, dynamic>))
        .toList();
    
    return eventi;
  } catch (e) {
    print('Errore nel caricamento degli eventi: $e');
    return [];
  }
});
