import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/transactions/repositories/reviews_repository.dart';

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

    if (memberName.contains('select')) {
      client.log.add('select');
      return FakePostgrestFilterBuilder(client);
    }

    if (memberName.contains('insert')) {
      final values = invocation.positionalArguments.first;
      client.log.add('insert:$values');
      return FakePostgrestFilterBuilder(client);
    }

    return super.noSuchMethod(invocation);
  }
}

class FakePostgrestFilterBuilder extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  FakePostgrestFilterBuilder(this.client);
  final FakeSupabaseClient client;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName.toString();

    if (memberName.contains('eq')) {
      final column = invocation.positionalArguments[0];
      final value = invocation.positionalArguments[1];
      client.log.add('eq:$column:$value');
      return this;
    }

    if (memberName.contains('order')) {
      final column = invocation.positionalArguments.first;
      client.log.add('order:$column');
      return this;
    }

    return this;
  }

  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>> value) onValue, {
    Function? onError,
  }) {
    final List<Map<String, dynamic>> mockData = [
      {
        'id': 'rev-100',
        'reviewer_id': 'user-reviewer',
        'reviewer_name': 'Carlos',
        'reviewer_avatar': 'avatar.png',
        'receiver_id': 'user-receiver',
        'rating': 4.5,
        'comment': 'Excelente comunicación.',
        'created_at': '2026-09-09T22:00:00Z',
      },
    ];
    return Future<List<Map<String, dynamic>>>.value(
      mockData,
    ).then((val) => onValue(val), onError: onError);
  }
}

void main() {
  group('SupabaseReviewsRepository Unit Tests', () {
    late FakeSupabaseClient fakeClient;
    late SupabaseReviewsRepository repository;

    setUp(() {
      fakeClient = FakeSupabaseClient();
      repository = SupabaseReviewsRepository(fakeClient);
    });

    test(
      'getUserReviews fetches entries with correct target filters and chronological sort',
      () async {
        final reviews = await repository.getUserReviews('user-receiver');

        expect(fakeClient.log, contains('from:user_reviews'));
        expect(fakeClient.log, contains('select'));
        expect(fakeClient.log, contains('eq:receiver_id:user-receiver'));
        expect(fakeClient.log, contains('order:created_at'));

        expect(reviews.length, 1);
        expect(reviews.first.comment, equals('Excelente comunicación.'));
        expect(reviews.first.rating, equals(4.5));
      },
    );

    test(
      'addReview executes insert with precise payload map structures',
      () async {
        await repository.addReview(
          reviewerId: 'user-reviewer',
          reviewerName: 'Carlos',
          reviewerAvatar: 'avatar.png',
          receiverId: 'user-receiver',
          rating: 5.0,
          comment: '  Cambio impecable  ',
        );

        expect(fakeClient.log, contains('from:user_reviews'));
        final insertLog = fakeClient.log.firstWhere(
          (e) => e.contains('insert:'),
        );
        expect(insertLog, contains('reviewer_id: user-reviewer'));
        expect(insertLog, contains('receiver_id: user-receiver'));
        expect(insertLog, contains('rating: 5.0'));
        expect(insertLog, contains('comment: Cambio impecable'));
      },
    );
  });
}
