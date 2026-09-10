import 'package:flutter/material.dart';
import 'package:trueke/features/profile/presentation/screens/profile_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Home Trueke'))),
        );
      case profile:
        final userId = settings.arguments as String? ?? '';
        return MaterialPageRoute(builder: (_) => ProfileScreen(userId: userId));
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
        );
    }
  }
}
