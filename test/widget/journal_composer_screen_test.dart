import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/journal/screens/journal_composer_screen.dart';
import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/models/profile.dart';

// ---------------------------------------------------------------------------
// Fakes — subclass real notifiers, override build() to skip Isar
// ---------------------------------------------------------------------------

class _FakeJournalList extends JournalEntryListNotifier {
  final List<JournalEntry> _initial;
  _FakeJournalList([this._initial = const []]);

  @override
  List<JournalEntry> build() => List.of(_initial);

  @override
  Future<int> add({
    required int profileId,
    required DateTime createdAt,
    required JournalSnapshot firstSnapshot,
    int? mood,
    int? energyLevel,
  }) async => 42;

  @override
  Future<void> appendSnapshot(int id, JournalSnapshot snapshot) async {}

  @override
  Future<void> update(JournalEntry updated) async {}

  @override
  Future<void> undo(int id) async {}

  @override
  Future<void> remove(int id) async {}
}

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

JournalEntry _entry({
  int id = 1,
  String body = 'Test body',
  String? title,
  JournalMood? mood,
  int? energyLevel,
}) {
  final ts = DateTime(2026, 2, 14, 10, 0);
  return JournalEntry(
    id: id,
    profileId: 1,
    createdAt: ts,
    snapshots: [JournalSnapshot(body: body, title: title, savedAt: ts)],
    mood: mood?.index,
    energyLevel: energyLevel,
  );
}

final _fakeProfile = Profile(id: 1, name: 'Ethan');

Widget _buildComposer({int? entryId, List<JournalEntry> entries = const []}) {
  return ProviderScope(
    overrides: [
      journalEntryListProvider.overrideWith(() => _FakeJournalList(entries)),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      activeProfileDataProvider.overrideWith((_) => _fakeProfile),
    ],
    child: MaterialApp(home: JournalComposerScreen(entryId: entryId)),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('JournalComposerScreen', () {
    group('create mode', () {
      testWidgets('body text field is present', (tester) async {
        await tester.pumpWidget(_buildComposer());
        await tester.pump();

        expect(find.byType(TextField), findsAtLeastNWidgets(1));
      });

      testWidgets('"+ Add title" is shown initially', (tester) async {
        await tester.pumpWidget(_buildComposer());
        await tester.pump();

        expect(find.text('+ Add title'), findsOneWidget);
      });

      testWidgets('tapping "+ Add title" reveals title field', (tester) async {
        await tester.pumpWidget(_buildComposer());
        await tester.pump();

        await tester.tap(find.text('+ Add title'));
        await tester.pump();

        // Two TextFields: title + body
        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.text('Title (optional)'), findsOneWidget);
      });

      testWidgets('Mood chip shows "Mood" when unset', (tester) async {
        await tester.pumpWidget(_buildComposer());
        await tester.pump();

        expect(find.text('Mood'), findsOneWidget);
      });

      testWidgets('Energy chip shows "Energy" when unset', (tester) async {
        await tester.pumpWidget(_buildComposer());
        await tester.pump();

        expect(find.text('Energy'), findsOneWidget);
      });

      testWidgets('tapping Mood chip opens bottom sheet with 5 options', (
        tester,
      ) async {
        await tester.pumpWidget(_buildComposer());
        await tester.pump();

        await tester.tap(find.text('Mood'));
        await tester.pumpAndSettle();

        expect(find.text('Great'), findsOneWidget);
        expect(find.text('Okay'), findsOneWidget);
        expect(find.text('Not great'), findsOneWidget);
        expect(find.text('Rough'), findsOneWidget);
        expect(find.text('Terrible'), findsOneWidget);
      });

      testWidgets('tapping Energy chip opens bottom sheet with levels 1–5', (
        tester,
      ) async {
        await tester.pumpWidget(_buildComposer());
        await tester.pump();

        await tester.tap(find.text('Energy'));
        await tester.pumpAndSettle();

        expect(find.text('Exhausted'), findsOneWidget);
        expect(find.text('Great'), findsOneWidget);
        for (int i = 1; i <= 5; i++) {
          expect(find.text('$i'), findsOneWidget);
        }
      });

      testWidgets('selecting a mood updates the Mood chip label', (
        tester,
      ) async {
        await tester.pumpWidget(_buildComposer());
        await tester.pump();

        await tester.tap(find.text('Mood'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Rough'));
        await tester.pumpAndSettle();

        expect(find.text('😔 Rough'), findsOneWidget);
        expect(find.text('Mood'), findsNothing);
      });

      testWidgets('selecting an energy level updates the Energy chip label', (
        tester,
      ) async {
        await tester.pumpWidget(_buildComposer());
        await tester.pump();

        await tester.tap(find.text('Energy'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        expect(find.text('Energy: 2'), findsOneWidget);
        expect(find.text('Energy'), findsNothing);
      });

      testWidgets(
        'tapping the same mood again in the sheet clears the selection',
        (tester) async {
          await tester.pumpWidget(_buildComposer());
          await tester.pump();

          // Select "Okay"
          await tester.tap(find.text('Mood'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Okay'));
          await tester.pumpAndSettle();

          expect(find.text('🙂 Okay'), findsOneWidget);

          // Re-open and tap "Okay" again to deselect
          await tester.tap(find.text('🙂 Okay'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Okay'));
          await tester.pumpAndSettle();

          expect(find.text('Mood'), findsOneWidget);
        },
      );
    });

    group('edit mode', () {
      testWidgets('body field is pre-filled with existing entry text', (
        tester,
      ) async {
        final entry = _entry(body: 'Rough day but managed a short walk');
        await tester.pumpWidget(
          _buildComposer(entryId: entry.id, entries: [entry]),
        );
        await tester.pump();

        expect(find.text('Rough day but managed a short walk'), findsOneWidget);
      });

      testWidgets('title field is pre-filled when entry has a title', (
        tester,
      ) async {
        final entry = _entry(
          body: 'Some body text',
          title: 'Appointment with Dr. Chen',
        );
        await tester.pumpWidget(
          _buildComposer(entryId: entry.id, entries: [entry]),
        );
        await tester.pump();

        expect(find.text('Appointment with Dr. Chen'), findsOneWidget);
      });

      testWidgets('mood chip shows existing mood', (tester) async {
        final entry = _entry(body: 'Body', mood: JournalMood.rough);
        await tester.pumpWidget(
          _buildComposer(entryId: entry.id, entries: [entry]),
        );
        // Extra frame for initState postFrameCallback
        await tester.pump();
        await tester.pump();

        expect(find.text('😔 Rough'), findsOneWidget);
      });

      testWidgets('energy chip shows existing energy level', (tester) async {
        final entry = _entry(body: 'Body', energyLevel: 2);
        await tester.pumpWidget(
          _buildComposer(entryId: entry.id, entries: [entry]),
        );
        await tester.pump();
        await tester.pump();

        expect(find.text('Energy: 2'), findsOneWidget);
      });
    });
  });
}
