import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _supabase = Supabase.instance.client;

  Future<String?> uploadAvatar(File file, String userId) async {
    final path = 'avatars/$userId.jpg';

    await _supabase.storage.from('avatars').upload(
      path,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    final url = _supabase.storage.from('avatars').getPublicUrl(path);
    return url;
  }
}