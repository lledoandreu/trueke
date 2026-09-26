import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/storage_service.dart';
import '../../../models/product.dart';
import 'product_repository.dart';

class SupabaseProductRepository implements ProductRepository {
  SupabaseProductRepository(this._client)
    : _storageService = StorageService(_client);

  final SupabaseClient _client;
  final StorageService _storageService;

  static const _table = 'products';

  static final List<Product> _mockFallback = [
    Product(
      id: 'mock_1',
      title: 'Smartphone de Última Generación',
      description: 'Pantalla AMOLED y cámara de alta resolución.',
      price: 699.0,
      tradeType: TradeType.sale,
      category: 'Electrónica',
      location: 'Madrid, Centro',
      owner: 'David',
      condition: 'Como nuevo',
      wanted: 'Dinero o tablet de valor similar',
      createdAt: DateTime.now(),
      latitude: 40.416775,
      longitude: -3.703790,
      images: ['https://unsplash.com'],
    ),
    Product(
      id: 'mock_2',
      title: 'Chaqueta de Cuero Vintage',
      description: 'Chaqueta clásica de cuero genuino, talla M.',
      price: null,
      tradeType: TradeType.trade,
      category: 'Moda',
      location: 'Barcelona, Eixample',
      owner: 'Elena',
      condition: 'Buen estado',
      wanted: 'Zapatillas de running talla 42',
      createdAt: DateTime.now(),
      latitude: 41.385063,
      longitude: 2.173404,
      images: ['https://unsplash.com'],
    ),
  ];

  @override
  Future<List<Product>> getProducts({
    String? query,
    String? category,
    double? userLatitude,
    double? userLongitude,
    double? radiusInKm,
  }) async {
    try {
      List<dynamic> response;

      // Si tenemos geolocalización activa, delegamos atómicamente a PostGIS mediante RPC
      if (userLatitude != null && userLongitude != null && radiusInKm != null) {
        response =
            await _client.rpc(
                  'search_products_by_radius',
                  params: {
                    'user_lat': userLatitude,
                    'user_lng': userLongitude,
                    'radius_km': radiusInKm,
                    'search_query': query ?? '',
                    'search_category': category ?? '',
                  },
                )
                as List<dynamic>;
      } else {
        // Fallback tradicional filtrado por base de datos si no hay coordenadas en el mapa
        var builder = _client.from(_table).select();
        if (query != null && query.isNotEmpty) {
          builder = builder.or(
            'title.ilike.%$query%,description.ilike.%$query%',
          );
        }
        if (category != null && category.isNotEmpty) {
          builder = builder.eq('category', category);
        }
        final res = await builder.order('created_at', ascending: false);
        response = res as List<dynamic>;
      }

      var allProducts = response
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();

      if (allProducts.isEmpty &&
          (query == null || query.isEmpty) &&
          (category == null || category.isEmpty)) {
        return List.from(_mockFallback);
      }

      return allProducts;
    } catch (_) {
      return List.from(_mockFallback);
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    if (id.startsWith('mock_')) {
      return _mockFallback.firstWhere(
        (p) => p.id == id,
        orElse: () => _mockFallback.first,
      );
    }

    final response = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Product.fromJson(response);
  }

  @override
  Future<void> createProduct(Product product) async {
    await _client.from(_table).insert(product.toJson());
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _client.from(_table).update(product.toJson()).eq('id', product.id);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  @override
  Future<String> uploadProductImage(XFile file) async {
    return _storageService.uploadProductImage(File(file.path));
  }

  @override
  Future<void> deleteProductImage(String publicUrl) async {
    await _storageService.deleteProductImage(publicUrl);
  }
}
