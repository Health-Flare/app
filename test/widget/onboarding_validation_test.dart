import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/features/onboarding/widgets/onboarding_profile_zone.dart';
import 'package:health_flare/models/condition.dart';

class _FakeConditionCatalog extends ConditionCatalogNotifier {
  @override
  List<Condition> build() => [];
}

/// Tests for onboarding profile-zone input validation edge cases.
///
/// Covers the scenarios added to docs/features/onboarding.feature:
///   - Profile name containing only whitespace keeps CTA disabled
void main() {
  group('OnboardingProfileZone — name validation', () {
    Widget buildZone({required TextEditingController nameController}) {
      return ProviderScope(
        overrides: [
          conditionCatalogProvider.overrideWith(_FakeConditionCatalog.new),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OnboardingProfileZone(
                formKey: GlobalKey<FormState>(),
                nameController: nameController,
                nameFocusNode: FocusNode(),
                isSubmitting: false,
                onSubmit: (dateOfBirth, avatarPath, conditions) {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('whitespace-only name keeps the CTA button disabled', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildZone(nameController: controller));

      // Enter whitespace-only — trim() yields empty, button must stay off.
      await tester.enterText(find.byType(TextFormField).first, '   ');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(
          ElevatedButton,
          'Create profile and get started  →',
        ),
      );
      expect(
        button.onPressed,
        isNull,
        reason: 'CTA must remain disabled when name is only whitespace',
      );
    });

    testWidgets('non-whitespace name enables the CTA button', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildZone(nameController: controller));

      await tester.enterText(find.byType(TextFormField).first, 'Sarah');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(
          ElevatedButton,
          'Create profile and get started  →',
        ),
      );
      expect(
        button.onPressed,
        isNotNull,
        reason: 'CTA must enable when a real name is entered',
      );
    });

    testWidgets(
      'name trimmed to empty after non-empty input disables CTA again',
      (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(buildZone(nameController: controller));

        // First enter a real name...
        await tester.enterText(find.byType(TextFormField).first, 'Sarah');
        await tester.pump();

        // ...then replace with whitespace only.
        await tester.enterText(find.byType(TextFormField).first, '   ');
        await tester.pump();

        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(
            ElevatedButton,
            'Create profile and get started  →',
          ),
        );
        expect(button.onPressed, isNull);
      },
    );
  });
}
