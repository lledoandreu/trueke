import 'package:flutter/material.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/support/presentation/screens/create_report_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String profile = '/profile';
  static const String favorites = '/favorites';
  static const String notifications = '/notifications';
  static const String createReport = '/create-report';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Home Trueke'))),
        );
      case profile:
        final userId = routeSettings.arguments as String? ?? '';
        return MaterialPageRoute(builder: (_) => ProfileScreen(userId: userId));
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case createReport:
        final args = routeSettings.arguments as Map<String, String>? ?? {};
        final targetId = args['targetId'] ?? '';
        final targetType = args['targetType'] ?? 'product';
        return MaterialPageRoute(
          builder: (_) =>
              CreateReportScreen(targetId: targetId, targetType: targetType),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
        );
    }
  }
}
