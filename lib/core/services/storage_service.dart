import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  StorageService();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _productBucket = 'product-images';

  Future<String> uploadProductImage(File imageFile) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('Debes iniciar sesión para subir imágenes.');
    }

    final extension = _extensionFromPath(imageFile.path);
    final fileName = '${DateTime.now().microsecondsSinceEpoch}.$extension';
    final path = '${user.id}/$fileName';

    await _supabase.storage
        .from(_productBucket)
        .upload(
          path,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    return _supabase.storage.from(_productBucket).getPublicUrl(path);
  }

  String _extensionFromPath(String path) {
    final dotIndex = path.lastIndexOf('.');

    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return 'jpg';
    }

    final extension = path.substring(dotIndex + 1).toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
        return extension == 'jpeg' ? 'jpg' : extension;
      default:
        return 'jpg';
    }
  }
}
