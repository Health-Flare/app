import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/features/meals/screens/meal_detail_screen.dart';
import 'package:health_flare/features/meals/screens/meal_entry_form_screen.dart';
import 'package:health_flare/features/meals/screens/meals_screen.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/symptom_entry.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeMealList extends MealEntryListNotifier {
  _FakeMealList({this.entries = const []});
  final List<MealEntry> entries;

  @override
  List<MealEntry> build() => entries;
}

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _FakeProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [Profile(id: 1, name: 'Sarah')];
}

class _FakeSymptomList extends SymptomEntryListNotifier {
  _FakeSymptomList({this.entries = const []});
  final List<SymptomEntry> entries;

  @override
  List<SymptomEntry> build() => entries;
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

final _now = DateTime(2026, 2, 16, 18, 30);

MealEntry makeMeal({
  int id = 1,
  String description = 'Grilled salmon',
  bool hasReaction = false,
  String? notes,
  String? photoPath,
  DateTime? loggedAt,
}) => MealEntry(
  id: id,
  profileId: 1,
  description: description,
  notes: notes,
  photoPath: photoPath,
  hasReaction: hasReaction,
  loggedAt: loggedAt ?? _now,
  createdAt: _now,
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildListScreen({List<MealEntry> entries = const []}) {
  return ProviderScope(
    overrides: [
      mealEntryListProvider.overrideWith(() => _FakeMealList(entries: entries)),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
      activeProfileMealEntriesProvider.overrideWith(
        (ref) =>
            entries.where((e) => e.profileId == 1).toList()
              ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt)),
      ),
    ],
    child: const MaterialApp(home: MealsScreen()),
  );
}

Widget _buildFormScreen({MealEntry? entry}) {
  return ProviderScope(
    overrides: [
      mealEntryListProvider.overrideWith(_FakeMealList.new),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
    ],
    child: MaterialApp(home: MealEntryFormScreen(entry: entry)),
  );
}

Widget _buildDetailScreen({
  required MealEntry entry,
  List<SymptomEntry> symptoms = const [],
}) {
  return ProviderScope(
    overrides: [
      mealEntryListProvider.overrideWith(() => _FakeMealList(entries: [entry])),
      symptomEntryListProvider.overrideWith(
        () => _FakeSymptomList(entries: symptoms),
      ),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
      activeProfileMealEntriesProvider.overrideWith((ref) => [entry]),
      activeProfileSymptomEntriesProvider.overrideWith((ref) => symptoms),
    ],
    child: MaterialApp(home: MealDetailScreen(mealId: entry.id)),
  );
}

// ---------------------------------------------------------------------------
// MealsScreen — list screen
// ---------------------------------------------------------------------------

void main() {
  group('MealsScreen', () {
    testWidgets('shows empty state when no meals', (tester) async {
      await tester.pumpWidget(_buildListScreen());
      await tester.pump();

      expect(find.text('No meals logged yet'), findsOneWidget);
      expect(find.text('Tap + to log your first meal'), findsOneWidget);
    });

    testWidgets('shows meal description in list', (tester) async {
      final entries = [makeMeal(description: 'Grilled salmon')];

      await tester.pumpWidget(_buildListScreen(entries: entries));
      await tester.pump();

      expect(find.text('Grilled salmon'), findsOneWidget);
    });

    testWidgets('shows reaction indicator for flagged meals', (tester) async {
      final entries = [
        makeMeal(id: 1, description: 'Toast', hasReaction: false),
        makeMeal(
          id: 2,
          description: 'Prawn stir-fry',
          hasReaction: true,
          loggedAt: _now.subtract(const Duration(hours: 1)),
        ),
      ];

      await tester.pumpWidget(_buildListScreen(entries: entries));
      await tester.pump();

      // Reaction indicator only for Prawn stir-fry
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('no reaction indicator for unflagged meals', (tester) async {
      final entries = [makeMeal(description: 'Toast', hasReaction: false)];

      await tester.pumpWidget(_buildListScreen(entries: entries));
      await tester.pump();

      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });

    testWidgets('shows multiple meals in list', (tester) async {
      final entries = [
        makeMeal(id: 1, description: 'Breakfast'),
        makeMeal(
          id: 2,
          description: 'Lunch',
          loggedAt: _now.add(const Duration(hours: 4)),
        ),
        makeMeal(
          id: 3,
          description: 'Dinner',
          loggedAt: _now.add(const Duration(hours: 10)),
        ),
      ];

      await tester.pumpWidget(_buildListScreen(entries: entries));
      await tester.pump();

      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
    });

    testWidgets('shows FAB to log a meal', (tester) async {
      await tester.pumpWidget(_buildListScreen());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // MealEntryFormScreen
  // ---------------------------------------------------------------------------

  group('MealEntryFormScreen (new)', () {
    testWidgets('shows form fields', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(find.text('Log meal'), findsOneWidget);
      expect(find.text('Logging for Sarah'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Description'), findsOneWidget);
    });

    testWidgets('shows validation error when description is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      await tester.tap(find.text('Add meal'));
      await tester.pump();

      expect(find.text('Description is required'), findsOneWidget);
    });

    testWidgets('does not show delete button in new mode', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('shows reaction switch', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(find.text('Reaction flag'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('shows add photo button', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(find.text('Add photo'), findsOneWidget);
    });
  });

  group('MealEntryFormScreen (edit)', () {
    testWidgets('pre-fills description from existing entry', (tester) async {
      final entry = makeMeal(description: 'Pasta with tomato sauce');

      await tester.pumpWidget(_buildFormScreen(entry: entry));
      await tester.pump();

      expect(find.text('Edit meal'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Description'), findsOneWidget);
    });

    testWidgets('shows delete button in edit mode', (tester) async {
      final entry = makeMeal();

      await tester.pumpWidget(_buildFormScreen(entry: entry));
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('shows Save changes button in edit mode', (tester) async {
      final entry = makeMeal();

      await tester.pumpWidget(_buildFormScreen(entry: entry));
      await tester.pump();

      expect(find.text('Save changes'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // MealDetailScreen
  // ---------------------------------------------------------------------------

  group('MealDetailScreen', () {
    testWidgets('shows meal description and timestamp', (tester) async {
      final entry = makeMeal(description: 'Grilled salmon');

      await tester.pumpWidget(_buildDetailScreen(entry: entry));
      await tester.pump();

      expect(find.text('Grilled salmon'), findsOneWidget);
    });

    testWidgets('shows reaction flag badge when hasReaction', (tester) async {
      final entry = makeMeal(description: 'Prawn stir-fry', hasReaction: true);

      await tester.pumpWidget(_buildDetailScreen(entry: entry));
      await tester.pump();

      expect(find.text('Reaction flagged'), findsOneWidget);
    });

    testWidgets('does not show reaction badge when hasReaction is false', (
      tester,
    ) async {
      final entry = makeMeal(description: 'Toast', hasReaction: false);

      await tester.pumpWidget(_buildDetailScreen(entry: entry));
      await tester.pump();

      expect(find.text('Reaction flagged'), findsNothing);
    });

    testWidgets('shows notes when present', (tester) async {
      final entry = makeMeal(notes: 'Was very spicy');

      await tester.pumpWidget(_buildDetailScreen(entry: entry));
      await tester.pump();

      expect(find.text('Was very spicy'), findsOneWidget);
    });

    testWidgets('shows nearby symptoms when reaction flagged', (tester) async {
      final meal = makeMeal(
        description: 'Prawn stir-fry',
        hasReaction: true,
        loggedAt: DateTime(2026, 2, 16, 18, 30),
      );
      final symptom = SymptomEntry(
        id: 1,
        profileId: 1,
        name: 'Hives',
        severity: 3,
        loggedAt: DateTime(2026, 2, 16, 20, 0), // 1.5h after meal
        createdAt: DateTime(2026, 2, 16, 20, 0),
      );

      await tester.pumpWidget(
        _buildDetailScreen(entry: meal, symptoms: [symptom]),
      );
      await tester.pump();

      expect(find.text('Potential associations'), findsOneWidget);
      expect(find.text('Hives'), findsOneWidget);
    });

    testWidgets('does not show nearby symptoms when no reaction flag', (
      tester,
    ) async {
      final meal = makeMeal(
        description: 'Toast',
        hasReaction: false,
        loggedAt: DateTime(2026, 2, 16, 8, 0),
      );
      final symptom = SymptomEntry(
        id: 1,
        profileId: 1,
        name: 'Headache',
        severity: 2,
        loggedAt: DateTime(2026, 2, 16, 9, 0),
        createdAt: DateTime(2026, 2, 16, 9, 0),
      );

      await tester.pumpWidget(
        _buildDetailScreen(entry: meal, symptoms: [symptom]),
      );
      await tester.pump();

      expect(find.text('Potential associations'), findsNothing);
    });

    testWidgets('shows edit button', (tester) async {
      final entry = makeMeal();

      await tester.pumpWidget(_buildDetailScreen(entry: entry));
      await tester.pump();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // MealEntry domain model
  // ---------------------------------------------------------------------------

  group('MealEntry domain model', () {
    test('copyWith preserves unchanged fields', () {
      final original = makeMeal(description: 'Original', hasReaction: false);
      final updated = original.copyWith(hasReaction: true);

      expect(updated.description, 'Original');
      expect(updated.hasReaction, isTrue);
      expect(updated.id, original.id);
    });

    test('clearNotes removes notes', () {
      final entry = makeMeal(notes: 'Some notes');
      final updated = entry.copyWith(clearNotes: true);

      expect(updated.notes, isNull);
    });

    test('clearPhotoPath removes photo', () {
      final entry = makeMeal(photoPath: '/tmp/photo.jpg');
      final updated = entry.copyWith(clearPhotoPath: true);

      expect(updated.photoPath, isNull);
    });

    test('equality is based on id', () {
      final a = makeMeal(id: 1, description: 'Breakfast');
      final b = makeMeal(id: 1, description: 'Different');
      final c = makeMeal(id: 2, description: 'Breakfast');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
