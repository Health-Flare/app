// lib/features/shared/widgets/guided_step_header.dart: shared by
// onboarding, post-setup and the release guide.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/features/shared/widgets/guided_step_header.dart';

Widget _header() => MaterialApp(
  home: Scaffold(
    body: GuidedStepHeader(
      currentIndex: 1,
      total: 4,
      stepTitle: 'Where things moved',
      onBack: () {},
      onSkip: () {},
    ),
  ),
);

void main() {
  for (final scale in [1.0, 2.0]) {
    // Found by the release review (#171): at 200% text "Skip" wrapped one
    // letter per line in a 48-point box.
    testWidgets('Skip stays on one line at ${(scale * 100).round()}% text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1206, 2622);
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(_header());

      final skip = tester.getSize(find.text('Skip'));
      expect(skip.width, greaterThan(skip.height), reason: 'one line');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the dots stay centred, with or without Back and Skip', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(_header());
    final dots = tester.getCenter(
      find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == 'StepProgressDots',
      ),
    );
    expect(dots.dx, moreOrLessEquals(402 / 2, epsilon: 1));
  });
}
