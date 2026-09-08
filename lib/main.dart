import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  await dotenv.load(fileName: '.env');
  
  // Inicializar Supabase usando las claves del archivo .env
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL', fallback: dotenv.get('NEXT_PUBLIC_SUPABASE_URL', fallback: '')),
    publishableKey: dotenv.get('SUPABASE_ANON_KEY', fallback: dotenv.get('NEXT_PUBLIC_SUPABASE_ANON_KEY', fallback: '')),
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
