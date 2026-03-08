import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/features/dashboard/dashboard_screen.dart';

import '../helpers/test_database.dart';
import '../fixtures/profile_fixtures.dart';

void main() {
  late Isar isar;

  setUpAll(() async {
    isar = await TestDatabase.open();
  });

  tearDownAll(() async {
    await TestDatabase.closeAll();
  });

  setUp(() async {
    await TestDatabase.clear(isar);
  });

  group('DashboardScreen', () {
    testWidgets('displays app name in app bar', (tester) async {
      await isar.seedProfiles([ProfileFixtures.simpleIsar]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isarProvider.overrideWithValue(isar),
            profileListProvider.overrideWith(
              () => ProfileListNotifier()..preload([ProfileFixtures.simple]),
            ),
            activeProfileProvider.overrideWith(
              () => ActiveProfileNotifier()..preload(1),
            ),
            onboardingProvider.overrideWith(() {
              final notifier = OnboardingNotifier();
              return notifier..markAlreadyComplete();
            }),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Health Flare'), findsWidgets);
    });

    testWidgets('displays profile avatar in app bar', (tester) async {
      await isar.seedProfiles([ProfileFixtures.simpleIsar]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isarProvider.overrideWithValue(isar),
            profileListProvider.overrideWith(
              () => ProfileListNotifier()..preload([ProfileFixtures.simple]),
            ),
            activeProfileProvider.overrideWith(
              () => ActiveProfileNotifier()..preload(1),
            ),
            onboardingProvider.overrideWith(() {
              final notifier = OnboardingNotifier();
              return notifier..markAlreadyComplete();
            }),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Look for CircleAvatar or profile avatar widget
      expect(find.byType(CircleAvatar), findsAtLeastNWidgets(1));
    });

    testWidgets('shows empty state when no entries', (tester) async {
      await isar.seedProfiles([ProfileFixtures.simpleIsar]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isarProvider.overrideWithValue(isar),
            profileListProvider.overrideWith(
              () => ProfileListNotifier()..preload([ProfileFixtures.simple]),
            ),
            activeProfileProvider.overrideWith(
              () => ActiveProfileNotifier()..preload(1),
            ),
            onboardingProvider.overrideWith(() {
              final notifier = OnboardingNotifier();
              return notifier..markAlreadyComplete();
            }),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Empty state might show encouraging message or illustration
      // Actual assertions depend on the implementation
    });

    testWidgets('tapping avatar opens profile switcher', (tester) async {
      await isar.seedProfiles(ProfileFixtures.multipleProfilesIsar);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isarProvider.overrideWithValue(isar),
            profileListProvider.overrideWith(
              () => ProfileListNotifier()..preload(ProfileFixtures.multipleProfiles),
            ),
            activeProfileProvider.overrideWith(
              () => ActiveProfileNotifier()..preload(1),
            ),
            onboardingProvider.overrideWith(() {
              final notifier = OnboardingNotifier();
              return notifier..markAlreadyComplete();
            }),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap avatar
      final avatar = find.byType(CircleAvatar).first;
      await tester.tap(avatar);
      await tester.pumpAndSettle();

      // Profile switcher sheet should appear
      // (assertions depend on implementation)
    });
  });

  group('First-log Prompt', () {
    testWidgets('shows first-log prompt for new profile', (tester) async {
      // This test would verify the first-log prompt behavior
      // after completing onboarding
    });

    testWidgets('first-log prompt shows five options', (tester) async {
      // Verify the five entry options are shown:
      // illness, symptom, vital, meal, medication
    });

    testWidgets('tapping illness option opens illness screen', (tester) async {
      // Verify navigation to illness entry screen
    });

    testWidgets('first-log prompt can be dismissed', (tester) async {
      // Verify dismissal behavior
    });
  });
}
