import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/journal/screens/journal_list_screen.dart';
import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/models/profile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

JournalEntry _entry({
  int id = 1,
  int profileId = 1,
  DateTime? createdAt,
  String body = 'Test body',
  String? title,
  JournalMood? mood,
  int? energyLevel,
}) {
  final ts = createdAt ?? DateTime(2026, 2, 14, 10, 0);
  return JournalEntry(
    id: id,
    profileId: profileId,
    createdAt: ts,
    snapshots: [JournalSnapshot(body: body, title: title, savedAt: ts)],
    mood: mood?.index,
    energyLevel: energyLevel,
  );
}

final _sarahProfile = Profile(id: 1, name: 'Sarah');

Widget _buildList({
  List<JournalEntry> allEntries = const [],
  List<JournalEntry>? filteredEntries,
  String searchQuery = '',
}) {
  final displayed = filteredEntries ?? allEntries;
  return ProviderScope(
    overrides: [
      activeProfileDataProvider.overrideWith((ref) => _sarahProfile),
      activeProfileJournalProvider.overrideWith((ref) => allEntries),
      filteredJournalProvider.overrideWith((ref) => displayed),
      journalSearchQueryProvider.overrideWith((ref) => searchQuery),
    ],
    child: const MaterialApp(home: JournalListScreen()),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('JournalListScreen', () {
    group('empty state', () {
      testWidgets('shows encouraging message when no entries', (tester) async {
        await tester.pumpWidget(_buildList());
        await tester.pump();

        expect(find.text('Nothing written yet.'), findsOneWidget);
      });

      testWidgets('FAB is visible in empty state', (tester) async {
        await tester.pumpWidget(_buildList());
        await tester.pump();

        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    group('entry list', () {
      testWidgets('profile name appears in AppBar', (tester) async {
        final entries = [_entry()];
        await tester.pumpWidget(_buildList(allEntries: entries));
        await tester.pump();

        expect(find.text('Sarah'), findsOneWidget);
      });

      testWidgets('entry with title shows title in card', (tester) async {
        final entries = [_entry(title: 'Week 3 notes', body: 'Rough week')];
        await tester.pumpWidget(_buildList(allEntries: entries));
        await tester.pump();

        expect(find.text('Week 3 notes'), findsOneWidget);
      });

      testWidgets('entry without title shows first line of body as preview', (
        tester,
      ) async {
        final entries = [_entry(body: 'Joint pain all day')];
        await tester.pumpWidget(_buildList(allEntries: entries));
        await tester.pump();

        expect(find.text('Joint pain all day'), findsOneWidget);
      });

      testWidgets('shows mood emoji when mood is set', (tester) async {
        final entries = [_entry(mood: JournalMood.okay)];
        await tester.pumpWidget(_buildList(allEntries: entries));
        await tester.pump();

        // 🙂 is the emoji for JournalMood.okay
        expect(find.text('🙂'), findsOneWidget);
      });

      testWidgets('shows energy dot semantics label when energy level is set', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        final entries = [_entry(energyLevel: 3)];
        await tester.pumpWidget(_buildList(allEntries: entries));
        await tester.pump();

        // The energy label is merged into the card's combined semantics label
        expect(
          find.bySemanticsLabel(RegExp('Energy: 3 out of 5')),
          findsOneWidget,
        );
        handle.dispose();
      });

      testWidgets('entries appear with most recent first', (tester) async {
        final entries = [
          _entry(
            id: 3,
            title: 'Post-appointment',
            createdAt: DateTime(2026, 2, 17, 16, 0),
          ),
          _entry(
            id: 2,
            title: 'Better this week',
            createdAt: DateTime(2026, 2, 14, 20, 30),
          ),
          _entry(
            id: 1,
            title: 'Rough start',
            createdAt: DateTime(2026, 2, 10, 9, 0),
          ),
        ];
        await tester.pumpWidget(_buildList(allEntries: entries));
        await tester.pump();

        final postDy = tester.getTopLeft(find.text('Post-appointment')).dy;
        final roughDy = tester.getTopLeft(find.text('Rough start')).dy;
        expect(postDy, lessThan(roughDy));
      });

      testWidgets('shows month header for entries', (tester) async {
        final entries = [_entry(id: 1, createdAt: DateTime(2026, 2, 14))];
        await tester.pumpWidget(_buildList(allEntries: entries));
        await tester.pump();

        expect(find.text('February 2026'), findsOneWidget);
      });

      testWidgets('shows separate month headers for two months', (
        tester,
      ) async {
        final entries = [
          _entry(
            id: 2,
            title: 'February entry',
            createdAt: DateTime(2026, 2, 14),
          ),
          _entry(
            id: 1,
            title: 'January entry',
            createdAt: DateTime(2026, 1, 20),
          ),
        ];
        await tester.pumpWidget(_buildList(allEntries: entries));
        await tester.pump();

        expect(find.text('February 2026'), findsOneWidget);
        expect(find.text('January 2026'), findsOneWidget);
      });
    });

    group('search', () {
      testWidgets('search icon is present', (tester) async {
        await tester.pumpWidget(_buildList());
        await tester.pump();

        expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      });

      testWidgets('tapping search icon shows search text field', (
        tester,
      ) async {
        await tester.pumpWidget(_buildList());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.search_rounded));
        await tester.pump();

        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('"No entries found." shown when search has no matches', (
        tester,
      ) async {
        final entries = [_entry(body: 'Something else')];
        await tester.pumpWidget(
          _buildList(
            allEntries: entries,
            filteredEntries: [],
            searchQuery: 'fatigue',
          ),
        );
        await tester.pump();

        expect(find.text('No entries found.'), findsOneWidget);
      });

      testWidgets('"Clear search" button shown when search yields no results', (
        tester,
      ) async {
        await tester.pumpWidget(
          _buildList(
            allEntries: [_entry()],
            filteredEntries: [],
            searchQuery: 'nomatch',
          ),
        );
        await tester.pump();

        expect(find.text('Clear search'), findsOneWidget);
      });

      testWidgets('close button appears when search is active', (tester) async {
        await tester.pumpWidget(_buildList());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.search_rounded));
        await tester.pump();

        expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      });

      testWidgets('tapping close restores normal AppBar', (tester) async {
        await tester.pumpWidget(_buildList());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.search_rounded));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pump();

        // Back to the normal title
        expect(find.text('Journal'), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
      });
    });
  });
}
