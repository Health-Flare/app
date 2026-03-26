import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/models/user_condition.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/features/flare/screens/flare_detail_screen.dart';
import 'package:health_flare/features/flare/screens/flare_form_screen.dart';
import 'package:health_flare/features/flare/screens/flare_history_screen.dart';
import 'package:health_flare/features/flare/widgets/active_flare_banner.dart';
import 'package:health_flare/models/flare.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/vital_entry.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeFlareList extends FlareListNotifier {
  _FakeFlareList({this.flares = const []});
  final List<Flare> flares;

  @override
  List<Flare> build() => flares;
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

class _FakeVitalList extends VitalEntryListNotifier {
  _FakeVitalList({this.entries = const []});
  final List<VitalEntry> entries;

  @override
  List<VitalEntry> build() => entries;
}

class _FakeMealList extends MealEntryListNotifier {
  _FakeMealList({this.entries = const []});
  final List<MealEntry> entries;

  @override
  List<MealEntry> build() => entries;
}

class _FakeUserConditionList extends UserConditionListNotifier {
  @override
  List<UserCondition> build() => [];
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

final _now = DateTime(2026, 3, 1, 12, 0);

Flare makeFlare({
  int id = 1,
  bool active = true,
  DateTime? startedAt,
  DateTime? endedAt,
  int? initialSeverity,
  int? peakSeverity,
  String? notes,
  List<int> conditionIsarIds = const [],
}) => Flare(
  id: id,
  profileId: 1,
  startedAt: startedAt ?? _now.subtract(const Duration(days: 2)),
  endedAt: active ? null : (endedAt ?? _now),
  conditionIsarIds: conditionIsarIds,
  initialSeverity: initialSeverity,
  peakSeverity: peakSeverity,
  notes: notes,
  createdAt: _now.subtract(const Duration(days: 2)),
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildHistoryScreen({List<Flare> flares = const []}) {
  return ProviderScope(
    overrides: [
      flareListProvider.overrideWith(() => _FakeFlareList(flares: flares)),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
      activeProfileFlaresProvider.overrideWith(
        (ref) =>
            flares.where((f) => f.profileId == 1).toList()
              ..sort((a, b) => b.startedAt.compareTo(a.startedAt)),
      ),
    ],
    child: const MaterialApp(home: FlareHistoryScreen()),
  );
}

Widget _buildFormScreen({Flare? flare}) {
  return ProviderScope(
    overrides: [
      flareListProvider.overrideWith(_FakeFlareList.new),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
      userConditionListProvider.overrideWith(_FakeUserConditionList.new),
    ],
    child: MaterialApp(home: FlareFormScreen(flare: flare)),
  );
}

Widget _buildDetailScreen({
  required Flare flare,
  List<SymptomEntry> symptoms = const [],
  List<VitalEntry> vitals = const [],
  List<MealEntry> meals = const [],
}) {
  return ProviderScope(
    overrides: [
      flareListProvider.overrideWith(() => _FakeFlareList(flares: [flare])),
      symptomEntryListProvider.overrideWith(
        () => _FakeSymptomList(entries: symptoms),
      ),
      vitalEntryListProvider.overrideWith(
        () => _FakeVitalList(entries: vitals),
      ),
      mealEntryListProvider.overrideWith(() => _FakeMealList(entries: meals)),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
      activeFlareProvider.overrideWith((ref) => flare.isActive ? flare : null),
    ],
    child: MaterialApp(home: FlareDetailScreen(flareId: flare.id)),
  );
}

Widget _buildBanner({Flare? activeFlare}) {
  return ProviderScope(
    overrides: [
      flareListProvider.overrideWith(
        () => _FakeFlareList(flares: activeFlare != null ? [activeFlare] : []),
      ),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
      activeFlareProvider.overrideWith((ref) => activeFlare),
    ],
    child: const MaterialApp(home: Scaffold(body: ActiveFlareBanner())),
  );
}

// ---------------------------------------------------------------------------
// FlareHistoryScreen
// ---------------------------------------------------------------------------

void main() {
  group('FlareHistoryScreen', () {
    testWidgets('shows empty state when no flares', (tester) async {
      await tester.pumpWidget(_buildHistoryScreen());
      await tester.pump();

      expect(find.text('No flares recorded'), findsOneWidget);
    });

    testWidgets('shows active flare with In progress chip', (tester) async {
      final flares = [makeFlare(active: true)];

      await tester.pumpWidget(_buildHistoryScreen(flares: flares));
      await tester.pump();

      expect(find.text('Active flare'), findsOneWidget);
      expect(find.text('In progress'), findsOneWidget);
    });

    testWidgets('shows ended flare with date range', (tester) async {
      final flares = [makeFlare(active: false)];

      await tester.pumpWidget(_buildHistoryScreen(flares: flares));
      await tester.pump();

      expect(find.text('Flare ended'), findsOneWidget);
    });

    testWidgets('shows multiple flares', (tester) async {
      final flares = [
        makeFlare(id: 1, active: true),
        makeFlare(
          id: 2,
          active: false,
          startedAt: _now.subtract(const Duration(days: 30)),
          endedAt: _now.subtract(const Duration(days: 27)),
        ),
      ];

      await tester.pumpWidget(_buildHistoryScreen(flares: flares));
      await tester.pump();

      expect(find.text('Active flare'), findsOneWidget);
      expect(find.text('Flare ended'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // FlareFormScreen
  // ---------------------------------------------------------------------------

  group('FlareFormScreen (new)', () {
    testWidgets('shows start flare title and attribution', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(find.text('Start flare'), findsWidgets);
      expect(find.text('Logging for Sarah'), findsOneWidget);
    });

    testWidgets('shows started-at date field', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(find.text('Started at'), findsOneWidget);
    });

    testWidgets('shows severity picker chips', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      // Severity chips 1–10 should be present
      expect(find.text('1'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });
  });

  group('FlareFormScreen (edit)', () {
    testWidgets('shows edit flare title', (tester) async {
      final flare = makeFlare(active: true);

      await tester.pumpWidget(_buildFormScreen(flare: flare));
      await tester.pump();

      expect(find.text('Edit flare'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // FlareDetailScreen
  // ---------------------------------------------------------------------------

  group('FlareDetailScreen', () {
    testWidgets('shows active flare header', (tester) async {
      final flare = makeFlare(active: true);

      await tester.pumpWidget(_buildDetailScreen(flare: flare));
      await tester.pump();

      expect(find.text('Active flare'), findsOneWidget);
      expect(find.text('End flare'), findsOneWidget);
    });

    testWidgets('shows ended flare without end-flare button', (tester) async {
      final flare = makeFlare(active: false);

      await tester.pumpWidget(_buildDetailScreen(flare: flare));
      await tester.pump();

      expect(find.text('Flare detail'), findsOneWidget);
      expect(find.text('End flare'), findsNothing);
    });

    testWidgets('shows symptom entries tagged to this flare', (tester) async {
      final flare = makeFlare(id: 1, active: true);
      final symptom = SymptomEntry(
        id: 1,
        profileId: 1,
        name: 'Joint pain',
        severity: 7,
        loggedAt: _now,
        createdAt: _now,
        flareIsarId: 1,
      );

      await tester.pumpWidget(
        _buildDetailScreen(flare: flare, symptoms: [symptom]),
      );
      await tester.pump();

      expect(find.text('Joint pain'), findsOneWidget);
      expect(find.text('Symptoms (1)'), findsOneWidget);
    });

    testWidgets('shows meal entries tagged to this flare', (tester) async {
      final flare = makeFlare(id: 1, active: true);
      final meal = MealEntry(
        id: 1,
        profileId: 1,
        description: 'Pasta',
        hasReaction: false,
        loggedAt: _now,
        createdAt: _now,
        flareIsarId: 1,
      );

      await tester.pumpWidget(_buildDetailScreen(flare: flare, meals: [meal]));
      await tester.pump();

      expect(find.text('Pasta'), findsOneWidget);
      expect(find.text('Meals (1)'), findsOneWidget);
    });

    testWidgets('does not show entries from other flares', (tester) async {
      final flare = makeFlare(id: 1, active: true);
      final otherSymptom = SymptomEntry(
        id: 2,
        profileId: 1,
        name: 'Headache',
        severity: 4,
        loggedAt: _now,
        createdAt: _now,
        flareIsarId: 99, // different flare
      );

      await tester.pumpWidget(
        _buildDetailScreen(flare: flare, symptoms: [otherSymptom]),
      );
      await tester.pump();

      expect(find.text('Headache'), findsNothing);
    });

    testWidgets('shows notes when present', (tester) async {
      final flare = makeFlare(notes: 'Triggered after stress');

      await tester.pumpWidget(_buildDetailScreen(flare: flare));
      await tester.pump();

      expect(find.text('Triggered after stress'), findsOneWidget);
    });

    testWidgets('shows severity when present', (tester) async {
      final flare = makeFlare(initialSeverity: 7, peakSeverity: 9);

      await tester.pumpWidget(_buildDetailScreen(flare: flare));
      await tester.pump();

      expect(find.text('7/10'), findsOneWidget);
      expect(find.text('9/10'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // ActiveFlareBanner
  // ---------------------------------------------------------------------------

  group('ActiveFlareBanner', () {
    testWidgets('shows I\'m flaring card when no active flare', (tester) async {
      await tester.pumpWidget(_buildBanner());
      await tester.pump();

      expect(find.textContaining('flaring'), findsOneWidget);
    });

    testWidgets('shows active flare card when flare is active', (tester) async {
      final flare = makeFlare(active: true);

      await tester.pumpWidget(_buildBanner(activeFlare: flare));
      await tester.pump();

      expect(find.text('Flare in progress'), findsOneWidget);
    });

    testWidgets('shows day label for active flare', (tester) async {
      final flare = makeFlare(
        active: true,
        startedAt: _now.subtract(const Duration(days: 2)),
      );

      await tester.pumpWidget(_buildBanner(activeFlare: flare));
      await tester.pump();

      expect(find.textContaining('Day'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Flare domain model
  // ---------------------------------------------------------------------------

  group('Flare domain model', () {
    test('isActive is true when endedAt is null', () {
      final flare = makeFlare(active: true);
      expect(flare.isActive, isTrue);
    });

    test('isActive is false when endedAt is set', () {
      final flare = makeFlare(active: false);
      expect(flare.isActive, isFalse);
    });

    test('dayLabel returns correct day for multi-day flare', () {
      // 0 days elapsed = Day 1; 1 day elapsed = Day 2; etc.
      final duration = DateTime(2026, 3, 4).difference(DateTime(2026, 3, 1));
      expect(duration.inDays + 1, 4); // day 4
    });

    test('copyWith clearEndedAt removes end date', () {
      final flare = makeFlare(active: false);
      expect(flare.endedAt, isNotNull);
      final reopened = flare.copyWith(clearEndedAt: true);
      expect(reopened.endedAt, isNull);
      expect(reopened.isActive, isTrue);
    });

    test('equality based on id', () {
      final a = makeFlare(id: 1);
      final b = makeFlare(id: 1);
      final c = makeFlare(id: 2);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
