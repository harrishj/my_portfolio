import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient? _customClient;
  StorageService([this._customClient]);

  SupabaseClient get _client {
    if (_customClient != null) return _customClient;
    return Supabase.instance.client;
  }
  String get _bucket => 'portfolio';

  Future<String?> uploadProjectMedia(String projectId, Uint8List bytes, String fileName, String mimeType, bool isVideo) async {
    if (projectId.isEmpty) {
      debugPrint('Storage Error: Cannot upload to an empty projectId.');
      throw Exception('Project ID is missing. Please save the project before uploading media.');
    }

    try {
      final path = 'projects/$projectId/$fileName';
      await _client.storage.from(_bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: true),
          );
      return _client.storage.from(_bucket).getPublicUrl(path);
    } catch (e) {
      debugPrint('Storage Upload Error: $e');
      rethrow;
    }
  }

  Future<String?> uploadGeneralImage(String name, Uint8List bytes, {String contentType = 'image/png'}) async {
    if (_client.auth.currentSession == null) {
      throw const AuthException('Unauthorized: Active admin session required to upload media.');
    }
    try {
      final path = 'general/$name';
      await _client.storage.from(_bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );
      final publicUrl = _client.storage.from(_bucket).getPublicUrl(path);
      final separator = publicUrl.contains('?') ? '&' : '?';
      return '$publicUrl${separator}t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      debugPrint('Storage Upload Error: $e');
      rethrow;
    }
  }

  Future<String?> uploadResume(Uint8List bytes, String fileName) async {
    try {
      final path = 'documents/$fileName';
      await _client.storage.from(_bucket).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(contentType: 'application/pdf', upsert: true),
          );
      return _client.storage.from(_bucket).getPublicUrl(path);
    } catch (e) {
      debugPrint('Storage Upload Error: $e');
      rethrow;
    }
  }
}
