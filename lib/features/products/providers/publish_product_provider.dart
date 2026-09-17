import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/product.dart';
import '../domain/repositories/publish_product_repository.dart';
import '../repositories/supabase_publish_product_repository.dart';

// Proveedor para exponer el cliente de Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Proveedor para la interfaz de PublishProductRepository
final publishProductRepositoryProvider = Provider<PublishProductRepository>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  return SupabasePublishProductRepository(client);
});

// Estado de UI para la pantalla de publicación
class PublishProductState {
  final File? selectedImage;
  final bool isPublishing;
  final String? errorMessage;
  final bool isSuccess;

  PublishProductState({
    this.selectedImage,
    this.isPublishing = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  PublishProductState copyWith({
    File? selectedImage,
    bool? isPublishing,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return PublishProductState(
      selectedImage: selectedImage ?? this.selectedImage,
      isPublishing: isPublishing ?? this.isPublishing,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Notifier reactivo que gestiona la lógica del formulario y captura de imágenes
class PublishProductNotifier extends Notifier<PublishProductState> {
  @override
  PublishProductState build() {
    return PublishProductState();
  }

  void setImage(File image) {
    state = state.copyWith(selectedImage: image, isSuccess: false);
  }

  void clearImage() {
    state = state.copyWith(selectedImage: null);
  }

  Future<void> submitProduct({
    required String title,
    required String description,
    double? price,
    required String category,
    required String owner,
    String? ownerId,
    required String condition,
    required TradeType tradeType,
    required String wanted,
    required String location,
    double? latitude,
    double? longitude,
  }) async {
    if (state.selectedImage == null) {
      state = state.copyWith(
        errorMessage: 'Por favor, selecciona o toma una foto del producto.',
      );
      return;
    }

    state = state.copyWith(isPublishing: true, errorMessage: null);

    try {
      final repository = ref.read(publishProductRepositoryProvider);

      // 1. Subir la imagen al storage usando el ID del propietario (o fallback)
      final uploadPathId = ownerId ?? owner;
      final imageUrl = await repository.uploadProductImage(
        state.selectedImage!,
        uploadPathId,
      );

      // 2. Construir el modelo inmutable Product con los tipos exactos detectados
      final product = Product(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        price: price,
        tradeType: tradeType,
        category: category,
        location: location,
        owner: owner,
        ownerId: ownerId,
        condition: condition,
        wanted: wanted,
        images: [imageUrl],
        createdAt: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
      );

      // 3. Persistir en la base de datos de Supabase
      await repository.publishProduct(product);

      state = state.copyWith(
        isPublishing: false,
        isSuccess: true,
        selectedImage: null,
      );
    } catch (e) {
      state = state.copyWith(isPublishing: false, errorMessage: e.toString());
    }
  }
}

// Proveedor reactivo del estado de publicación utilizando NotifierProvider
final publishProductNotifierProvider =
    NotifierProvider<PublishProductNotifier, PublishProductState>(() {
      return PublishProductNotifier();
    });
