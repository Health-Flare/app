import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/sleep/screens/sleep_list_screen.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/sleep_entry.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _sarahProfile = Profile(id: 1, name: 'Sarah');

SleepEntry _entry({int id = 1, DateTime? bedtime, DateTime? wakeTime}) {
  final wake = wakeTime ?? DateTime(2026, 3, 15, 7, 30);
  final bed = bedtime ?? wake.subtract(const Duration(hours: 8));
  return SleepEntry(
    id: id,
    profileId: 1,
    bedtime: bed,
    wakeTime: wake,
    isNap: false,
    createdAt: wake,
  );
}

/// Wraps SleepListScreen in a test GoRouter so navigation to the "new sleep
/// entry" route can be asserted.
Widget _buildScreen({List<SleepEntry> entries = const []}) {
  final router = GoRouter(
    initialLocation: AppRoutes.sleep,
    routes: [
      GoRoute(
        path: AppRoutes.sleep,
        builder: (context, _) => const SleepListScreen(),
      ),
      GoRoute(
        path: AppRoutes.sleepNew,
        builder: (context, _) =>
            const Scaffold(body: Center(child: Text('Log sleep screen'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      activeSleepEntriesProvider.overrideWith((ref) => entries),
      activeProfileDataProvider.overrideWith((ref) => _sarahProfile),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SleepListScreen', () {
    testWidgets('shows empty state when no entries exist', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.text('No sleep logged yet'), findsOneWidget);
    });

    testWidgets('lists entries when present', (tester) async {
      final entries = [
        _entry(id: 1, wakeTime: DateTime(2026, 3, 15, 7, 30)),
        _entry(id: 2, wakeTime: DateTime(2026, 3, 14, 6, 45)),
      ];
      await tester.pumpWidget(_buildScreen(entries: entries));
      await tester.pump();

      expect(find.text('No sleep logged yet'), findsNothing);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('floating action button is present', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('tapping the FAB opens Quick Log', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('What would you like to log?'), findsOneWidget);
      expect(find.text('Add to Journal'), findsOneWidget);
    });

    testWidgets('tapping an entry navigates to edit with the entry passed', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: AppRoutes.sleep,
        routes: [
          GoRoute(
            path: AppRoutes.sleep,
            builder: (context, _) => const SleepListScreen(),
          ),
          GoRoute(
            path: '/sleep/:id/edit',
            builder: (context, state) {
              final entry = state.extra as SleepEntry?;
              return Scaffold(
                body: Center(child: Text('Edit sleep entry ${entry?.id}')),
              );
            },
          ),
        ],
      );
      final entry = _entry(id: 9);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeSleepEntriesProvider.overrideWith((ref) => [entry]),
            activeProfileDataProvider.overrideWith((ref) => _sarahProfile),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(ListTile));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Edit sleep entry 9'), findsOneWidget);
    });
  });
}
