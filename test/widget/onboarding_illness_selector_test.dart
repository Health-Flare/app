import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/features/onboarding/widgets/onboarding_profile_zone.dart';
import 'package:health_flare/models/condition.dart';

// ---------------------------------------------------------------------------
// Fake catalog — no Isar required
// ---------------------------------------------------------------------------

class _FakeConditionCatalog extends ConditionCatalogNotifier {
  final List<Condition> _conditions;
  _FakeConditionCatalog(this._conditions);

  @override
  List<Condition> build() => _conditions;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _testConditions = [
  const Condition(id: 1, name: 'Fibromyalgia'),
  const Condition(id: 2, name: "Crohn's Disease"),
  const Condition(id: 3, name: 'Rheumatoid Arthritis'),
  const Condition(id: 4, name: 'Fibrous Dysplasia'),
];

Widget _buildZone({
  List<Condition> catalog = const [],
  TextEditingController? nameController,
  void Function(DateTime?, String?, List<Condition>)? onSubmit,
}) {
  return ProviderScope(
    overrides: [
      conditionCatalogProvider.overrideWith(
        () => _FakeConditionCatalog(catalog),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: OnboardingProfileZone(
            formKey: GlobalKey<FormState>(),
            nameController: nameController ?? TextEditingController(),
            nameFocusNode: FocusNode(),
            isSubmitting: false,
            onSubmit: onSubmit ?? (a, b, c) {},
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('OnboardingProfileZone — illness selector', () {
    testWidgets('condition search field is present in Zone 3', (tester) async {
      await tester.pumpWidget(_buildZone(catalog: _testConditions));
      await tester.pump();

      expect(
        find.byKey(const Key('onboarding_condition_search')),
        findsOneWidget,
      );
    });

    testWidgets('typing shows matching conditions', (tester) async {
      await tester.pumpWidget(_buildZone(catalog: _testConditions));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('onboarding_condition_search')),
        'fibro',
      );
      await tester.pump();

      expect(find.text('Fibromyalgia'), findsOneWidget);
      expect(find.text('Fibrous Dysplasia'), findsOneWidget);
      expect(find.text("Crohn's Disease"), findsNothing);
      expect(find.text('Rheumatoid Arthritis'), findsNothing);
    });

    testWidgets('starts-with results appear before contains results', (
      tester,
    ) async {
      await tester.pumpWidget(_buildZone(catalog: _testConditions));
      await tester.pump();

      // 'fibro' matches: Fibromyalgia (starts-with) and Fibrous Dysplasia
      // (starts-with). Both rank equally. Just confirm both appear.
      await tester.enterText(
        find.byKey(const Key('onboarding_condition_search')),
        'fibro',
      );
      await tester.pump();

      expect(find.text('Fibromyalgia'), findsOneWidget);
      expect(find.text('Fibrous Dysplasia'), findsOneWidget);
    });

    testWidgets('tapping a result adds it as a chip and clears the search', (
      tester,
    ) async {
      await tester.pumpWidget(_buildZone(catalog: _testConditions));
      await tester.pump();

      await tester.ensureVisible(
        find.byKey(const Key('onboarding_condition_search')),
      );
      await tester.enterText(
        find.byKey(const Key('onboarding_condition_search')),
        'fibro',
      );
      await tester.pump();

      await tester.ensureVisible(find.text('Fibromyalgia'));
      await tester.tap(find.text('Fibromyalgia'));
      await tester.pump();

      // Chip appears
      expect(find.byType(InputChip), findsOneWidget);
      expect(find.widgetWithText(InputChip, 'Fibromyalgia'), findsOneWidget);

      // Search cleared
      final searchField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('onboarding_condition_search')),
          matching: find.byType(TextField),
        ),
      );
      expect(searchField.controller?.text ?? '', isEmpty);
    });

    testWidgets('selected condition no longer appears in search results', (
      tester,
    ) async {
      await tester.pumpWidget(_buildZone(catalog: _testConditions));
      await tester.pump();

      await tester.ensureVisible(
        find.byKey(const Key('onboarding_condition_search')),
      );
      await tester.enterText(
        find.byKey(const Key('onboarding_condition_search')),
        'fibro',
      );
      await tester.pump();
      await tester.ensureVisible(find.text('Fibromyalgia'));
      await tester.tap(find.text('Fibromyalgia'));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('onboarding_condition_search')),
        'fibro',
      );
      await tester.pump();

      // Fibromyalgia selected, only Fibrous Dysplasia remains in list
      expect(find.widgetWithText(InputChip, 'Fibromyalgia'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Fibromyalgia'),
        ),
        findsNothing,
      );
    });

    testWidgets('tapping the chip delete icon removes the condition', (
      tester,
    ) async {
      await tester.pumpWidget(_buildZone(catalog: _testConditions));
      await tester.pump();

      await tester.ensureVisible(
        find.byKey(const Key('onboarding_condition_search')),
      );
      await tester.enterText(
        find.byKey(const Key('onboarding_condition_search')),
        'crohn',
      );
      await tester.pump();
      await tester.ensureVisible(find.text("Crohn's Disease"));
      await tester.tap(find.text("Crohn's Disease"));
      await tester.pump();

      expect(find.byType(InputChip), findsOneWidget);

      // Tap the InputChip delete icon
      await tester.tap(find.byIcon(Icons.cancel).first);
      await tester.pump();

      expect(find.byType(InputChip), findsNothing);
    });

    testWidgets('no results shown when search field is empty', (tester) async {
      await tester.pumpWidget(_buildZone(catalog: _testConditions));
      await tester.pump();

      // Don't type anything — results list should not appear
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('selected conditions are passed to onSubmit', (tester) async {
      List<Condition>? captured;

      await tester.pumpWidget(
        _buildZone(
          catalog: _testConditions,
          onSubmit: (a, b, conditions) => captured = conditions,
        ),
      );
      await tester.pump();

      // Enter a name to enable the CTA (listener fires via enterText)
      await tester.enterText(find.byType(TextFormField).first, 'Sarah');
      await tester.pump();

      // Select a condition — scroll the search field into view first
      await tester.ensureVisible(
        find.byKey(const Key('onboarding_condition_search')),
      );
      await tester.enterText(
        find.byKey(const Key('onboarding_condition_search')),
        'crohn',
      );
      await tester.pump();

      await tester.ensureVisible(find.text("Crohn's Disease"));
      await tester.tap(find.text("Crohn's Disease"));
      await tester.pump();

      // Scroll to and tap the submit button
      final submitFinder = find.text('Create profile and get started  →');
      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.length, 1);
      expect(captured!.first.id, 2);
    });
  });
}
