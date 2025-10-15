import 'dart:math';
import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sound.dart';
import 'supabase_config.dart';
import 'supabase_service.dart';

class StorageService {
  final _supabase = Supabase.instance.client;
  final _db = SupabaseService();

  bool _isAudioExtension(String? ext) {
    final e = (ext ?? '').toLowerCase();
    return e == 'mp3' || e == 'wav';
  }

  Future<Sound> uploadSoundAndInsertMetadata({
    required FilePickerResult result,
    required String tag,
    String? customName,
  }) async {
    if (result.files.isEmpty) {
      throw const FormatException('No se seleccionó ningún archivo');
    }
    final file = result.files.first;
    if (!_isAudioExtension(file.extension)) {
      throw const FormatException('Formato no permitido. Solo .mp3 o .wav');
    }

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Usuario no autenticado');
    }

    final originalName = (customName?.trim().isNotEmpty == true)
        ? customName!.trim()
        : (file.name.split('.').first);

    final sanitized = originalName.replaceAll(RegExp(r'[^A-Za-z0-9_\- ]'), '_');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(9999);
    final path = '$userId/${timestamp}_$rand.${file.extension?.toLowerCase() ?? 'mp3'}';

    // Subir al bucket
    if (file.bytes != null) {
      await _supabase.storage.from(soundsBucket).uploadBinary(path, file.bytes!);
    } else if (file.path != null) {
      await _supabase.storage.from(soundsBucket).upload(path, io.File(file.path!));
    } else {
      throw const FormatException('No se pudo leer el archivo seleccionado');
    }

    // Obtener URL pública (el bucket debe ser público) o firmada si no lo es
    final publicUrl = _supabase.storage.from(soundsBucket).getPublicUrl(path);

    final sound = Sound(
      id: _generateUuid(),
      name: sanitized,
      tag: tag,
      url: publicUrl,
      userId: userId,
      createdAt: DateTime.now(),
    );

    await _db.insertSound(sound);
    return sound;
  }

  Future<void> deleteSound(Sound sound) async {
    // Extraer el path relativo desde la URL pública
    // Si el bucket es público, la URL contiene el path tras el nombre del bucket
    final uri = Uri.parse(sound.url);
    final segments = uri.pathSegments;
    final bucketIndex = segments.indexOf(soundsBucket);
    String? path;
    if (bucketIndex != -1 && bucketIndex + 1 < segments.length) {
      path = segments.sublist(bucketIndex + 1).join('/');
    }

    if (path != null && path.isNotEmpty) {
      await _supabase.storage.from(soundsBucket).remove([path]);
    }

    await _db.deleteSoundById(sound.id);
  }

  String _generateUuid() {
    // Generar UUID v4 simple (sin dependencia extra). Adecuado para IDs temporales.
    final rnd = Random();
    String s(int n) => List.generate(n, (_) => rnd.nextInt(16).toRadixString(16)).join();
    return '${s(8)}-${s(4)}-${s(4)}-${s(4)}-${s(12)}';
  }
}