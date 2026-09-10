import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../repositories/supabase_profile_repository.dart';

/// Proveedor del repositorio que requiere la instancia nativa de SupabaseClient heredada de la arquitectura Core.
final supabaseProfileRepositoryProvider = Provider<SupabaseProfileRepository>((
  ref,
) {
  return SupabaseProfileRepository(Supabase.instance.client);
});

/// Proveedor familiar manual de tipo [FutureProvider] para obtener perfiles de usuario por [userId].
/// Elimina cualquier colisión estructural con bounds genéricos del linter de Riverpod manual.
final userProfileProvider = FutureProvider.autoDispose
    .family<UserProfile, String>((ref, userId) async {
      final repository = ref.watch(supabaseProfileRepositoryProvider);
      return repository.getProfile(userId);
    });

/// Controlador para operaciones mutables del perfil del usuario extendiendo de la clase base real [AsyncNotifier].
class ProfileMutationNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Estado inicial pasivo listo para ejecutar mutaciones
  }

  /// Actualiza los datos del perfil pasando el modelo inmutable [UserProfile] esperado posicionalmente por el repositorio.
  Future<void> updateProfile({required UserProfile profile}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(supabaseProfileRepositoryProvider);

      await repository.updateProfile(profile);

      // Forzamos el refresco inmediato del proveedor familiar para actualizar la UI automáticamente
      ref.invalidate(userProfileProvider(profile.id));
    });
  }
}

/// Proveedor para gestionar las mutaciones asíncronas sobre los perfiles de usuario.
final profileMutationProvider =
    AsyncNotifierProvider.autoDispose<ProfileMutationNotifier, void>(() {
      return ProfileMutationNotifier();
    });
