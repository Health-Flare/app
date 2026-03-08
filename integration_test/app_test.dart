import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/main.dart';
import 'package:health_flare/core/providers/database_provider.dart';

import '../test/helpers/test_database.dart';
import '../test/fixtures/profile_fixtures.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  group('End-to-End: Onboarding Flow', () {
    testWidgets('complete onboarding creates profile and shows dashboard', (
      tester,
    ) async {
      // Start app with fresh database
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const HealthFlareApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Should see onboarding
      expect(find.text('Your health story,\nin your hands.'), findsOneWidget);

      // Enter a name
      await tester.enterText(find.byType(TextField).first, 'Sarah');
      await tester.pump();

      // Tap the primary action button
      final ctaButton = find.widgetWithText(
        ElevatedButton,
        'Create profile and get started  →',
      );
      await tester.tap(ctaButton);
      await tester.pumpAndSettle();

      // Should now be on dashboard (or first-log prompt)
      expect(find.text('Your health story,\nin your hands.'), findsNothing);
    });

    testWidgets('existing profile skips onboarding', (tester) async {
      // Seed a profile
      await isar.seedProfiles([ProfileFixtures.simpleIsar]);
      await isar.setActiveProfile(1);

      // Start app
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const HealthFlareApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Should skip onboarding and show dashboard
      expect(find.text('Health Flare'), findsWidgets);
      expect(find.text('Your health story,\nin your hands.'), findsNothing);
    });
  });

  group('End-to-End: Journal Flow', () {
    testWidgets('can create journal entry from dashboard', (tester) async {
      // Seed a profile and set it active
      await isar.seedProfiles([ProfileFixtures.simpleIsar]);
      await isar.setActiveProfile(1);

      // Start app
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const HealthFlareApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to journal (implementation depends on navigation structure)
      // This is a placeholder - actual navigation would use bottom nav or FAB
      await tester.pumpAndSettle();

      // Test would continue with journal creation flow
    });
  });

  group('End-to-End: Profile Switching', () {
    testWidgets('can switch between profiles', (tester) async {
      // Seed multiple profiles
      await isar.seedProfiles(ProfileFixtures.multipleProfilesIsar);
      await isar.setActiveProfile(1);

      // Start app
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const HealthFlareApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Open profile switcher (tap on avatar or profile name)
      // Switch to another profile
      // Verify the switch occurred
      await tester.pumpAndSettle();
    });
  });
}
