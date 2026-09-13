import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/onboarding/screens/post_setup_flow_screen.dart';
import 'package:health_flare/features/onboarding/widgets/first_log_prompt.dart';
import 'package:health_flare/features/onboarding/widgets/weather_opt_in_sheet.dart';
import 'package:health_flare/features/shared/widgets/step_progress_dots.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeFirstLogPrompt extends FirstLogPromptNotifier {
  bool shownCalled = false;

  @override
  bool build() => true;

  @override
  Future<void> markShown() async {
    shownCalled = true;
  }
}

class _FakeWeatherOptIn extends WeatherOptInNotifier {
  bool? lastResult;

  @override
  bool build() => true;

  @override
  Future<void> dismiss({required bool enabled}) async {
    lastResult = enabled;
  }
}

/// Wraps [child] in a GoRouter with stub destination screens for every
/// route FirstLogPrompt can navigate to.
Widget _routedHarness(Widget child, {List<Override> overrides = const []}) {
  final router = GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(
        path: '/start',
        builder: (_, _) => Scaffold(body: child),
      ),
      GoRoute(
        path: AppRoutes.illness,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Illness screen'))),
      ),
      GoRoute(
        path: AppRoutes.symptoms,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Tracking screen'))),
      ),
      GoRoute(
        path: AppRoutes.meals,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Meals screen'))),
      ),
      GoRoute(
        path: AppRoutes.medications,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Medications screen'))),
      ),
      GoRoute(
        path: AppRoutes.journal,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Journal screen'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('FirstLogPrompt', () {
    testWidgets('offers six icon-led options, including a journal entry', (
      tester,
    ) async {
      await tester.pumpWidget(
        _routedHarness(
          FirstLogPrompt(profileName: 'Ethan', onFinished: () {}),
          overrides: [
            firstLogPromptProvider.overrideWith(_FakeFirstLogPrompt.new),
          ],
        ),
      );

      for (final label in [
        'An illness',
        'A symptom',
        'A vital',
        'A meal',
        'A medication',
        'A journal entry',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('tapping "An illness" pushes the illness screen and returns '
        'here afterwards, updating the heading', (tester) async {
      await tester.pumpWidget(
        _routedHarness(
          FirstLogPrompt(profileName: 'Ethan', onFinished: () {}),
          overrides: [
            firstLogPromptProvider.overrideWith(_FakeFirstLogPrompt.new),
          ],
        ),
      );

      expect(find.text("Ethan's profile is ready."), findsOneWidget);

      await tester.tap(find.text('An illness'));
      await tester.pumpAndSettle();
      expect(find.text('Illness screen'), findsOneWidget);

      // Pop back out of the illness screen.
      Navigator.of(tester.element(find.text('Illness screen'))).pop();
      await tester.pumpAndSettle();

      // Back on the first-log step, heading updated.
      expect(
        find.text('What would you like to record for Ethan first?'),
        findsOneWidget,
      );
    });

    testWidgets('tapping a routine option navigates away and finishes', (
      tester,
    ) async {
      var finished = false;
      await tester.pumpWidget(
        _routedHarness(
          FirstLogPrompt(
            profileName: 'Ethan',
            onFinished: () => finished = true,
          ),
          overrides: [
            firstLogPromptProvider.overrideWith(_FakeFirstLogPrompt.new),
          ],
        ),
      );

      final journalOption = find.text('A journal entry');
      await tester.ensureVisible(journalOption);
      await tester.tap(journalOption);
      await tester.pumpAndSettle();

      expect(find.text('Journal screen'), findsOneWidget);
      expect(finished, isTrue);
    });

    testWidgets('"I\'ll explore on my own" marks shown and finishes', (
      tester,
    ) async {
      var finished = false;
      final notifier = _FakeFirstLogPrompt();
      await tester.pumpWidget(
        _routedHarness(
          FirstLogPrompt(
            profileName: 'Ethan',
            onFinished: () => finished = true,
          ),
          overrides: [firstLogPromptProvider.overrideWith(() => notifier)],
        ),
      );

      final exploreLink = find.text("I'll explore on my own  →");
      await tester.ensureVisible(exploreLink);
      await tester.tap(exploreLink);
      await tester.pumpAndSettle();

      expect(notifier.shownCalled, isTrue);
      expect(finished, isTrue);
    });
  });

  group('PostSetupFlowScreen', () {
    testWidgets('shows both steps when both are pending, in sequence', (
      tester,
    ) async {
      await tester.pumpWidget(
        _routedHarness(
          const PostSetupFlowScreen(
            showWeatherStep: true,
            showFirstLogStep: true,
            profileName: 'Ethan',
          ),
          overrides: [
            firstLogPromptProvider.overrideWith(_FakeFirstLogPrompt.new),
            weatherOptInProvider.overrideWith(_FakeWeatherOptIn.new),
          ],
        ),
      );

      expect(find.byType(WeatherTrackingOptInSheet), findsOneWidget);
      expect(find.byType(StepProgressDots), findsOneWidget);

      await tester.tap(find.text('No thanks'));
      await tester.pumpAndSettle();

      expect(find.byType(FirstLogPrompt), findsOneWidget);
    });

    testWidgets('shows only the pending step when the other is already done', (
      tester,
    ) async {
      await tester.pumpWidget(
        _routedHarness(
          const PostSetupFlowScreen(
            showWeatherStep: false,
            showFirstLogStep: true,
            profileName: 'Ethan',
          ),
          overrides: [
            firstLogPromptProvider.overrideWith(_FakeFirstLogPrompt.new),
            weatherOptInProvider.overrideWith(_FakeWeatherOptIn.new),
          ],
        ),
      );

      expect(find.byType(WeatherTrackingOptInSheet), findsNothing);
      expect(find.byType(FirstLogPrompt), findsOneWidget);
    });

    testWidgets('Skip on the weather step declines tracking and advances', (
      tester,
    ) async {
      final weatherNotifier = _FakeWeatherOptIn();
      await tester.pumpWidget(
        _routedHarness(
          const PostSetupFlowScreen(
            showWeatherStep: true,
            showFirstLogStep: true,
            profileName: 'Ethan',
          ),
          overrides: [
            firstLogPromptProvider.overrideWith(_FakeFirstLogPrompt.new),
            weatherOptInProvider.overrideWith(() => weatherNotifier),
          ],
        ),
      );

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(weatherNotifier.lastResult, isFalse);
      expect(find.byType(FirstLogPrompt), findsOneWidget);
    });
  });
}
