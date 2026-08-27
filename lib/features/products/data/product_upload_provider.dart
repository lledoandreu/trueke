import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/core/services/storage_service.dart';

class ProductUploadNotifier extends StateNotifier<AsyncValue<void>> {
  ProductUploadNotifier() : super(const AsyncValue.data(null));

  final _supabase = Supabase.instance.client;
  final _storageService = StorageService();

  Future<bool> uploadProduct({
    required String title,
    required String description,
    required double price,
    required File? imageFile,
  }) async {
    state = const AsyncValue.loading();
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storageService.uploadProductImage(imageFile);
      }

      await _supabase.from('products').insert({
        'name': title,
        'description': description,
        'price': price,
        'images': imageUrl != null ? <String>[imageUrl] : <String>[],
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
