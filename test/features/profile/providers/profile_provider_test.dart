import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/profile/models/user_profile.dart';
import 'package:trueke/features/profile/providers/profile_provider.dart';
import 'package:trueke/features/profile/repositories/supabase_profile_repository.dart';

class MockProfileRepository implements SupabaseProfileRepository {
  final UserProfile mockProfile;
  bool updateCalled = false;
  UserProfile? lastUpdatedProfile;

  MockProfileRepository(this.mockProfile);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getProfile) {
      return Future.value(mockProfile);
    }
    if (invocation.memberName == #updateProfile) {
      updateCalled = true;
      // Capturamos el perfil inmutable enviado posicionalmente en los argumentos
      final profileParam = invocation.positionalArguments.first as UserProfile;
      lastUpdatedProfile = profileParam;
      return Future.value(profileParam);
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late UserProfile sampleProfile;
  late MockProfileRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    sampleProfile = UserProfile(
      id: 'user_123',
      email: 'test@trueke.com',
      displayName: 'David Trueke',
      avatarUrl: 'https://avatar.url',
      bio: 'Apasionado del trueque sostenible',
      averageRating: 4.8,
      totalRatings: 12,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

    mockRepository = MockProfileRepository(sampleProfile);

    container = ProviderContainer(
      overrides: [
        supabaseProfileRepositoryProvider.overrideWith((ref) => mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('UserProfile Providers Suite Tests', () {
    test(
      'userProfileProvider obtiene y expone el modelo UserProfile correctamente',
      () async {
        final profileFuture = container.read(
          userProfileProvider('user_123').future,
        );

        expect(profileFuture, completes);
        final profile = await profileFuture;
        expect(profile.id, equals('user_123'));
        expect(profile.displayName, equals('David Trueke'));
        expect(profile.bio, equals('Apasionado del trueque sostenible'));
      },
    );

    test(
      'profileMutationProvider ejecuta updateProfile de forma exitosa y refresca el estado',
      () async {
        final updatedProfileModel = sampleProfile.copyWith(
          displayName: 'David Actualizado',
          bio: 'Nueva bio de trueques',
        );

        final mutationNotifier = container.read(
          profileMutationProvider.notifier,
        );
        await mutationNotifier.updateProfile(profile: updatedProfileModel);

        expect(mockRepository.updateCalled, isTrue);
        expect(
          mockRepository.lastUpdatedProfile?.displayName,
          equals('David Actualizado'),
        );
        expect(
          mockRepository.lastUpdatedProfile?.bio,
          equals('Nueva bio de trueques'),
        );
      },
    );
  });
}
