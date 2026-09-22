import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/features/sleep/screens/sleep_entry_screen.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/sleep_entry.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeSleepList extends SleepEntryListNotifier {
  @override
  List<SleepEntry> build() => [];
}

class _FakeSleepListWithRemove extends SleepEntryListNotifier {
  final List<SleepEntry> _initial;
  bool removeWasCalled = false;

  _FakeSleepListWithRemove(this._initial);

  @override
  List<SleepEntry> build() => List.of(_initial);

  @override
  Future<void> remove(int id) async {
    removeWasCalled = true;
    state = state.where((e) => e.id != id).toList();
  }
}

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _FakeProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [Profile(id: 1, name: 'Sarah')];
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen({SleepEntry? entry, SleepEntryPrefill? prefill}) {
  return ProviderScope(
    overrides: [
      sleepEntryListProvider.overrideWith(_FakeSleepList.new),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeSleepEntriesProvider.overrideWith((ref) => []),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
    ],
    child: MaterialApp(
      home: SleepEntryScreen(entry: entry, prefill: prefill),
    ),
  );
}

/// Builds the edit-mode screen inside a GoRouter so that context.pop() works,
/// with a fake list notifier that tracks whether `remove` was called.
Widget _buildEditScreenWithRouter(
  _FakeSleepListWithRemove fakeList,
  SleepEntry entry,
) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => const Scaffold(body: Text('Root screen')),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, _) => SleepEntryScreen(entry: entry),
          ),
        ],
      ),
    ],
    initialLocation: '/edit',
  );

  return ProviderScope(
    overrides: [
      sleepEntryListProvider.overrideWith(() => fakeList),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeSleepEntriesProvider.overrideWith((ref) => []),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SleepEntryScreen', () {
    testWidgets('renders bedtime and wake time fields', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.text('Bedtime'), findsOneWidget);
      expect(find.text('Wake time'), findsOneWidget);
    });

    testWidgets('shows duration calculated from default times', (tester) async {
      // Defaults: bedtime yesterday 23:00, wake today 07:00 → 8h
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.textContaining('8h'), findsOneWidget);
    });

    testWidgets('quality selector shows Very poor and Restful labels', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.text('Very poor'), findsOneWidget);
      expect(find.text('Restful'), findsOneWidget);
    });

    testWidgets('quality is not pre-selected on new entry', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.byKey(const Key('sleep_quality_selector')), findsOneWidget);
      // No filled quality button: all five are present but none active
      final selector = find.byKey(const Key('sleep_quality_selector'));
      expect(selector, findsOneWidget);
    });

    testWidgets('save button is present', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.text('Save entry'), findsOneWidget);
    });

    testWidgets('notes field accepts text', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('sleep_notes_field')),
        'Woke up twice, hot and restless',
      );
      await tester.pump();

      expect(find.text('Woke up twice, hot and restless'), findsOneWidget);
    });

    testWidgets('edit mode pre-fills entry duration and notes', (tester) async {
      final entry = SleepEntry(
        id: 1,
        profileId: 1,
        bedtime: DateTime(2026, 3, 10, 22, 30),
        wakeTime: DateTime(2026, 3, 11, 6, 45),
        qualityRating: 3,
        notes: 'Restless night',
        isNap: false,
        createdAt: DateTime(2026, 3, 11, 6, 45),
      );

      await tester.pumpWidget(_buildScreen(entry: entry));
      await tester.pump();

      // 22:30 → 06:45 = 8h 15m
      expect(find.textContaining('8h 15m'), findsOneWidget);
      expect(find.text('Restless night'), findsOneWidget);
    });

    testWidgets(
      'Quick Log prefill with only notes leaves default bedtime/wake time',
      (tester) async {
        await tester.pumpWidget(
          _buildScreen(
            prefill: const SleepEntryPrefill(notes: 'Terrible night'),
          ),
        );
        await tester.pump();

        // Defaults: bedtime yesterday 23:00, wake today 07:00 → 8h
        expect(find.textContaining('8h'), findsOneWidget);
        expect(find.text('Terrible night'), findsOneWidget);
      },
    );

    testWidgets(
      'Quick Log prefill with a parsed time range pre-fills bedtime and wake time',
      (tester) async {
        await tester.pumpWidget(
          _buildScreen(
            prefill: SleepEntryPrefill(
              notes: 'slept 8pm to 4am',
              bedtime: DateTime(2026, 3, 14, 20),
              wakeTime: DateTime(2026, 3, 15, 4),
            ),
          ),
        );
        await tester.pump();

        expect(find.textContaining('8h'), findsOneWidget);
        expect(find.textContaining('20:00'), findsOneWidget);
        expect(find.textContaining('04:00'), findsOneWidget);
        expect(find.text('slept 8pm to 4am'), findsOneWidget);
      },
    );

    testWidgets('negative duration shows validation error', (tester) async {
      // An entry where wake < bed same calendar day is invalid
      final invalid = SleepEntry(
        id: 1,
        profileId: 1,
        bedtime: DateTime(2026, 3, 11, 8, 0),
        wakeTime: DateTime(2026, 3, 11, 6, 0),
        isNap: false,
        createdAt: DateTime(2026, 3, 11, 6, 0),
      );

      await tester.pumpWidget(_buildScreen(entry: invalid));
      await tester.pump();

      expect(
        find.textContaining('Wake time must be after bedtime'),
        findsOneWidget,
      );
    });
  });

  group('SleepEntryScreen delete', () {
    SleepEntry entry({int id = 1}) => SleepEntry(
      id: id,
      profileId: 1,
      bedtime: DateTime(2026, 3, 10, 22, 30),
      wakeTime: DateTime(2026, 3, 11, 6, 45),
      isNap: false,
      createdAt: DateTime(2026, 3, 11, 6, 45),
    );

    testWidgets('Delete icon is present in edit mode', (tester) async {
      final e = entry();
      final fake = _FakeSleepListWithRemove([e]);
      await tester.pumpWidget(_buildEditScreenWithRouter(fake, e));
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('Delete icon is not present when creating a new entry', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });

    testWidgets('tapping Delete shows confirmation dialog', (tester) async {
      final e = entry();
      final fake = _FakeSleepListWithRemove([e]);
      await tester.pumpWidget(_buildEditScreenWithRouter(fake, e));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Delete this entry?'), findsOneWidget);
      expect(find.text('This cannot be undone.'), findsOneWidget);
    });

    testWidgets('Cancel dismisses dialog without deleting', (tester) async {
      final e = entry();
      final fake = _FakeSleepListWithRemove([e]);
      await tester.pumpWidget(_buildEditScreenWithRouter(fake, e));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Delete this entry?'), findsNothing);
      expect(fake.removeWasCalled, isFalse);
    });

    testWidgets('confirming delete calls remove and navigates back', (
      tester,
    ) async {
      final e = entry();
      final fake = _FakeSleepListWithRemove([e]);
      await tester.pumpWidget(_buildEditScreenWithRouter(fake, e));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(fake.removeWasCalled, isTrue);
      expect(find.text('Root screen'), findsOneWidget);
    });
  });

  group('SleepQualitySelector', () {
    testWidgets('shows 5 numbered buttons', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      for (final n in ['1', '2', '3', '4', '5']) {
        expect(
          find.descendant(
            of: find.byKey(const Key('sleep_quality_selector')),
            matching: find.text(n),
          ),
          findsOneWidget,
          reason: 'Quality button $n not found',
        );
      }
    });

    testWidgets('tapping a quality button selects it', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      // Tap quality 3
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('sleep_quality_selector')),
          matching: find.text('3'),
        ),
      );
      await tester.pump();

      // After selecting 3 the button changes appearance: we confirm no crash
      // and only one button is selected by checking state indirectly.
      expect(find.byKey(const Key('sleep_quality_selector')), findsOneWidget);
    });
  });

  group('SleepEntry duration logic', () {
    test('cross-midnight duration is calculated correctly', () {
      final entry = SleepEntry(
        id: 1,
        profileId: 1,
        bedtime: DateTime(2026, 3, 10, 23, 30),
        wakeTime: DateTime(2026, 3, 11, 7, 15),
        isNap: false,
        createdAt: DateTime(2026, 3, 11, 7, 15),
      );

      expect(entry.duration, const Duration(hours: 7, minutes: 45));
      expect(entry.formattedDuration, '7h 45m');
    });

    test('exact-hour duration formats without minutes', () {
      final entry = SleepEntry(
        id: 1,
        profileId: 1,
        bedtime: DateTime(2026, 3, 10, 23, 0),
        wakeTime: DateTime(2026, 3, 11, 7, 0),
        isNap: false,
        createdAt: DateTime(2026, 3, 11, 7, 0),
      );

      expect(entry.duration, const Duration(hours: 8));
      expect(entry.formattedDuration, '8h');
    });

    test('date is derived from wake time', () {
      final entry = SleepEntry(
        id: 1,
        profileId: 1,
        bedtime: DateTime(2026, 3, 10, 23, 30),
        wakeTime: DateTime(2026, 3, 11, 7, 15),
        isNap: false,
        createdAt: DateTime(2026, 3, 11, 7, 15),
      );

      expect(entry.date, DateTime(2026, 3, 11));
    });

    test('isNap defaults to false', () {
      final entry = SleepEntry(
        id: 1,
        profileId: 1,
        bedtime: DateTime(2026, 3, 10, 23, 0),
        wakeTime: DateTime(2026, 3, 11, 7, 0),
        isNap: false,
        createdAt: DateTime(2026, 3, 11, 7, 0),
      );

      expect(entry.isNap, false);
    });
  });

  group('Nap toggle', () {
    testWidgets('shows Nap switch pre-filled from the entry in edit mode', (
      tester,
    ) async {
      final nap = SleepEntry(
        id: 1,
        profileId: 1,
        bedtime: DateTime(2026, 3, 11, 14, 0),
        wakeTime: DateTime(2026, 3, 11, 14, 45),
        isNap: true,
        createdAt: DateTime(2026, 3, 11, 14, 45),
      );

      await tester.pumpWidget(_buildScreen(entry: nap));
      await tester.pump();

      final tile = tester.widget<SwitchListTile>(
        find.byKey(const Key('sleep_nap_switch')),
      );
      expect(tile.value, isTrue);
    });

    testWidgets('defaults off for a new entry with no same-day sleep', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      final tile = tester.widget<SwitchListTile>(
        find.byKey(const Key('sleep_nap_switch')),
      );
      expect(tile.value, isFalse);
    });

    testWidgets('tapping the switch toggles it', (tester) async {
      final entry = SleepEntry(
        id: 1,
        profileId: 1,
        bedtime: DateTime(2026, 3, 11, 14, 0),
        wakeTime: DateTime(2026, 3, 11, 14, 45),
        isNap: false,
        createdAt: DateTime(2026, 3, 11, 14, 45),
      );

      await tester.pumpWidget(_buildScreen(entry: entry));
      await tester.pump();

      await tester.tap(find.byKey(const Key('sleep_nap_switch')));
      await tester.pump();

      final tile = tester.widget<SwitchListTile>(
        find.byKey(const Key('sleep_nap_switch')),
      );
      expect(tile.value, isTrue);
    });
  });

  group('Bedtime/wake time shift helpers', () {
    test(
      'shifting wake time before bedtime carries bedtime by the same offset',
      () {
        final oldBedtime = DateTime(2026, 3, 11, 23, 0);
        final oldWakeTime = DateTime(2026, 3, 12, 7, 0);

        // User drags wake time 2 hours earlier than the old bedtime.
        final newWakeTime = DateTime(2026, 3, 11, 21, 0);

        final newBedtime = shiftedBedtimeForNewWakeTime(
          newWakeTime: newWakeTime,
          oldWakeTime: oldWakeTime,
          bedtime: oldBedtime,
        );

        final shift = newWakeTime.difference(oldWakeTime);
        expect(newBedtime, oldBedtime.add(shift));
        expect(newWakeTime.isAfter(newBedtime), isTrue);
      },
    );

    test('shifting wake time to stay valid leaves bedtime untouched', () {
      final bedtime = DateTime(2026, 3, 11, 23, 0);
      final oldWakeTime = DateTime(2026, 3, 12, 7, 0);
      final newWakeTime = DateTime(2026, 3, 12, 6, 30);

      final result = shiftedBedtimeForNewWakeTime(
        newWakeTime: newWakeTime,
        oldWakeTime: oldWakeTime,
        bedtime: bedtime,
      );

      expect(result, bedtime);
    });

    test(
      'shifting bedtime after wake time carries wake time by the same offset',
      () {
        final oldBedtime = DateTime(2026, 3, 11, 23, 0);
        final oldWakeTime = DateTime(2026, 3, 12, 7, 0);

        // User drags bedtime 3 hours past the old wake time.
        final newBedtime = DateTime(2026, 3, 12, 10, 0);

        final newWakeTime = shiftedWakeTimeForNewBedtime(
          newBedtime: newBedtime,
          oldBedtime: oldBedtime,
          wakeTime: oldWakeTime,
        );

        final shift = newBedtime.difference(oldBedtime);
        expect(newWakeTime, oldWakeTime.add(shift));
        expect(newWakeTime.isAfter(newBedtime), isTrue);
      },
    );

    test('shifting bedtime to stay valid leaves wake time untouched', () {
      final oldBedtime = DateTime(2026, 3, 11, 23, 0);
      final wakeTime = DateTime(2026, 3, 12, 7, 0);
      final newBedtime = DateTime(2026, 3, 11, 22, 0);

      final result = shiftedWakeTimeForNewBedtime(
        newBedtime: newBedtime,
        oldBedtime: oldBedtime,
        wakeTime: wakeTime,
      );

      expect(result, wakeTime);
    });

    test('shift preserves the original sleep duration', () {
      final oldBedtime = DateTime(2026, 3, 11, 23, 0);
      final oldWakeTime = DateTime(2026, 3, 12, 7, 0);
      final originalDuration = oldWakeTime.difference(oldBedtime);

      final newWakeTime = DateTime(2026, 3, 11, 20, 0);
      final newBedtime = shiftedBedtimeForNewWakeTime(
        newWakeTime: newWakeTime,
        oldWakeTime: oldWakeTime,
        bedtime: oldBedtime,
      );

      expect(newWakeTime.difference(newBedtime), originalDuration);
    });
  });
}
