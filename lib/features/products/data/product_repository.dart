import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/product.dart';

class ProductRepository {
  final _supabase = Supabase.instance.client;

  // Método automático para descargar todos los productos de Supabase
  Future<List<Product>> fetchProducts() async {
    try {
      final List<dynamic> response = await _supabase.from('products').select();

      // Mapeamos los datos de internet directamente a tus objetos del modelo Product
      return response
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Devuelve una lista vacía de forma segura si falla el internet o el servidor
      return [];
    }
  }
}
