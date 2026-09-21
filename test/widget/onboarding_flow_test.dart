import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/onboarding/screens/onboarding_screen.dart';
import 'package:health_flare/features/onboarding/widgets/onboarding_features_zone.dart';
import 'package:health_flare/features/shared/widgets/guided_step_header.dart';
import 'package:health_flare/features/shared/widgets/step_progress_dots.dart';
import 'package:health_flare/models/condition.dart';
import 'package:health_flare/models/profile.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeConditionCatalog extends ConditionCatalogNotifier {
  @override
  List<Condition> build() => [];
}

class _FakeProfileList extends ProfileListNotifier {
  final List<Profile> created = [];

  @override
  List<Profile> build() => [];

  @override
  Future<void> add({
    required String name,
    DateTime? dateOfBirth,
    String? avatarPath,
  }) async {
    created.add(Profile(id: created.length + 1, name: name));
  }
}

Widget _buildOnboarding({List<Override> extraOverrides = const []}) {
  return ProviderScope(
    overrides: [
      conditionCatalogProvider.overrideWith(_FakeConditionCatalog.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      ...extraOverrides,
    ],
    child: const MaterialApp(home: OnboardingScreen()),
  );
}

void main() {
  group('GuidedStepHeader', () {
    testWidgets('shows the dot indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GuidedStepHeader(
              total: 4,
              currentIndex: 1,
              stepTitle: 'What you can track',
            ),
          ),
        ),
      );

      expect(find.byType(StepProgressDots), findsOneWidget);
    });

    testWidgets('hides Back when onBack is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GuidedStepHeader(
              total: 4,
              currentIndex: 0,
              stepTitle: 'Welcome',
            ),
          ),
        ),
      );

      expect(find.byTooltip('Back'), findsNothing);
    });

    testWidgets('shows Back and Skip when provided, and both are tappable', (
      tester,
    ) async {
      var backTapped = false;
      var skipTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GuidedStepHeader(
              total: 4,
              currentIndex: 1,
              stepTitle: 'What you can track',
              onBack: () => backTapped = true,
              onSkip: () => skipTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('Back'));
      await tester.tap(find.text('Skip'));

      expect(backTapped, isTrue);
      expect(skipTapped, isTrue);
    });
  });

  group('OnboardingFeaturesZone', () {
    testWidgets('shows a chip with a real icon for each of the six features', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OnboardingFeaturesZone(onNext: () {})),
        ),
      );

      for (final label in [
        'Symptoms',
        'Vitals',
        'Medications',
        'Meals',
        'Journal',
        'Conditions',
      ]) {
        expect(find.widgetWithText(Chip, label), findsOneWidget);
      }

      // Each chip's avatar is a rendered Icon, not emoji-as-text.
      expect(
        find.descendant(of: find.byType(Chip), matching: find.byType(Icon)),
        findsNWidgets(6),
      );
    });

    testWidgets('tapping Next invokes the callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingFeaturesZone(onNext: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      expect(tapped, isTrue);
    });
  });

  group('OnboardingScreen: guided flow', () {
    testWidgets('starts on the Welcome step', (tester) async {
      await tester.pumpWidget(_buildOnboarding());
      await tester.pump();

      expect(find.text('Your health story,\nin your hands.'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.byTooltip('Back'), findsNothing);
    });

    testWidgets('Next moves from Welcome to What you can track', (
      tester,
    ) async {
      await tester.pumpWidget(_buildOnboarding());
      await tester.pump();

      final nextButton = find.widgetWithText(FilledButton, 'Next');
      await tester.ensureVisible(nextButton);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingFeaturesZone), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
    });

    testWidgets('Skip jumps straight to the mandatory Create profile step', (
      tester,
    ) async {
      await tester.pumpWidget(_buildOnboarding());
      await tester.pump();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Create profile and get started  →'), findsOneWidget);
      // The mandatory step offers no Skip.
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('the Create profile step cannot be skipped, only completed', (
      tester,
    ) async {
      await tester.pumpWidget(_buildOnboarding());
      await tester.pump();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(
          ElevatedButton,
          'Create profile and get started  →',
        ),
      );
      expect(button.onPressed, isNull); // no name entered yet

      await tester.enterText(find.byType(TextFormField).first, 'Sarah');
      await tester.pump();

      final enabledButton = tester.widget<ElevatedButton>(
        find.widgetWithText(
          ElevatedButton,
          'Create profile and get started  →',
        ),
      );
      expect(enabledButton.onPressed, isNotNull);
    });
  });
}
