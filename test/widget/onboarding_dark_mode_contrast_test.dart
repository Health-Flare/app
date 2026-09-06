import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/theme/app_theme.dart';
import 'package:health_flare/features/onboarding/widgets/onboarding_privacy_zone.dart';
import 'package:health_flare/features/onboarding/widgets/onboarding_profile_zone.dart';
import 'package:health_flare/features/onboarding/widgets/weather_opt_in_sheet.dart';
import 'package:health_flare/models/condition.dart';

class _FakeConditionCatalog extends ConditionCatalogNotifier {
  @override
  List<Condition> build() => [];
}

/// WCAG 2.1 relative luminance of an sRGB colour.
double _relativeLuminance(Color color) {
  return 0.2126 * _linearize(color.r) +
      0.7152 * _linearize(color.g) +
      0.0722 * _linearize(color.b);
}

double _linearize(double srgb) {
  return srgb <= 0.03928
      ? srgb / 12.92
      : math.pow((srgb + 0.055) / 1.055, 2.4).toDouble();
}

double _contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a) + 0.05;
  final lb = _relativeLuminance(b) + 0.05;
  return la > lb ? la / lb : lb / la;
}

/// Finds every [Text] with an explicit style colour inside [rootFinder] and
/// asserts it meets WCAG AA contrast (4.5:1, or 3:1 for large/bold text)
/// against its nearest ancestor [Container] background.
///
/// Regression coverage for docs/features/onboarding.feature ›
/// "Onboarding screen meets WCAG 2.1 AA colour contrast requirements" — this
/// scenario had no implementing test, which is how the onboarding privacy
/// and profile-creation zones shipped with hardcoded light backgrounds
/// (AppColors.surfaceVariant / AppColors.surface) that made theme-adaptive
/// text unreadable once dark mode was wired up in main.dart.
void _expectReadableText(WidgetTester tester, Finder rootFinder) {
  final textElements = find
      .descendant(of: rootFinder, matching: find.byType(Text))
      .evaluate()
      .toList();

  var checked = 0;

  for (final element in textElements) {
    final text = element.widget as Text;
    final color = text.style?.color;
    if (color == null) continue;

    final containerFinder = find.ancestor(
      of: find.byElementPredicate((e) => identical(e, element)),
      matching: find.byType(Container),
    );
    if (containerFinder.evaluate().isEmpty) continue;

    final container = tester.widget<Container>(containerFinder.first);
    final decoration = container.decoration;
    final background =
        container.color ??
        (decoration is BoxDecoration ? decoration.color : null);
    if (background == null) continue;

    final fontSize = text.style?.fontSize ?? 14;
    final isBold = (text.style?.fontWeight?.index ?? 3) >= FontWeight.w700.index;
    final isLargeText = fontSize >= 18 || (fontSize >= 14 && isBold);
    final minRatio = isLargeText ? 3.0 : 4.5;

    final ratio = _contrastRatio(color, background);
    checked++;

    expect(
      ratio,
      greaterThanOrEqualTo(minRatio),
      reason:
          'Text "${text.data}" has contrast ${ratio.toStringAsFixed(2)}:1 '
          'against background $background (needs $minRatio:1 for '
          '${isLargeText ? "large" : "normal"} text)',
    );
  }

  // Guard against the test silently checking nothing if the widget tree
  // structure changes underneath it.
  expect(
    checked,
    greaterThan(0),
    reason: 'Expected at least one styled Text with a Container ancestor',
  );
}

void main() {
  group('Onboarding — dark mode readability (WCAG AA)', () {
    testWidgets('Privacy zone (Zone 2) text is readable in dark mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: OnboardingPrivacyZone()),
        ),
      );
      await tester.pump();

      _expectReadableText(tester, find.byType(OnboardingPrivacyZone));
    });

    testWidgets('Profile-creation zone (Zone 3) text is readable in dark mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conditionCatalogProvider.overrideWith(_FakeConditionCatalog.new),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: SingleChildScrollView(
                child: OnboardingProfileZone(
                  formKey: GlobalKey<FormState>(),
                  nameController: TextEditingController(),
                  nameFocusNode: FocusNode(),
                  isSubmitting: false,
                  onSubmit: (dateOfBirth, avatarPath, conditions) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      _expectReadableText(tester, find.byType(OnboardingProfileZone));
    });

    testWidgets('Weather opt-in sheet text is readable in dark mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: WeatherTrackingOptInSheet(onResult: (_) {}),
          ),
        ),
      );
      await tester.pump();

      _expectReadableText(tester, find.byType(WeatherTrackingOptInSheet));
    });
  });
}
