import 'dart:io';
import 'package:geolocator/geolocator.dart';
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

  // Productos semilla (Fallback mock inmutable)
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
    Product(
      id: 'mock_3',
      title: 'Cafetera Express Automática',
      description: 'Prepara café molido al instante. Presión de 15 bares.',
      price: 120.0,
      tradeType: TradeType.tradeAndMoney,
      category: 'Hogar',
      location: 'Valencia, Ruzafa',
      owner: 'Carlos',
      condition: 'Usado',
      wanted: 'Bicicleta de paseo antigua',
      createdAt: DateTime.now(),
      latitude: 39.469907,
      longitude: -0.376288,
      images: ['https://unsplash.com'],
    ),
    Product(
      id: 'mock_4',
      title: 'Consola Retro Portable',
      description: 'Incluye más de 500 juegos clásicos en memoria.',
      price: 45.0,
      tradeType: TradeType.sale,
      category: 'Gaming',
      location: 'Sevilla, Triana',
      owner: 'Ana',
      condition: 'Nueva',
      wanted: 'Juegos de mesa modernos',
      createdAt: DateTime.now(),
      latitude: 37.389092,
      longitude: -5.984459,
      images: ['https://unsplash.com'],
    ),
    Product(
      id: 'mock_5',
      title: 'Raqueta de Tenis Profesional',
      description: 'Ligera y de alta tensión para competición.',
      price: null,
      tradeType: TradeType.trade,
      category: 'Deporte',
      location: 'Bilbao, Abando',
      owner: 'Luis',
      condition: 'Buen estado',
      wanted: 'Pala de pádel de carbono',
      createdAt: DateTime.now(),
      latitude: 43.263012,
      longitude: -2.934985,
      images: ['https://unsplash.com'],
    ),
  ];

  @override
  Future<List<Product>> getProducts({
    double? userLatitude,
    double? userLongitude,
    double? radiusInKm,
  }) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false);

      var allProducts = (response as List<dynamic>)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();

      // Si la base de datos remota está vacía, usamos los productos semilla
      if (allProducts.isEmpty) {
        allProducts = List.from(_mockFallback);
      }

      if (userLatitude == null || userLongitude == null || radiusInKm == null) {
        return allProducts;
      }

      return allProducts.where((product) {
        if (product.latitude == null || product.longitude == null) {
          return false;
        }

        final distanceInMeters = Geolocator.distanceBetween(
          userLatitude,
          userLongitude,
          product.latitude!,
          product.longitude!,
        );

        final distanceInKm = distanceInMeters / 1000.0;
        return distanceInKm <= radiusInKm;
      }).toList();
    } catch (_) {
      // Si falla la red o la tabla no está lista, garantizamos que la app no rompa usando el fallback
      return List.from(_mockFallback);
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    // Si es un id del mock, lo buscamos en la lista estática
    if (id.startsWith('mock_')) {
      return _mockFallback.firstWhere((p) => p.id == id);
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
