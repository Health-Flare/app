import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/main.dart';
import 'package:health_flare/core/providers/onboarding_provider.dart';

void main() {
  group('Onboarding flow', () {
    testWidgets('shows onboarding screen when no profile exists', (
      tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: HealthFlareApp()));
      await tester.pumpAndSettle();

      // Zone 1 welcome headline should be visible
      expect(find.text('Your health story,\nin your hands.'), findsOneWidget);
    });

    testWidgets('CTA button is disabled when name field is empty', (
      tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: HealthFlareApp()));
      await tester.pumpAndSettle();

      final ctaButton = find.widgetWithText(
        ElevatedButton,
        'Create profile and get started  →',
      );
      expect(ctaButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(ctaButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('CTA button enables once a name is entered', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: HealthFlareApp()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Sarah');
      await tester.pump();

      final ctaButton = find.widgetWithText(
        ElevatedButton,
        'Create profile and get started  →',
      );
      final button = tester.widget<ElevatedButton>(ctaButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('skips onboarding when already complete', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Simulate onboarding already done
            onboardingProvider.overrideWith(() {
              final notifier = OnboardingNotifier();
              return notifier..markAlreadyComplete();
            }),
          ],
          child: const HealthFlareApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Should land on the dashboard, not onboarding
      expect(find.text('Health Flare'), findsWidgets);
      expect(find.text('Your health story,\nin your hands.'), findsNothing);
    });
  });
}
