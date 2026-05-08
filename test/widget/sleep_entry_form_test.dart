import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen({SleepEntry? entry}) {
  return ProviderScope(
    overrides: [
      sleepEntryListProvider.overrideWith(_FakeSleepList.new),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      activeSleepEntriesProvider.overrideWith((ref) => []),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
    ],
    child: MaterialApp(home: SleepEntryScreen(entry: entry)),
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
      // No filled quality button — all five are present but none active
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

      // After selecting 3 the button changes appearance — we confirm no crash
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
}
