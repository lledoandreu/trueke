import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/core/services/notifications/repositories/notification_tokens_repository.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {
  final List<String> log = [];

  @override
  SupabaseQueryBuilder from(String table) {
    log.add('from:$table');
    return FakeSupabaseQueryBuilder(this);
  }
}

class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  FakeSupabaseQueryBuilder(this.client);
  final FakeSupabaseClient client;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName.toString();

    if (memberName.contains('upsert')) {
      final values = invocation.positionalArguments.first;
      final onConflict = invocation.namedArguments[#onConflict];
      client.log.add('upsert:$values:onConflict:$onConflict');
      return FakePostgrestFilterBuilder(client);
    }

    if (memberName.contains('delete')) {
      client.log.add('delete');
      return FakePostgrestFilterBuilder(client);
    }

    return super.noSuchMethod(invocation);
  }
}

class FakePostgrestFilterBuilder extends Fake
    implements PostgrestFilterBuilder {
  FakePostgrestFilterBuilder(this.client);
  final FakeSupabaseClient client;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName.toString();
    if (memberName.contains('eq')) {
      final firstArg = invocation.positionalArguments.first;
      final secondArg = invocation.positionalArguments.length > 1
          ? invocation.positionalArguments[1]
          : '';
      client.log.add('eq:$firstArg:$secondArg');
    }
    return this;
  }

  @override
  Future<R> then<R>(
    FutureOr<R> Function(dynamic value) onValue, {
    Function? onError,
  }) {
    return Future<dynamic>.value(
      [],
    ).then((dynamic val) => onValue(val), onError: onError);
  }
}

void main() {
  group('SupabaseNotificationTokensRepository Unit Tests', () {
    late FakeSupabaseClient fakeClient;
    late SupabaseNotificationTokensRepository repository;

    setUp(() {
      fakeClient = FakeSupabaseClient();
      repository = SupabaseNotificationTokensRepository(fakeClient);
    });

    test(
      'saveToken executes upsert with the correct structure and target table',
      () async {
        await repository.saveToken(
          userId: 'user-uuid-123',
          token: 'fcm-token-xyz',
        );

        expect(fakeClient.log, contains('from:user_push_tokens'));
        final upsertLog = fakeClient.log.firstWhere(
          (e) => e.contains('upsert:'),
        );
        expect(upsertLog, contains('user_id: user-uuid-123'));
        expect(upsertLog, contains('token: fcm-token-xyz'));
        expect(upsertLog, contains('onConflict:token'));
      },
    );

    test(
      'deleteToken executes delete filter matches correct token string',
      () async {
        await repository.deleteToken(token: 'fcm-token-to-remove');

        expect(fakeClient.log, contains('from:user_push_tokens'));
        expect(fakeClient.log, contains('delete'));
        expect(fakeClient.log, contains('eq:token:fcm-token-to-remove'));
      },
    );
  });
}
