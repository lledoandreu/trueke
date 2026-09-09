import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/transactions/models/transaction_history_model.dart';
import 'package:trueke/features/transactions/repositories/transaction_repository.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {
  final List<Map<String, dynamic>> transactionStorage = [];
  final List<Map<String, dynamic>> notificationStorage = [];

  @override
  SupabaseQueryBuilder from(String table) {
    return FakeSupabaseQueryBuilder(table, this);
  }
}

class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final String table;
  final FakeSupabaseClient client;

  FakeSupabaseQueryBuilder(this.table, this.client);

  @override
  PostgrestFilterBuilder<PostgrestList> select([String? columns]) {
    return FakePostgrestFilterBuilder<PostgrestList>(table, client);
  }

  @override
  PostgrestFilterBuilder<dynamic> insert(
    Object values, {
    bool defaultToNull = true,
  }) {
    final mapValues = Map<String, dynamic>.from(values as Map);
    if (table == 'transaction_history') {
      mapValues.putIfAbsent('id', () => 'tx-fake-id');
      mapValues.putIfAbsent(
        'created_at',
        () => DateTime.now().toIso8601String(),
      );
      client.transactionStorage.add(mapValues);
    } else if (table == 'notifications') {
      mapValues.putIfAbsent('id', () => 'notif-fake-id');
      mapValues.putIfAbsent(
        'created_at',
        () => DateTime.now().toIso8601String(),
      );
      client.notificationStorage.add(mapValues);
    }
    return FakePostgrestFilterBuilder<dynamic>(table, client);
  }

  @override
  PostgrestFilterBuilder<dynamic> update(
    Map<dynamic, dynamic> values, {
    String? count,
  }) {
    if (table == 'notifications') {
      for (var item in client.notificationStorage) {
        item['is_read'] = values['is_read'];
      }
    }
    return FakePostgrestFilterBuilder<dynamic>(table, client);
  }
}

class FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final String table;
  final FakeSupabaseClient client;

  FakePostgrestFilterBuilder(this.table, this.client);

  @override
  PostgrestFilterBuilder<T> or(String filters, {String? referencedTable}) =>
      this;

  @override
  PostgrestFilterBuilder<T> eq(String column, dynamic value) => this;

  @override
  PostgrestTransformBuilder<T> order(
    String column, {
    bool ascending = false,
    bool nullsFirst = false,
    String? referencedTable,
  }) {
    return FakePostgrestTransformBuilder<T>(table, client);
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(T) onValue, {
    Function? onError,
  }) async {
    final dynamic data = table == 'transaction_history'
        ? client.transactionStorage
        : client.notificationStorage;
    return onValue(data as T);
  }
}

class FakePostgrestTransformBuilder<T> extends Fake
    implements PostgrestTransformBuilder<T> {
  final String table;
  final FakeSupabaseClient client;

  FakePostgrestTransformBuilder(this.table, this.client);

  @override
  Future<U> then<U>(
    FutureOr<U> Function(T) onValue, {
    Function? onError,
  }) async {
    final dynamic data = table == 'transaction_history'
        ? client.transactionStorage
        : client.notificationStorage;
    return onValue(data as T);
  }
}

void main() {
  late FakeSupabaseClient fakeClient;
  late TransactionRepository repository;

  setUp(() {
    fakeClient = FakeSupabaseClient();
    repository = TransactionRepository(fakeClient);
  });

  group('Pruebas del Bloque G - Repositorio de Transacciones', () {
    test(
      'Debe insertar y retornar un historial de transacciones correctamente',
      () async {
        final tx = TransactionHistory(
          id: '1',
          tradeOfferId: 'offer-100',
          ownerId: 'user-a',
          traderId: 'user-b',
          productTitle: 'Bici Eléctrica',
          tradeType: 'trueke',
          status: 'completed',
          createdAt: DateTime.parse('2026-09-09T12:00:00Z'),
        );

        await repository.addTransaction(tx);
        expect(fakeClient.transactionStorage.length, 1);

        final list = await repository.getTransactionHistory('user-a');
        expect(list.length, 1);
        expect(list.first.productTitle, 'Bici Eléctrica');
      },
    );

    test('Debe insertar, listar y marcar notificaciones como leídas', () async {
      await repository.sendNotification(
        userId: 'user-a',
        title: 'Nueva oferta',
        message: 'Tienes una propuesta de intercambio',
        type: 'trade_request',
      );

      expect(fakeClient.notificationStorage.length, 1);
      expect(fakeClient.notificationStorage.first['is_read'], false);

      final list = await repository.getNotifications('user-a');
      expect(list.length, 1);

      await repository.markNotificationAsRead('notif-fake-id');
      expect(fakeClient.notificationStorage.first['is_read'], true);
    });
  });
}
