import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/app/shell/main_shell.dart';
import 'package:trueke/features/home/home_page.dart'; // O la página inicial por defecto de tu estructura

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Trueke',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // Inyectamos la página correspondiente dentro del contenedor de la Shell
      home: const MainShell(child: HomePage()),
    );
  }
}
