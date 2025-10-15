import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sound.dart';

class SupabaseService {
  SupabaseClient get client => Supabase.instance.client;

  Future<AuthResponse> signUpEmail({required String email, required String password}) async {
    return await client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signInEmail({required String email, required String password}) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<void> insertSound(Sound sound) async {
    await client.from('sounds').insert(sound.toInsertMap());
  }

  Future<void> deleteSoundById(String id) async {
    await client.from('sounds').delete().eq('id', id);
  }
}