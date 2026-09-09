import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:trueke/core/services/notifications/notification_service.dart';

class FakeFirebaseMessaging extends Fake implements FirebaseMessaging {
  bool requestPermissionCalled = false;
  String? mockToken = 'mock-fcm-token-123';
  final _tokenRefreshController = StreamController<String>.broadcast();

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = false,
    bool announcement = false,
    bool badge = false,
    bool carPlay = false,
    bool criticalAlert = false,
    bool providesAppNotificationSettings = false,
    bool provisional = false,
    bool sound = false,
  }) async {
    requestPermissionCalled = true;
    return const NotificationSettings(
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.disabled,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.disabled,
      criticalAlert: AppleNotificationSetting.disabled,
      sound: AppleNotificationSetting.enabled,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.never,
      timeSensitive: AppleNotificationSetting.disabled,
      authorizationStatus: AuthorizationStatus.authorized,
      providesAppNotificationSettings: AppleNotificationSetting.disabled,
    );
  }

  @override
  Future<String?> getToken({
    String? serviceWorkerScriptPath,
    String? vapidKey,
  }) async {
    return mockToken;
  }

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  void emitToken(String token) {
    _tokenRefreshController.add(token);
  }

  void dispose() {
    _tokenRefreshController.close();
  }
}

void main() {
  group('FirebaseNotificationService Unit Tests', () {
    late FakeFirebaseMessaging fakeMessaging;
    late FirebaseNotificationService service;

    setUp(() {
      fakeMessaging = FakeFirebaseMessaging();
      service = FirebaseNotificationService(fakeMessaging);
    });

    tearDown(() {
      fakeMessaging.dispose();
    });

    test(
      'requestPermissions requests permission and returns true when authorized',
      () async {
        final result = await service.requestPermissions();

        expect(fakeMessaging.requestPermissionCalled, isTrue);
        expect(result, isTrue);
      },
    );

    test('getDeviceToken returns the configured token from Firebase', () async {
      final token = await service.getDeviceToken();

      expect(token, equals('mock-fcm-token-123'));
    });

    test('onTokenRefresh stream forwards tokens correctly', () async {
      final emittedTokens = <String>[];
      final subscription = service.onTokenRefresh.listen(emittedTokens.add);

      fakeMessaging.emitToken('new-token-abc');
      await pumpEventQueue();

      expect(emittedTokens, contains('new-token-abc'));
      await subscription.cancel();
    });
  });
}
