import 'package:flutter_test/flutter_test.dart';

import 'package:trueke/models/product.dart';

void main() {
  group('Product', () {
    final createdAt = DateTime.utc(2026, 8, 28, 10, 30);

    test('serializes and restores a trade product', () {
      final product = Product(
        id: 'product-1',
        title: 'Cámara Canon',
        images: const ['https://example.com/camera.jpg'],
        tradeType: TradeType.trade,
        category: 'Electrónica',
        location: 'Albacete',
        owner: 'David',
        ownerId: 'user-1',
        condition: 'Buen estado',
        description: 'Cámara en buen estado.',
        wanted: 'Objetivo 50 mm',
        createdAt: createdAt,
      );

      final restored = Product.fromJson(product.toJson());

      expect(restored.id, product.id);
      expect(restored.title, product.title);
      expect(restored.images, product.images);
      expect(restored.imageUrl, product.imageUrl);
      expect(restored.price, isNull);
      expect(restored.tradeType, TradeType.trade);
      expect(restored.category, product.category);
      expect(restored.location, product.location);
      expect(restored.owner, product.owner);
      expect(restored.ownerId, product.ownerId);
      expect(restored.condition, product.condition);
      expect(restored.description, product.description);
      expect(restored.wanted, product.wanted);
      expect(restored.createdAt, createdAt);
    });

    test('returns an empty image URL when there are no images', () {
      final product = Product(
        id: 'product-2',
        title: 'Artículo sin foto',
        images: const [],
        tradeType: TradeType.trade,
        category: 'Hogar',
        location: 'Albacete',
        owner: 'Usuario',
        condition: 'Usado',
        description: 'Sin imágenes.',
        wanted: 'Otro artículo',
        createdAt: createdAt,
      );

      expect(product.imageUrl, isEmpty);
    });

    test('preserves price and trade-and-money mode', () {
      final product = Product(
        id: 'product-3',
        title: 'Bicicleta',
        images: const ['https://example.com/bike.jpg'],
        price: 150,
        tradeType: TradeType.tradeAndMoney,
        category: 'Deporte',
        location: 'Albacete',
        owner: 'Usuario',
        condition: 'Como nuevo',
        description: 'Bicicleta de carretera.',
        wanted: 'Patinete eléctrico',
        createdAt: createdAt,
      );

      final restored = Product.fromJson(product.toJson());

      expect(restored.price, 150);
      expect(restored.tradeType, TradeType.tradeAndMoney);
    });

    test('uses safe defaults for incomplete JSON data', () {
      final product = Product.fromJson({
        'id': 123,
        'title': null,
        'images': null,
        'trade_type': 'unknown',
        'price': 'not-a-number',
        'created_at': 'invalid-date',
      });

      expect(product.id, '123');
      expect(product.title, isEmpty);
      expect(product.images, isEmpty);
      expect(product.imageUrl, isEmpty);
      expect(product.tradeType, TradeType.trade);
      expect(product.price, isNull);
      expect(product.category, 'Otros');
      expect(product.location, isEmpty);
      expect(product.owner, 'Usuario');
      expect(product.condition, 'Usado');
      expect(product.description, isEmpty);
      expect(product.wanted, isEmpty);
      expect(product.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });
}
