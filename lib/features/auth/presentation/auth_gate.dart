import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/home_page.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado de autenticación actual de Supabase
    final session = Supabase.instance.client.auth.currentSession;

    // Si hay una sesión activa guardada localmente, va directo a la Home sin pedir credenciales
    if (session != null) {
      return const HomePage();
    }

    // Si no hay sesión o ha expirado, lo redirige de forma automática a la pantalla de Login
    return const LoginPage();
  }
}
