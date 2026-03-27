import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/daily_checkin_provider.dart';
import 'package:health_flare/core/providers/dashboard_provider.dart';
import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/dashboard/dashboard_screen.dart';
import 'package:health_flare/models/activity_item.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/daily_checkin.dart';
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

class _FakeCheckinList extends DailyCheckinListNotifier {
  @override
  List<DailyCheckin> build() => [];
}

class _FakeAppointmentList extends AppointmentListNotifier {
  @override
  List<Appointment> build() => [];
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

/// Builds the feed items list from journal + sleep entries for legacy tests.
List<ActivityItem> _feedItems({
  List<JournalEntry> journalEntries = const [],
  List<SleepEntry> sleepEntries = const [],
}) {
  final items = <ActivityItem>[
    ...journalEntries.map(
      (e) => JournalActivityItem(timestamp: e.createdAt, entry: e),
    ),
    ...sleepEntries.map(
      (e) => SleepActivityItem(timestamp: e.wakeTime, entry: e),
    ),
  ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items.take(10).toList();
}

/// Wraps DashboardScreen in a plain MaterialApp (no GoRouter) — suitable for
/// content and sheet-presence tests where navigation is not exercised.
Widget _buildDashboard({
  List<JournalEntry> journalEntries = const [],
  List<SleepEntry> sleepEntries = const [],
}) {
  final feedItems = _feedItems(
    journalEntries: journalEntries,
    sleepEntries: sleepEntries,
  );
  return ProviderScope(
    overrides: [
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      activeProfileDataProvider.overrideWith((ref) => _sarahProfile),
      activeProfileJournalProvider.overrideWith((ref) => journalEntries),
      activeSleepEntriesProvider.overrideWith((ref) => sleepEntries),
      dashboardActivityProvider.overrideWith((ref) => feedItems),
      dashboardHasActivityProvider.overrideWith((ref) => feedItems.isNotEmpty),
      firstLogPromptProvider.overrideWith(_FakeFirstLogPrompt.new),
      weatherOptInProvider.overrideWith(_FakeWeatherOptIn.new),
      flareListProvider.overrideWith(_FakeFlareList.new),
      activeFlareProvider.overrideWith((ref) => null),
      dailyCheckinListProvider.overrideWith(_FakeCheckinList.new),
      todayCheckinProvider.overrideWith((ref) => null),
      appointmentListProvider.overrideWith(_FakeAppointmentList.new),
      activeProfileAppointmentsProvider.overrideWith((ref) => []),
      upcomingAppointmentsProvider.overrideWith((ref) => []),
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

  final feedItems = _feedItems(
    journalEntries: journalEntries,
    sleepEntries: sleepEntries,
  );
  return ProviderScope(
    overrides: [
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      activeProfileDataProvider.overrideWith((ref) => _sarahProfile),
      activeProfileJournalProvider.overrideWith((ref) => journalEntries),
      activeSleepEntriesProvider.overrideWith((ref) => sleepEntries),
      dashboardActivityProvider.overrideWith((ref) => feedItems),
      dashboardHasActivityProvider.overrideWith((ref) => feedItems.isNotEmpty),
      firstLogPromptProvider.overrideWith(_FakeFirstLogPrompt.new),
      weatherOptInProvider.overrideWith(_FakeWeatherOptIn.new),
      flareListProvider.overrideWith(_FakeFlareList.new),
      activeFlareProvider.overrideWith((ref) => null),
      dailyCheckinListProvider.overrideWith(_FakeCheckinList.new),
      todayCheckinProvider.overrideWith((ref) => null),
      appointmentListProvider.overrideWith(_FakeAppointmentList.new),
      activeProfileAppointmentsProvider.overrideWith((ref) => []),
      upcomingAppointmentsProvider.overrideWith((ref) => []),
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
      testWidgets('tapping FAB opens quick log sheet', (tester) async {
        await tester.pumpWidget(_buildDashboard());
        await tester.pump();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Logging for Sarah'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
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

      testWidgets('feed shows at most ten items when eleven entries exist', (
        tester,
      ) async {
        // Entry 11 is newest (shown), Entry 1 is oldest (cut off after 10).
        final entries = List.generate(
          11,
          (i) => _journalEntry(
            id: i + 1,
            body: 'Entry ${i + 1}',
            createdAt: DateTime(2026, 3, i + 1, 10, 0),
          ),
        );
        await tester.pumpWidget(_buildDashboard(journalEntries: entries));
        await tester.pump();

        // Newest ten are visible, oldest is not.
        expect(find.text('Entry 11', skipOffstage: false), findsOneWidget);
        expect(find.text('Entry 1', skipOffstage: false), findsNothing);
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
