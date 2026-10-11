// The real tab bodies (#141): each one with no data.
// Spec: navigation.feature, "Each log screen shows a helpful empty state
// when no data exists", "Appointments tab has an empty state",
// "Conditions tab is in Care".
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/activity_entry_provider.dart';
import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/clock_provider.dart';
import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/daily_checkin_provider.dart';
import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/medication_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/features/sections/tab_content.dart';
import 'package:health_flare/features/tracking/screens/tracking_screen.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/user_condition.dart';

class _NoConditions extends UserConditionListNotifier {
  @override
  List<UserCondition> build() => [];
}

Widget _body(String tabId) => ProviderScope(
  overrides: [
    activeProfileDataProvider.overrideWith(
      (ref) => Profile(id: 1, name: 'Sarah'),
    ),
    activeProfileSymptomEntriesProvider.overrideWith((ref) => []),
    activeProfileVitalEntriesProvider.overrideWith((ref) => []),
    userConditionListProvider.overrideWith(_NoConditions.new),
    activeProfileMealEntriesProvider.overrideWith((ref) => []),
    activeSleepEntriesProvider.overrideWith((ref) => []),
    activeProfileActivityEntriesProvider.overrideWith((ref) => []),
    activeProfileActiveMedicationsProvider.overrideWith((ref) => []),
    activeProfileDiscontinuedMedicationsProvider.overrideWith((ref) => []),
    activeProfileActiveSupplementsProvider.overrideWith((ref) => []),
    activeProfileDiscontinuedSupplementsProvider.overrideWith((ref) => []),
    activeProfileAppointmentsProvider.overrideWith((ref) => []),
    clockProvider.overrideWithValue(() => DateTime(2026, 10, 10, 12)),
    activeProfileFlaresProvider.overrideWith((ref) => []),
    activeProfileJournalProvider.overrideWith((ref) => []),
    filteredJournalProvider.overrideWith((ref) => []),
    activeProfileCheckinsProvider.overrideWith((ref) => []),
  ],
  child: Consumer(
    builder: (context, ref, _) {
      final content = ref.watch(tabContentProvider)[tabId]!;
      return MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, _) =>
                  Scaffold(body: Builder(builder: content.body)),
            ),
            GoRoute(
              path: '/appointments/new',
              builder: (_, _) => const Text('New appointment form'),
            ),
          ],
        ),
      );
    },
  ),
);

void main() {
  group('Each log screen shows a helpful empty state when no data exists', () {
    const expected = {
      'track.symptoms': ('No symptoms logged yet', 'Tap + to log a symptom'),
      'track.vitals': ('No vitals logged yet', 'Tap + to log a vital'),
      'track.meals': ('No meals logged yet', 'Tap + to log your first meal'),
      'track.sleep': ('No sleep logged yet', 'Tap + to log'),
      'track.activity': ('No activities logged yet', 'Tap + to log'),
      'care.medications': ('No medications yet', 'Tap + to add a medication'),
      'care.appointments': ('No appointments recorded yet', 'Add appointment'),
      'care.conditions': (
        'No conditions added yet',
        'Tap + to add a condition',
      ),
      'care.flares': ('No flares recorded', 'Tap + to record a flare'),
      'journal.entries': ('Nothing written yet.', 'Write whatever helps'),
      'journal.checkins': (
        'No check-ins recorded yet',
        "Tap + to add today's check-in",
      ),
    };

    for (final MapEntry(key: tab, value: (title, hint)) in expected.entries) {
      testWidgets(tab, (tester) async {
        await tester.pumpWidget(_body(tab));
        await tester.pumpAndSettle();
        expect(find.textContaining(title), findsOneWidget, reason: title);
        expect(find.textContaining(hint), findsOneWidget, reason: hint);
      });
    }
  });

  testWidgets('Appointments tab has an empty state with a button to add one', (
    tester,
  ) async {
    await tester.pumpWidget(_body('care.appointments'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add appointment'));
    await tester.pumpAndSettle();
    expect(find.text('New appointment form'), findsOneWidget);
  });

  testWidgets('Conditions tab is in Care: the same list as Tracking > '
      'Conditions', (tester) async {
    await tester.pumpWidget(_body('care.conditions'));
    await tester.pumpAndSettle();
    expect(find.byType(ConditionListBody), findsOneWidget);
  });
}
