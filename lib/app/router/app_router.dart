import 'package:flutter/material.dart';

import '../../features/home/home_page.dart';
import '../../features/products/product_detail_page.dart';
import '../../models/product.dart';
import '../routes/app_routes.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case AppRoutes.product:
        final product = settings.arguments as Product;

        return MaterialPageRoute(
          builder: (_) => ProductDetailPage(product: product),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Página no encontrada')),
            body: const Center(child: Text('404')),
          ),
        );
    }
  }
}
