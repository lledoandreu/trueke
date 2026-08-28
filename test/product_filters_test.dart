import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trueke/features/products/providers/product_filters_provider.dart';
import 'package:trueke/models/product.dart';

void main() {
  group('ProductFilters', () {
    test('starts without active filters', () {
      const filters = ProductFilters();

      expect(filters.hasActiveFilters, isFalse);
      expect(filters.query, isEmpty);
      expect(filters.category, isNull);
      expect(filters.tradeType, isNull);
    });

    test('setQuery trims surrounding whitespace', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(productFiltersProvider.notifier).setQuery('  bicicleta  ');

      expect(container.read(productFiltersProvider).query, 'bicicleta');
    });

    test('toggleCategory selects and then clears the same category', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(productFiltersProvider.notifier);

      notifier.toggleCategory('Electrónica');
      expect(container.read(productFiltersProvider).category, 'Electrónica');

      notifier.toggleCategory('Electrónica');
      expect(container.read(productFiltersProvider).category, isNull);
    });

    test('setTradeType updates and can clear the trade type', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(productFiltersProvider.notifier);

      notifier.setTradeType(TradeType.tradeAndMoney);
      expect(
        container.read(productFiltersProvider).tradeType,
        TradeType.tradeAndMoney,
      );

      notifier.setTradeType(null);
      expect(container.read(productFiltersProvider).tradeType, isNull);
    });

    test('clear resets every filter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(productFiltersProvider.notifier);

      notifier.setQuery('mesa');
      notifier.toggleCategory('Hogar');
      notifier.setTradeType(TradeType.sale);
      expect(container.read(productFiltersProvider).hasActiveFilters, isTrue);

      notifier.clear();

      expect(container.read(productFiltersProvider), const ProductFilters());
    });
  });
}
