import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _supabase = Supabase.instance.client;

  // Método automático para subir un archivo al Bucket de Supabase
  Future<String?> uploadProductImage(File imageFile) async {
    try {
      // Generamos un nombre único para el archivo basado en el tiempo actual
      final String fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = 'products/$fileName';

      // Subimos el archivo físicamente al Bucket llamado 'images'
      await _supabase.storage.from('images').upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Obtenemos la URL pública oficial de internet para guardarla en el producto
      final String publicUrl = _supabase.storage.from('images').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      // Devuelve null de forma segura si el Bucket no existe o falla la red
      return null;
    }
  }
}
