import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/app/shell/main_shell.dart';
import 'package:trueke/features/home/home_page.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/features/auth/auth_page.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Trueke',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: authStateAsync.when(
        data: (authState) {
          final session = authState.session;
          if (session != null) {
            return const MainShell(child: HomePage());
          } else {
            return const AuthPage();
          }
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) =>
            Scaffold(body: Center(child: Text('Error de autenticacion: $err'))),
      ),
    );
  }
}
