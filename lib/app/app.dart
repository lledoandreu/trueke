import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'routes/app_routes.dart';

class TruekeApp extends StatelessWidget {
  const TruekeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trueke',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
