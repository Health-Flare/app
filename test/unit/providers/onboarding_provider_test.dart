import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';

import '../../helpers/test_database.dart';
import '../../fixtures/profile_fixtures.dart';

void main() {
  late Isar isar;
  late ProviderContainer container;

  setUpAll(() async {
    isar = await TestDatabase.open();
  });

  tearDownAll(() async {
    await TestDatabase.closeAll();
  });

  setUp(() async {
    await TestDatabase.clear(isar);
    container = ProviderContainer(
      overrides: [isarProvider.overrideWithValue(isar)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('OnboardingNotifier', () {
    test('initial state is false when no profiles exist', () {
      final isComplete = container.read(onboardingProvider);
      expect(isComplete, isFalse);
    });

    test('state is true when profiles exist', () async {
      // Create container with preloaded profiles
      final seededContainer = ProviderContainer(
        overrides: [
          isarProvider.overrideWithValue(isar),
          profileListProvider.overrideWith(
            () => ProfileListNotifier()..preload([ProfileFixtures.simple]),
          ),
        ],
      );

      // The onboarding state should reflect that profiles exist
      final isComplete = seededContainer.read(onboardingProvider);
      expect(isComplete, isTrue);

      seededContainer.dispose();
    });

    test('state updates when profile is added', () async {
      // Initially no profiles
      expect(container.read(onboardingProvider), isFalse);

      // Add a profile
      await container.read(profileListProvider.notifier).add(
            name: 'Test User',
          );

      await Future.delayed(const Duration(milliseconds: 100));

      // Now onboarding should be complete
      expect(container.read(onboardingProvider), isTrue);
    });

    test('markComplete is a no-op (state is derived from profiles)', () {
      container.read(onboardingProvider.notifier).markComplete();
      // State remains false since no profiles exist
      expect(container.read(onboardingProvider), isFalse);
    });

    test('markAlreadyComplete is a no-op (state is derived from profiles)', () {
      container.read(onboardingProvider.notifier).markAlreadyComplete();
      // State remains false since no profiles exist
      expect(container.read(onboardingProvider), isFalse);
    });
  });

  group('FirstLogPromptNotifier', () {
    test('initial state is false when no active profile', () {
      final shouldShow = container.read(firstLogPromptProvider);
      expect(shouldShow, isFalse);
    });

    test('markShown sets state to false and persists', () async {
      // Create a profile first
      await container.read(profileListProvider.notifier).add(name: 'Test');
      await Future.delayed(const Duration(milliseconds: 100));

      // Mark as shown
      await container.read(firstLogPromptProvider.notifier).markShown();

      final shouldShow = container.read(firstLogPromptProvider);
      expect(shouldShow, isFalse);
    });

    test('dismiss is an alias for markShown', () async {
      // Create a profile first
      await container.read(profileListProvider.notifier).add(name: 'Test');
      await Future.delayed(const Duration(milliseconds: 100));

      // Dismiss
      await container.read(firstLogPromptProvider.notifier).dismiss();

      final shouldShow = container.read(firstLogPromptProvider);
      expect(shouldShow, isFalse);
    });

    test('show is a no-op (prompt is triggered automatically)', () {
      container.read(firstLogPromptProvider.notifier).show();
      // No error should occur
    });
  });
}
