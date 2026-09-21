import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationService {
  Future<bool> requestPermissions();
  Future<String?> getDeviceToken();
  Stream<String> get onTokenRefresh;
}

class FirebaseNotificationService implements NotificationService {
  FirebaseNotificationService([FirebaseMessaging? messaging])
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  @override
  Future<bool> requestPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> getDeviceToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
