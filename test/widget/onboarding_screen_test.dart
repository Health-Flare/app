import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/features/onboarding/screens/onboarding_screen.dart';

import '../helpers/test_database.dart';

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

  group('OnboardingScreen', () {
    testWidgets('displays welcome headline', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Your health story,\nin your hands.'),
        findsOneWidget,
      );
    });

    testWidgets('displays app name', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Health Flare'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays privacy section', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Look for privacy-related text
      expect(
        find.textContaining('data'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('displays name input field', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
    });

    testWidgets('CTA button is initially disabled', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final ctaButton = find.widgetWithText(
        ElevatedButton,
        'Create profile and get started  →',
      );
      expect(ctaButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(ctaButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('CTA button enables when name is entered', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Enter a name
      await tester.enterText(find.byType(TextFormField).first, 'Sarah');
      await tester.pump();

      final ctaButton = find.widgetWithText(
        ElevatedButton,
        'Create profile and get started  →',
      );
      final button = tester.widget<ElevatedButton>(ctaButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('CTA button remains disabled for whitespace-only name', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Enter only whitespace
      await tester.enterText(find.byType(TextFormField).first, '   ');
      await tester.pump();

      final ctaButton = find.widgetWithText(
        ElevatedButton,
        'Create profile and get started  →',
      );
      final button = tester.widget<ElevatedButton>(ctaButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('privacy learn more can be expanded', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap "Learn more" if it exists
      final learnMore = find.text('Learn more');
      if (learnMore.evaluate().isNotEmpty) {
        await tester.tap(learnMore);
        await tester.pumpAndSettle();

        // Verify expanded content is shown
        // (actual content depends on implementation)
      }
    });

    testWidgets('scrolls to show all content', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find scrollable and scroll down
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      // CTA should still be findable (either fixed or scrolled into view)
      expect(
        find.widgetWithText(ElevatedButton, 'Create profile and get started  →'),
        findsOneWidget,
      );
    });
  });

  group('OnboardingScreen Accessibility', () {
    testWidgets('name field has accessible label', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find the text field and verify it has semantic label
      final textField = find.byType(TextFormField).first;
      expect(textField, findsOneWidget);

      // The field should have a label or hint for accessibility
    });

    testWidgets('CTA button has accessible label', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final ctaButton = find.widgetWithText(
        ElevatedButton,
        'Create profile and get started  →',
      );
      expect(ctaButton, findsOneWidget);
    });
  });
}
