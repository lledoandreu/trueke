import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_search_notifier.dart';
import 'product_map_view.dart';

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
    final searchState = ref.watch(productSearchProvider);

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
                ref.read(productSearchProvider.notifier).filterProducts(value);
              },
            ),
          ),
          Expanded(
            child: searchState.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron artículos disponibles.'),
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
                          ? Image.network(
                              product.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            )
                          : const Icon(Icons.image),
                      title: Text(product.title),
                      subtitle: Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Error: ${error.toString()}')),
            ),
          ),
        ],
      ),
    );
  }
}
