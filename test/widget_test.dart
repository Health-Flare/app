import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/main.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';

import 'helpers/test_database.dart';
import 'fixtures/profile_fixtures.dart';

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

  group('Onboarding flow', () {
    testWidgets('shows onboarding screen when no profile exists', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const HealthFlareApp(),
        ),
      );
      // Use pump with duration instead of pumpAndSettle to avoid timeout
      // from ongoing animations or provider updates
      await tester.pump(const Duration(milliseconds: 500));

      // Zone 1 welcome headline should be visible
      expect(find.text('Your health story,\nin your hands.'), findsOneWidget);
    });

    testWidgets('CTA button is disabled when name field is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const HealthFlareApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final ctaButton = find.widgetWithText(
        ElevatedButton,
        'Create profile and get started  →',
      );
      expect(ctaButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(ctaButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('CTA button enables once a name is entered', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const HealthFlareApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextFormField).first, 'Sarah');
      await tester.pump(const Duration(milliseconds: 100));

      final ctaButton = find.widgetWithText(
        ElevatedButton,
        'Create profile and get started  →',
      );
      final button = tester.widget<ElevatedButton>(ctaButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('skips onboarding when already complete', (tester) async {
      // Seed a profile to make onboarding complete
      await isar.seedProfiles([ProfileFixtures.simpleIsar]);
      await isar.setActiveProfile(1);

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
          ],
          child: const HealthFlareApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Should land on the dashboard, not onboarding
      expect(find.text('Health Flare'), findsWidgets);
      expect(find.text('Your health story,\nin your hands.'), findsNothing);
    });
  });
}
