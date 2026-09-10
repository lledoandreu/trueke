import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../supabase/supabase_client.dart';
import '../../../../features/auth/auth_service.dart';
import '../../../../features/transactions/models/notification_model.dart';
import '../data/supabase_notifications_repository.dart';
import '../domain/notifications_repository.dart';

// Provider para el repositorio de notificaciones
final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseNotificationsRepository(client);
});

// Notifier asíncrono para gestionar la bandeja de notificaciones en tiempo real
class NotificationsHistoryNotifier
    extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    final userIdAsync = ref.watch(authUserIdProvider);
    final userId = userIdAsync.value;

    if (userId == null) {
      return [];
    }

    final repository = ref.watch(notificationsRepositoryProvider);
    return repository.fetchNotifications(userId: userId);
  }

  /// Marca una notificación concreta como leída y actualiza el estado localmente de forma reactiva
  Future<void> markAsRead(String notificationId) async {
    final currentList = state.value ?? [];

    // Actualización optimista del estado local
    state = AsyncData(
      currentList
          .map(
            (n) => n.id == notificationId
                ? NotificationModel(
                    id: n.id,
                    userId: n.userId,
                    title: n.title,
                    message: n.message,
                    type: n.type,
                    isRead: true,
                    createdAt: n.createdAt,
                  )
                : n,
          )
          .toList(),
    );

    try {
      final repository = ref.read(notificationsRepositoryProvider);
      await repository.markAsRead(notificationId: notificationId);
    } catch (error, stackTrace) {
      // Si falla en el servidor, revertimos volviendo a recargar de la fuente
      state = AsyncError(error, stackTrace);
      ref.invalidateSelf();
    }
  }

  /// Marca todas las notificaciones del usuario actual como leídas
  Future<void> markAllAsRead() async {
    final userId = ref.read(authUserIdProvider).value;
    if (userId == null) return;

    final currentList = state.value ?? [];
    state = AsyncData(
      currentList
          .map(
            (n) => NotificationModel(
              id: n.id,
              userId: n.userId,
              title: n.title,
              message: n.message,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
            ),
          )
          .toList(),
    );

    try {
      final repository = ref.read(notificationsRepositoryProvider);
      await repository.markAllAsRead(userId: userId);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      ref.invalidateSelf();
    }
  }
}

// Provider global de la lista de notificaciones de la bandeja
final notificationsHistoryProvider =
    AsyncNotifierProvider<
      NotificationsHistoryNotifier,
      List<NotificationModel>
    >(NotificationsHistoryNotifier.new);
