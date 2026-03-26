import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/dashboard/dashboard_screen.dart';
import 'package:health_flare/models/flare.dart';
import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/sleep_entry.dart';

// ---------------------------------------------------------------------------
// Fake notifiers — avoid touching Isar in widget tests
// ---------------------------------------------------------------------------

class _FakeFirstLogPrompt extends FirstLogPromptNotifier {
  @override
  bool build() => false;

  @override
  Future<void> markShown() async {}

  @override
  void show() {}

  @override
  Future<void> dismiss() async {}
}

class _FakeFlareList extends FlareListNotifier {
  @override
  List<Flare> build() => [];
}

class _FakeWeatherOptIn extends WeatherOptInNotifier {
  @override
  bool build() => false;

  @override
  Future<void> dismiss({required bool enabled}) async {}
}

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => _sarahProfile.id;

  @override
  Future<void> setActive(int? id) async {}
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

final _sarahProfile = Profile(id: 1, name: 'Sarah');

JournalEntry _journalEntry({
  int id = 1,
  String body = 'Test body',
  String? title,
  DateTime? createdAt,
}) {
  final ts = createdAt ?? DateTime(2026, 3, 10, 10, 0);
  return JournalEntry(
    id: id,
    profileId: _sarahProfile.id,
    createdAt: ts,
    snapshots: [JournalSnapshot(body: body, title: title, savedAt: ts)],
  );
}

SleepEntry _sleepEntry({int id = 1, DateTime? bedtime, DateTime? wakeTime}) {
  final wake = wakeTime ?? DateTime(2026, 3, 15, 7, 30);
  final bed = bedtime ?? wake.subtract(const Duration(hours: 7, minutes: 30));
  return SleepEntry(
    id: id,
    profileId: _sarahProfile.id,
    bedtime: bed,
    wakeTime: wake,
    createdAt: wake,
  );
}

// ---------------------------------------------------------------------------
// Widget helpers
// ---------------------------------------------------------------------------

/// Wraps DashboardScreen in a plain MaterialApp (no GoRouter) — suitable for
/// content and sheet-presence tests where navigation is not exercised.
Widget _buildDashboard({
  List<JournalEntry> journalEntries = const [],
  List<SleepEntry> sleepEntries = const [],
}) {
  return ProviderScope(
    overrides: [
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      activeProfileDataProvider.overrideWith((ref) => _sarahProfile),
      activeProfileJournalProvider.overrideWith((ref) => journalEntries),
      activeSleepEntriesProvider.overrideWith((ref) => sleepEntries),
      firstLogPromptProvider.overrideWith(_FakeFirstLogPrompt.new),
      weatherOptInProvider.overrideWith(_FakeWeatherOptIn.new),
      flareListProvider.overrideWith(_FakeFlareList.new),
      activeFlareProvider.overrideWith((ref) => null),
    ],
    child: const MaterialApp(home: DashboardScreen()),
  );
}

/// Wraps DashboardScreen in a test GoRouter — used for navigation tests.
Widget _buildDashboardWithRouter({
  List<JournalEntry> journalEntries = const [],
  List<SleepEntry> sleepEntries = const [],
}) {
  final router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, _) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.journalNew,
        builder: (context, _) =>
            const Scaffold(body: Center(child: Text('Journal Composer'))),
      ),
      GoRoute(
        path: AppRoutes.sleepNew,
        builder: (context, _) =>
            const Scaffold(body: Center(child: Text('Sleep Entry'))),
      ),
      GoRoute(
        path: '/journal/:id',
        builder: (context, _) =>
            const Scaffold(body: Center(child: Text('Journal Detail'))),
      ),
      GoRoute(
        path: '/sleep/:id/edit',
        builder: (context, _) =>
            const Scaffold(body: Center(child: Text('Sleep Edit'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      activeProfileDataProvider.overrideWith((ref) => _sarahProfile),
      activeProfileJournalProvider.overrideWith((ref) => journalEntries),
      activeSleepEntriesProvider.overrideWith((ref) => sleepEntries),
      firstLogPromptProvider.overrideWith(_FakeFirstLogPrompt.new),
      weatherOptInProvider.overrideWith(_FakeWeatherOptIn.new),
      flareListProvider.overrideWith(_FakeFlareList.new),
      activeFlareProvider.overrideWith((ref) => null),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DashboardScreen', () {
    // ── Empty state ──────────────────────────────────────────────────────────

    group('empty state', () {
      testWidgets('shows encouraging message when nothing logged', (
        tester,
      ) async {
        await tester.pumpWidget(_buildDashboard());
        await tester.pump();

        expect(find.text('Nothing logged yet.'), findsOneWidget);
      });

      testWidgets('FAB is visible in the empty state', (tester) async {
        await tester.pumpWidget(_buildDashboard());
        await tester.pump();

        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    // ── Quick-entry sheet ────────────────────────────────────────────────────

    group('quick-entry sheet', () {
      testWidgets('tapping FAB shows sheet with Journal entry and Sleep', (
        tester,
      ) async {
        await tester.pumpWidget(_buildDashboard());
        await tester.pump();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump(); // trigger modal
        await tester.pump(const Duration(milliseconds: 300)); // animation

        expect(find.text('Journal entry'), findsOneWidget);
        expect(find.text('Sleep'), findsOneWidget);
      });

      testWidgets('tapping "Journal entry" navigates to journal composer', (
        tester,
      ) async {
        await tester.pumpWidget(_buildDashboardWithRouter());
        await tester.pump();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.text('Journal entry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Journal Composer'), findsOneWidget);
      });

      testWidgets('tapping "Sleep" navigates to sleep entry screen', (
        tester,
      ) async {
        await tester.pumpWidget(_buildDashboardWithRouter());
        await tester.pump();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.text('Sleep'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Sleep Entry'), findsOneWidget);
      });
    });

    // ── Activity feed — content ──────────────────────────────────────────────

    group('activity feed', () {
      testWidgets('journal entry body preview appears in feed', (tester) async {
        final entry = _journalEntry(body: 'Feeling better today');
        await tester.pumpWidget(_buildDashboard(journalEntries: [entry]));
        await tester.pump();

        expect(find.text('Feeling better today'), findsOneWidget);
      });

      testWidgets('journal entry title takes priority over body', (
        tester,
      ) async {
        final entry = _journalEntry(title: 'Week 3 notes', body: 'Rough week');
        await tester.pumpWidget(_buildDashboard(journalEntries: [entry]));
        await tester.pump();

        expect(find.text('Week 3 notes'), findsOneWidget);
        expect(find.text('Rough week'), findsNothing);
      });

      testWidgets('sleep entry duration appears in feed', (tester) async {
        final entry = _sleepEntry(
          wakeTime: DateTime(2026, 3, 15, 7, 30),
          bedtime: DateTime(2026, 3, 15, 0, 0),
        );
        await tester.pumpWidget(_buildDashboard(sleepEntries: [entry]));
        await tester.pump();

        expect(find.text('7h 30m'), findsOneWidget);
      });

      testWidgets('feed shows at most five items when six entries exist', (
        tester,
      ) async {
        // Entry 6 is newest (shown), Entry 1 is oldest (cut off after 5).
        final entries = List.generate(
          6,
          (i) => _journalEntry(
            id: i + 1,
            body: 'Entry ${i + 1}',
            createdAt: DateTime(2026, 3, i + 1, 10, 0),
          ),
        );
        await tester.pumpWidget(_buildDashboard(journalEntries: entries));
        await tester.pump();

        // Newest five are visible, oldest is not.
        expect(find.text('Entry 6'), findsOneWidget);
        expect(find.text('Entry 1'), findsNothing);
      });

      testWidgets('feed is in reverse chronological order', (tester) async {
        final journalEntry = _journalEntry(
          body: 'Old journal',
          createdAt: DateTime(2026, 3, 13, 10, 0), // 2 days ago
        );
        final sleepEntry = _sleepEntry(
          wakeTime: DateTime(2026, 3, 15, 7, 30), // today
          bedtime: DateTime(2026, 3, 15, 0, 0),
        );
        await tester.pumpWidget(
          _buildDashboard(
            journalEntries: [journalEntry],
            sleepEntries: [sleepEntry],
          ),
        );
        await tester.pump();

        final sleepDy = tester.getTopLeft(find.text('7h 30m')).dy;
        final journalDy = tester.getTopLeft(find.text('Old journal')).dy;
        expect(sleepDy, lessThan(journalDy));
      });
    });

    // ── Activity feed — navigation ───────────────────────────────────────────

    group('activity feed navigation', () {
      testWidgets('tapping journal item navigates to detail screen', (
        tester,
      ) async {
        final entry = _journalEntry(id: 42, body: 'Detail navigation test');
        await tester.pumpWidget(
          _buildDashboardWithRouter(journalEntries: [entry]),
        );
        await tester.pump();

        await tester.tap(find.text('Detail navigation test'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Journal Detail'), findsOneWidget);
      });

      testWidgets('tapping sleep item navigates to sleep edit screen', (
        tester,
      ) async {
        final entry = _sleepEntry(
          id: 7,
          wakeTime: DateTime(2026, 3, 15, 7, 30),
          bedtime: DateTime(2026, 3, 15, 0, 0),
        );
        await tester.pumpWidget(
          _buildDashboardWithRouter(sleepEntries: [entry]),
        );
        await tester.pump();

        await tester.tap(find.text('7h 30m'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Sleep Edit'), findsOneWidget);
      });
    });
  });
}
