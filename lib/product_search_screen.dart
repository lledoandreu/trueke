import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/products/providers/product_filters_provider.dart';
import 'product_map_view.dart';
import 'features/products/product_detail_page.dart';

class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  ConsumerState<ProductSearchScreen> createState() =>
      _ProductSearchScreenState();
}

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen> {
  bool _isListView = true; // true = Lista, false = Mapa

  @override
  Widget build(BuildContext context) {
    final filteredProductsAsync = ref.watch(filteredProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Artículos'),
        actions: [
          IconButton(
            icon: Icon(_isListView ? Icons.map : Icons.view_list),
            tooltip: _isListView ? 'Ver en Mapa' : 'Ver en Lista',
            onPressed: () {
              setState(() {
                _isListView = !_isListView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: '¿Qué estás buscando?',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(productFiltersProvider.notifier).setQuery(value);
              },
            ),
          ),
          Expanded(
            child: filteredProductsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  'Error al cargar productos: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron artículos disponibles con los filtros aplicados.',
                    ),
                  );
                }

                if (!_isListView) {
                  return ProductMapView(products: products);
                }

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      leading: product.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                product.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              ),
                            )
                          : const Icon(Icons.image),
                      title: Text(product.title),
                      subtitle: Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                ProductDetailPage(product: product),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
