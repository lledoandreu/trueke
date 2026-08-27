import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/storage_service.dart';

class ProductUploadNotifier extends StateNotifier<AsyncValue<void>> {
  ProductUploadNotifier() : super(const AsyncValue.data(null));

  final _supabase = Supabase.instance.client;
  final _storageService = StorageService();

  // Método automático para gestionar la subida completa del artículo
  Future<bool> uploadProduct({
    required String title,
    required String description,
    required double price,
    required File? imageFile,
  }) async {
    state = const AsyncValue.loading();
    try {
      String? imageUrl;
      
      // 1. Si el usuario seleccionó una imagen, la subimos primero al Storage de Supabase
      if (imageFile != null) {
        imageUrl = await _storageService.uploadProductImage(imageFile);
      }

      // 2. Insertamos el registro definitivo de textos y URL en la tabla 'products'
      await _supabase.from('products').insert({
        'name': title,
        'description': description,
        'price': price,
        'images': imageUrl != null ? [imageUrl] : [], // Guardamos la URL en tu lista de imágenes
        'user_id': _supabase.auth.currentUser?.id,
      });

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final productUploadProvider = StateNotifierProvider<ProductUploadNotifier, AsyncValue<void>>((ref) {
  return ProductUploadNotifier();
});
