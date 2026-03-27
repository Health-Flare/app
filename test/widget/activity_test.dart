import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/activity_entry_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/activity/screens/activity_entry_form_screen.dart';
import 'package:health_flare/features/activity/screens/activity_list_screen.dart';
import 'package:health_flare/models/activity_entry.dart';
import 'package:health_flare/models/profile.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeActivityList extends ActivityEntryListNotifier {
  _FakeActivityList({this.entries = const []});
  final List<ActivityEntry> entries;

  @override
  List<ActivityEntry> build() => entries;
}

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _FakeProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [Profile(id: 1, name: 'Emma')];
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

final _now = DateTime(2026, 3, 20, 10, 0);

ActivityEntry makeActivity({
  int id = 1,
  String description = 'Morning walk',
  ActivityType? activityType = ActivityType.walking,
  int? effortLevel = 2,
  int? durationMinutes = 30,
  String? notes,
  DateTime? loggedAt,
}) => ActivityEntry(
  id: id,
  profileId: 1,
  description: description,
  activityType: activityType,
  effortLevel: effortLevel,
  durationMinutes: durationMinutes,
  notes: notes,
  loggedAt: loggedAt ?? _now,
  createdAt: _now,
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildListScreen({List<ActivityEntry> entries = const []}) {
  return ProviderScope(
    overrides: [
      activityEntryListProvider.overrideWith(
        () => _FakeActivityList(entries: entries),
      ),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Emma'),
      ),
      activeProfileActivityEntriesProvider.overrideWith(
        (ref) =>
            entries.where((e) => e.profileId == 1).toList()
              ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt)),
      ),
    ],
    child: const MaterialApp(home: ActivityListScreen()),
  );
}

Widget _buildFormScreen({ActivityEntry? entry}) {
  return ProviderScope(
    overrides: [
      activityEntryListProvider.overrideWith(_FakeActivityList.new),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Emma'),
      ),
    ],
    child: MaterialApp(home: ActivityEntryFormScreen(entry: entry)),
  );
}

// ---------------------------------------------------------------------------
// ActivityListScreen tests
// ---------------------------------------------------------------------------

void main() {
  group('ActivityListScreen', () {
    testWidgets('shows empty state when no activities', (tester) async {
      await tester.pumpWidget(_buildListScreen());
      await tester.pump();

      expect(find.text('No activities logged yet'), findsOneWidget);
      expect(find.text('Tap + to log your first activity'), findsOneWidget);
    });

    testWidgets('shows activity description in list', (tester) async {
      final entries = [makeActivity(description: 'Morning walk')];

      await tester.pumpWidget(_buildListScreen(entries: entries));
      await tester.pump();

      expect(find.text('Morning walk'), findsOneWidget);
    });

    testWidgets('shows effort badge for entries with effort level', (
      tester,
    ) async {
      final entries = [makeActivity(effortLevel: 3)];

      await tester.pumpWidget(_buildListScreen(entries: entries));
      await tester.pump();

      // Badge shows the effort number
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows multiple activities in list', (tester) async {
      final entries = [
        makeActivity(id: 1, description: 'Yoga'),
        makeActivity(
          id: 2,
          description: 'Grocery run',
          loggedAt: _now.add(const Duration(hours: 2)),
        ),
        makeActivity(
          id: 3,
          description: 'Doctor visit',
          loggedAt: _now.add(const Duration(hours: 4)),
        ),
      ];

      await tester.pumpWidget(_buildListScreen(entries: entries));
      await tester.pump();

      expect(find.text('Yoga'), findsOneWidget);
      expect(find.text('Grocery run'), findsOneWidget);
      expect(find.text('Doctor visit'), findsOneWidget);
    });

    testWidgets('shows profile name in app bar subtitle', (tester) async {
      await tester.pumpWidget(_buildListScreen());
      await tester.pump();

      expect(find.text('Emma'), findsOneWidget);
    });

    testWidgets('shows FAB for logging activity', (tester) async {
      await tester.pumpWidget(_buildListScreen());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // ActivityEntryFormScreen tests
  // ---------------------------------------------------------------------------

  group('ActivityEntryFormScreen — new entry', () {
    testWidgets('shows Log activity title', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      // Title appears in app bar + button — find at least one
      expect(find.text('Log activity'), findsWidgets);
    });

    testWidgets('shows Logging for attribution', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(find.text('Logging for Emma'), findsOneWidget);
    });

    testWidgets('shows required description field', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('shows description required error when submitting empty', (
      tester,
    ) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      // Tap the FilledButton (save), not the app bar title
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Description is required'), findsOneWidget);
    });

    testWidgets('shows effort level selector with 1–5 chips', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows duration and notes fields', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(find.text('Duration (optional)'), findsOneWidget);
      expect(find.text('Notes (optional)'), findsOneWidget);
    });
  });

  group('ActivityEntryFormScreen — edit entry', () {
    testWidgets('shows Edit activity title in edit mode', (tester) async {
      final entry = makeActivity(description: 'Yoga session');
      await tester.pumpWidget(_buildFormScreen(entry: entry));
      await tester.pump();

      expect(find.text('Edit activity'), findsOneWidget);
    });

    testWidgets('pre-fills description in edit mode', (tester) async {
      final entry = makeActivity(description: 'Evening stroll');
      await tester.pumpWidget(_buildFormScreen(entry: entry));
      await tester.pump();

      expect(find.text('Evening stroll'), findsOneWidget);
    });

    testWidgets('shows delete button in edit mode', (tester) async {
      final entry = makeActivity();
      await tester.pumpWidget(_buildFormScreen(entry: entry));
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('shows Save changes button in edit mode', (tester) async {
      final entry = makeActivity();
      await tester.pumpWidget(_buildFormScreen(entry: entry));
      await tester.pump();

      expect(find.text('Save changes'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // ActivityEntry model tests
  // ---------------------------------------------------------------------------

  group('ActivityEntry domain model', () {
    test('effortLabel returns formatted label', () {
      final entry = makeActivity(effortLevel: 3);
      expect(entry.effortLabel, '3 – Moderate');
    });

    test('effortLabel is null when no effort level set', () {
      final entry = makeActivity(effortLevel: null);
      expect(entry.effortLabel, isNull);
    });

    test('copyWith clears nullable fields', () {
      final entry = makeActivity(effortLevel: 2, durationMinutes: 30);
      final cleared = entry.copyWith(
        clearEffortLevel: true,
        clearDurationMinutes: true,
      );
      expect(cleared.effortLevel, isNull);
      expect(cleared.durationMinutes, isNull);
    });

    test('copyWith preserves non-cleared fields', () {
      final entry = makeActivity(
        description: 'Yoga',
        activityType: ActivityType.gentleExercise,
      );
      final updated = entry.copyWith(description: 'Gentle yoga');
      expect(updated.description, 'Gentle yoga');
      expect(updated.activityType, ActivityType.gentleExercise);
    });

    test('ActivityType.fromValue returns correct type', () {
      expect(ActivityType.fromValue('walking'), ActivityType.walking);
      expect(
        ActivityType.fromValue('gentle_exercise'),
        ActivityType.gentleExercise,
      );
      expect(ActivityType.fromValue('unknown'), isNull);
    });

    test('effortLabels map covers all 5 levels', () {
      for (int i = 1; i <= 5; i++) {
        expect(effortLabels[i], isNotNull);
      }
    });
  });
}
