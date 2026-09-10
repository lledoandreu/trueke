import 'package:flutter/material.dart';
import 'package:trueke/features/search/presentation/screens/search_screen.dart';
import 'package:trueke/features/transactions/presentation/screens/user_transactions_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case '/transactions':
        final userId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => UserTransactionsScreen(userId: userId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('404'), Text('Página no encontrada')],
              ),
            ),
          ),
        );
    }
  }
}
