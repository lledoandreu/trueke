import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/home/home_page.dart';

class TruekeApp extends StatelessWidget {
  const TruekeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trueke',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}
