import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/features/journal/screens/journal_detail_screen.dart';
import 'package:health_flare/models/journal_entry.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeJournalList extends JournalEntryListNotifier {
  final List<JournalEntry> _initial;
  bool removeWasCalled = false;

  _FakeJournalList(this._initial);

  @override
  List<JournalEntry> build() => List.of(_initial);

  @override
  Future<void> remove(int id) async {
    removeWasCalled = true;
    state = state.where((e) => e.id != id).toList();
  }

  @override
  Future<void> update(JournalEntry updated) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

JournalEntry _entry({
  int id = 1,
  String body = 'Joint pain all day',
  String? title,
  JournalMood? mood,
  int? energyLevel,
  bool edited = false,
}) {
  final created = DateTime(2026, 2, 14, 10, 0);
  final saved = edited ? DateTime(2026, 2, 14, 12, 0) : created;
  return JournalEntry(
    id: id,
    profileId: 1,
    createdAt: created,
    snapshots: [JournalSnapshot(body: body, title: title, savedAt: saved)],
    mood: mood?.index,
    energyLevel: energyLevel,
  );
}

/// Builds the detail screen inside a GoRouter so that context.pop() works.
Widget _buildDetail(_FakeJournalList fakeList, JournalEntry entry) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => const Scaffold(body: Text('Root screen')),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (context, _) => JournalDetailScreen(entryId: entry.id),
          ),
        ],
      ),
    ],
    initialLocation: '/detail',
  );

  return ProviderScope(
    overrides: [journalEntryListProvider.overrideWith(() => fakeList)],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('JournalDetailScreen', () {
    group('content display', () {
      testWidgets('shows full body text', (tester) async {
        final entry = _entry(body: 'Joint pain all day');
        final fake = _FakeJournalList([entry]);
        await tester.pumpWidget(_buildDetail(fake, entry));
        await tester.pump();

        expect(find.text('Joint pain all day'), findsOneWidget);
      });

      testWidgets('shows title when set', (tester) async {
        final entry = _entry(title: 'Week 3 notes', body: 'Some text');
        final fake = _FakeJournalList([entry]);
        await tester.pumpWidget(_buildDetail(fake, entry));
        await tester.pump();

        expect(find.text('Week 3 notes'), findsOneWidget);
      });

      testWidgets('shows creation date', (tester) async {
        final entry = _entry();
        final fake = _FakeJournalList([entry]);
        await tester.pumpWidget(_buildDetail(fake, entry));
        await tester.pump();

        // Date format: "Saturday 14 February 2026 at 10:00 AM"
        expect(find.textContaining('February 2026'), findsOneWidget);
      });

      testWidgets('body text is selectable', (tester) async {
        final entry = _entry(body: 'Some selectable body text');
        final fake = _FakeJournalList([entry]);
        await tester.pumpWidget(_buildDetail(fake, entry));
        await tester.pump();

        expect(find.byType(SelectableText), findsOneWidget);
      });

      testWidgets('shows mood chip when mood is set', (tester) async {
        final entry = _entry(mood: JournalMood.great);
        final fake = _FakeJournalList([entry]);
        await tester.pumpWidget(_buildDetail(fake, entry));
        await tester.pump();

        expect(find.text('😊  Great'), findsOneWidget);
      });

      testWidgets('shows energy chip when energy is set', (tester) async {
        final entry = _entry(energyLevel: 5);
        final fake = _FakeJournalList([entry]);
        await tester.pumpWidget(_buildDetail(fake, entry));
        await tester.pump();

        expect(find.text('Energy 5/5'), findsOneWidget);
      });

      testWidgets('does not show mood chip when mood is not set', (
        tester,
      ) async {
        final entry = _entry();
        final fake = _FakeJournalList([entry]);
        await tester.pumpWidget(_buildDetail(fake, entry));
        await tester.pump();

        // Mood emoji should not appear
        expect(find.text('😊  Great'), findsNothing);
        expect(find.text('🙂  Okay'), findsNothing);
      });

      testWidgets('shows "Last saved" note when entry was edited', (
        tester,
      ) async {
        final entry = _entry(edited: true);
        final fake = _FakeJournalList([entry]);
        await tester.pumpWidget(_buildDetail(fake, entry));
        await tester.pump();

        expect(find.textContaining('Last saved'), findsOneWidget);
      });

      testWidgets('does not show "Last saved" when entry was not edited', (
        tester,
      ) async {
        final entry = _entry(edited: false);
        final fake = _FakeJournalList([entry]);
        await tester.pumpWidget(_buildDetail(fake, entry));
        await tester.pump();

        expect(find.textContaining('Last saved'), findsNothing);
      });
    });

    group('actions', () {
      testWidgets('Edit icon is present', (tester) async {
        final entry = _entry();
        final fake = _FakeJournalList([entry]);
        await tester.pumpWidget(_buildDetail(fake, entry));
        await tester.pump();

        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      });

      testWidgets('Delete icon is present', (tester) async {
        final entry = _entry();
        final fake = _FakeJournalList([entry]);
        await tester.pumpWidget(_buildDetail(fake, entry));
        await tester.pump();

        expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      });

      testWidgets('tapping Delete shows confirmation dialog', (tester) async {
        final entry = _entry();
        final fake = _FakeJournalList([entry]);
        await tester.pumpWidget(_buildDetail(fake, entry));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.delete_outline_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Delete this entry?'), findsOneWidget);
        expect(find.text('This cannot be undone.'), findsOneWidget);
      });

      testWidgets('Cancel button dismisses dialog without deleting', (
        tester,
      ) async {
        final entry = _entry();
        final fake = _FakeJournalList([entry]);
        await tester.pumpWidget(_buildDetail(fake, entry));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.delete_outline_rounded));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Dialog dismissed
        expect(find.text('Delete this entry?'), findsNothing);
        // Remove not called
        expect(fake.removeWasCalled, isFalse);
        // Body text still showing
        expect(find.text(entry.body), findsOneWidget);
      });

      testWidgets('confirming delete calls remove and navigates back', (
        tester,
      ) async {
        final entry = _entry();
        final fake = _FakeJournalList([entry]);
        await tester.pumpWidget(_buildDetail(fake, entry));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.delete_outline_rounded));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(fake.removeWasCalled, isTrue);
        // Navigated back to root screen
        expect(find.text('Root screen'), findsOneWidget);
      });
    });
  });
}
