import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/illness/screens/illness_screen.dart';
import 'package:health_flare/models/condition.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/symptom.dart';
import 'package:health_flare/models/user_condition.dart';
import 'package:health_flare/models/user_symptom.dart';

// ---------------------------------------------------------------------------
// Fake notifiers: subclass real notifiers, override build() to skip Isar
// ---------------------------------------------------------------------------

class _FakeConditionCatalog extends ConditionCatalogNotifier {
  _FakeConditionCatalog(this.items, [this.onAddCustom]);
  final List<Condition> items;
  final void Function(String name)? onAddCustom;

  @override
  List<Condition> build() => items;

  @override
  Future<Condition> addCustom(String name) async {
    onAddCustom?.call(name);
    final c = Condition(id: 999, name: name.trim(), global: false);
    state = [...state, c];
    return c;
  }
}

class _FakeSymptomCatalog extends SymptomCatalogNotifier {
  @override
  List<Symptom> build() => [
    const Symptom(id: 1, name: 'Fatigue', global: true),
    const Symptom(id: 2, name: 'Joint pain', global: true),
  ];
}

class _FakeUserConditions extends UserConditionListNotifier {
  _FakeUserConditions([this.items = const []]);
  final List<UserCondition> items;

  @override
  List<UserCondition> build() => items;
}

class _FakeUserSymptoms extends UserSymptomListNotifier {
  @override
  List<UserSymptom> build() => [];
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget buildIllnessScreen({
  List<Condition> conditions = const [],
  List<UserCondition> trackedConditions = const [],
  IllnessScreenPrefill? prefill,
  void Function(String name)? onAddCustom,
}) {
  return ProviderScope(
    overrides: [
      conditionCatalogProvider.overrideWith(
        () => _FakeConditionCatalog(conditions, onAddCustom),
      ),
      symptomCatalogProvider.overrideWith(_FakeSymptomCatalog.new),
      userConditionListProvider.overrideWith(
        () => _FakeUserConditions(trackedConditions),
      ),
      userSymptomListProvider.overrideWith(_FakeUserSymptoms.new),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
    ],
    child: MaterialApp(home: IllnessScreen(prefill: prefill)),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('IllnessScreen: custom condition guard', () {
    testWidgets('whitespace search query does not show Add custom tile', (
      tester,
    ) async {
      await tester.pumpWidget(buildIllnessScreen());
      await tester.pump();

      // Whitespace trims to empty → _query is '' → not shown.
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();

      expect(
        find.textContaining('as a custom illness'),
        findsNothing,
        reason: 'Whitespace-only search must not show "Add custom"',
      );
    });

    testWidgets('case-insensitive exact match suppresses Add custom tile', (
      tester,
    ) async {
      const arthritis = Condition(id: 1, name: 'Arthritis', global: true);
      await tester.pumpWidget(buildIllnessScreen(conditions: [arthritis]));
      await tester.pump();

      // rankSearch is case-insensitive: "ARTHRITIS" matches "Arthritis".
      await tester.enterText(find.byType(TextField), 'ARTHRITIS');
      await tester.pump();

      // filteredConditions is non-empty → _AddCustomTile not shown.
      expect(find.textContaining('as a custom illness'), findsNothing);
      // The matched condition remains visible.
      expect(find.text('Arthritis'), findsOneWidget);
    });

    testWidgets('unmatched search shows Add custom tile', (tester) async {
      const arthritis = Condition(id: 1, name: 'Arthritis', global: true);
      await tester.pumpWidget(buildIllnessScreen(conditions: [arthritis]));
      await tester.pump();

      await tester.enterText(
        find.byType(TextField),
        'Myalgic encephalomyelitis',
      );
      await tester.pump();

      expect(find.textContaining('as a custom illness'), findsOneWidget);
    });
  });

  group('IllnessScreen: Add custom only hides on an exact match (#26)', () {
    // Spec (main): "Searching for an exact catalogue match suppresses the Add
    // custom option"; "An Add custom option appears when no condition matches
    // the search ... And no existing condition exactly matches". A partial
    // match used to hide it, so text sharing a word with a catalogue name
    // could not be saved at all.
    const catalogue = [
      Condition(id: 1, name: "Crohn's disease", global: true),
      Condition(id: 2, name: 'Ulcerative colitis', global: true),
    ];

    testWidgets('a partial match still offers Add custom, alongside the '
        'matches', (tester) async {
      await tester.pumpWidget(buildIllnessScreen(conditions: catalogue));
      await tester.pump();

      await tester.enterText(find.byType(TextField), "Crohn's");
      await tester.pump();

      expect(find.text("Crohn's disease"), findsOneWidget);
      expect(find.textContaining('as a custom illness'), findsOneWidget);
    });

    testWidgets('someone with plain "Colitis" can add it, though four '
        'catalogue names contain the word', (tester) async {
      // The real catalogue has Ischemic, Microscopic, Pseudomembranous and
      // Ulcerative colitis, but no "Colitis". Typing it used to list those
      // four and offer no way to save what was typed.
      final added = <String>[];
      await tester.pumpWidget(
        buildIllnessScreen(
          conditions: const [
            Condition(id: 1, name: 'Ischemic colitis', global: true),
            Condition(id: 2, name: 'Microscopic colitis', global: true),
            Condition(id: 3, name: 'Ulcerative colitis', global: true),
          ],
          onAddCustom: added.add,
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Colitis');
      await tester.pump();
      expect(find.text('Ulcerative colitis'), findsOneWidget);
      await tester.tap(find.textContaining('as a custom illness'));
      await tester.pump();

      expect(added, ['Colitis']);
    });

    testWidgets("text that matches nothing still offers it (\"Crohn's "
        'colitis")', (tester) async {
      final added = <String>[];
      await tester.pumpWidget(
        buildIllnessScreen(conditions: catalogue, onAddCustom: added.add),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), "Crohn's colitis");
      await tester.pump();
      await tester.tap(find.textContaining('as a custom illness'));
      await tester.pump();

      expect(added, ["Crohn's colitis"]);
    });

    testWidgets('an exact match with different case and spaces still hides '
        'it', (tester) async {
      await tester.pumpWidget(buildIllnessScreen(conditions: catalogue));
      await tester.pump();

      await tester.enterText(find.byType(TextField), "  crohn's DISEASE ");
      await tester.pump();

      expect(find.text("Crohn's disease"), findsOneWidget);
      expect(find.textContaining('as a custom illness'), findsNothing);
    });

    testWidgets('an exact match to a condition already tracked is not offered '
        'as a duplicate', (tester) async {
      await tester.pumpWidget(
        buildIllnessScreen(
          conditions: catalogue,
          trackedConditions: [
            UserCondition(
              id: 1,
              profileId: 1,
              conditionId: 1,
              conditionName: "Crohn's disease",
              trackedSince: DateTime(2026),
            ),
          ],
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), "Crohn's disease");
      await tester.pump();

      // Tracked conditions are left out of the list, but the name is still
      // taken: adding it again would make a second catalogue entry.
      expect(find.textContaining('as a custom illness'), findsNothing);
    });

    testWidgets('an exact match to an earlier custom condition hides it too', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildIllnessScreen(
          conditions: [
            ...catalogue,
            const Condition(id: 3, name: 'Long COVID', global: false),
          ],
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'long covid');
      await tester.pump();

      expect(find.textContaining('as a custom illness'), findsNothing);
    });
  });

  group('IllnessScreen: Add to profile button state', () {
    testWidgets('"Add to profile" is disabled with no selections', (
      tester,
    ) async {
      const arthritis = Condition(id: 1, name: 'Arthritis', global: true);
      await tester.pumpWidget(buildIllnessScreen(conditions: [arthritis]));
      await tester.pump();

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Add to profile'),
      );
      expect(
        button.onPressed,
        isNull,
        reason:
            '"Add to profile" must be disabled until a condition or symptom is chosen',
      );
    });

    testWidgets('tapping a condition enables "Add to profile"', (tester) async {
      const arthritis = Condition(id: 1, name: 'Arthritis', global: true);
      await tester.pumpWidget(buildIllnessScreen(conditions: [arthritis]));
      await tester.pump();

      await tester.tap(find.text('Arthritis'));
      await tester.pump();

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Add to profile'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets(
      'search filter shows starts-with results before contains results',
      (tester) async {
        const conditions = [
          Condition(id: 1, name: 'Arthritis', global: true),
          Condition(id: 2, name: 'Osteoarthritis', global: true),
          Condition(id: 3, name: 'Reactive arthritis', global: true),
        ];
        await tester.pumpWidget(buildIllnessScreen(conditions: conditions));
        await tester.pump();

        await tester.enterText(find.byType(TextField), 'arth');
        await tester.pump();

        // All three contain 'arth': all should be visible.
        expect(find.text('Arthritis'), findsOneWidget);
        expect(find.text('Osteoarthritis'), findsOneWidget);
        expect(find.text('Reactive arthritis'), findsOneWidget);
      },
    );
  });

  group('IllnessScreen: arriving from Quick Log "Add details"', () {
    testWidgets(
      'a matched catalogue condition is pre-selected, not shown for search',
      (tester) async {
        const fibromyalgia = Condition(id: 1, name: 'Fibromyalgia');
        await tester.pumpWidget(
          buildIllnessScreen(
            conditions: [fibromyalgia],
            prefill: const IllnessScreenPrefill(
              query: 'Just found out I have fibromyalgia',
              conditionId: 1,
            ),
          ),
        );
        await tester.pump();

        // Pre-selected → shown as a removable "Selected" chip (and still
        // listed below, since only already-tracked conditions are excluded
        // from the browsable list: pending selections are not).
        expect(find.text('Fibromyalgia'), findsWidgets);
        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Add to profile'),
        );
        expect(button.onPressed, isNotNull);
      },
    );

    testWidgets(
      'unmatched typed text pre-fills the search bar instead of selecting '
      'anything',
      (tester) async {
        const arthritis = Condition(id: 1, name: 'Arthritis');
        await tester.pumpWidget(
          buildIllnessScreen(
            conditions: [arthritis],
            prefill: const IllnessScreenPrefill(
              query: 'Myalgic encephalomyelitis',
            ),
          ),
        );
        await tester.pump();

        expect(
          find.text('Myalgic encephalomyelitis'),
          findsOneWidget,
          reason: 'search bar should start filled with the typed text',
        );
        expect(find.textContaining('as a custom illness'), findsOneWidget);
        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Add to profile'),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets(
      'a condition already tracked is not pre-selected as a duplicate',
      (tester) async {
        const fibromyalgia = Condition(id: 1, name: 'Fibromyalgia');
        await tester.pumpWidget(
          buildIllnessScreen(
            conditions: [fibromyalgia],
            trackedConditions: [
              UserCondition(
                id: 1,
                profileId: 1,
                conditionId: 1,
                conditionName: 'Fibromyalgia',
                trackedSince: DateTime(2026),
              ),
            ],
            prefill: const IllnessScreenPrefill(
              query: 'fibromyalgia flare',
              conditionId: 1,
            ),
          ),
        );
        await tester.pump();

        // Already tracked → excluded from the selectable list and not
        // re-added as a pending "Selected" chip.
        expect(find.text('Fibromyalgia'), findsNothing);
        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Add to profile'),
        );
        expect(button.onPressed, isNull);
      },
    );
  });
}
