import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider temporal para comprobar que Riverpod
/// está correctamente configurado.
final appNameProvider = Provider<String>((ref) {
  return 'Trueke';
});
