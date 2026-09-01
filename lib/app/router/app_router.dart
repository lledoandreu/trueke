import 'package:flutter/material.dart';

import '../../features/home/home_page.dart';
import '../../features/products/product_detail_page.dart';
import '../../features/products/publish_product_page.dart';
import '../../features/chat/chat_page.dart';
import '../../features/trades/trade_offers_page.dart';
import '../../features/trades/send_trade_offer_page.dart';
import '../../models/product.dart';
import '../routes/app_routes.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(builder: (_) => const HomePage());

      case AppRoutes.product:
        final product = settings.arguments as Product;
        return MaterialPageRoute<void>(
          builder: (_) => ProductDetailPage(product: product),
        );

      case AppRoutes.chat:
        return MaterialPageRoute<void>(builder: (_) => const ChatPage());

      case AppRoutes.tradeOffers:
        return MaterialPageRoute<void>(builder: (_) => const TradeOffersPage());

      case AppRoutes.sendTradeOffer:
        final product = settings.arguments as Product;
        return MaterialPageRoute<void>(
          builder: (_) => SendTradeOfferPage(product: product),
        );

      case AppRoutes.publishProduct:
        final product = settings.arguments as Product?;
        return MaterialPageRoute<void>(
          builder: (_) => PublishProductPage(product: product),
        );

      default:
        return MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Página no encontrada')),
            body: const Center(child: Text('404')),
          ),
        );
    }
  }
}
