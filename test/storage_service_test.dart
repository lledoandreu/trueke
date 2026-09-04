import 'package:flutter_test/flutter_test.dart';
import 'package:trueke/core/services/storage_service.dart';

void main() {
  group('StorageService', () {
    test(
      'instantiates without throwing when Supabase is not yet initialized',
      () {
        final storage = StorageService();
        expect(storage, isNotNull);
      },
    );
  });
}
