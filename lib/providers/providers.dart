import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sound.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Stream con la sesión actual; persiste mientras no se haga logout
final authStateProvider = StreamProvider<Session?>((ref) {
  final client = ref.read(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((event) => event.session);
});

/// Filtro de etiqueta actual
final filterTagProvider = StateProvider<String?>((ref) => null);

/// Lista de sonidos (todos o por etiqueta)
final soundsProvider = FutureProvider<List<Sound>>((ref) async {
  final client = ref.read(supabaseClientProvider);
  final tag = ref.watch(filterTagProvider);
  var builder = client.from('sounds').select('*');
  if (tag != null) {
    builder = builder.eq('tag', tag);
  }
  final data = await builder.order('created_at', ascending: false);
  final list = (data as List)
      .map((e) => Sound.fromMap(e as Map<String, dynamic>))
      .toList();
  return list;
});

/// Sonidos del usuario autenticado
final mySoundsProvider = FutureProvider<List<Sound>>((ref) async {
  final client = ref.read(supabaseClientProvider);
  final tag = ref.watch(filterTagProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];
  var builder = client
      .from('sounds')
      .select('*')
      .eq('user_id', userId);
  if (tag != null) {
    builder = builder.eq('tag', tag);
  }
  final data = await builder.order('created_at', ascending: false);
  final list = (data as List)
      .map((e) => Sound.fromMap(e as Map<String, dynamic>))
      .toList();
  return list;
});