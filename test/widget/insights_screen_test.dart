import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/reports/models/insight_data.dart';
import 'package:health_flare/features/reports/screens/insights_screen.dart';
import 'package:health_flare/models/profile.dart';

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _FakeProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [Profile(id: 1, name: 'Ethan')];
}

// ---------------------------------------------------------------------------
// Unit tests — InsightData model helpers
// ---------------------------------------------------------------------------

void main() {
  group('InsightData', () {
    test('isEmpty returns true when no data', () {
      final data = InsightData(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
        symptomTrends: const [],
        wellbeingTrend: const [],
        flarePeriods: const [],
        foodTriggers: const [],
        sleepCorrelation: const SleepCorrelation(),
      );
      expect(data.isEmpty, isTrue);
    });

    test('isEmpty returns false when symptom trends exist', () {
      final data = InsightData(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
        symptomTrends: [
          SymptomTrend(
            name: 'Headache',
            points: [TrendPoint(date: DateTime(2026, 1, 5), value: 6)],
          ),
        ],
        wellbeingTrend: const [],
        flarePeriods: const [],
        foodTriggers: const [],
        sleepCorrelation: const SleepCorrelation(),
      );
      expect(data.isEmpty, isFalse);
    });

    test('isEmpty returns false when sleep correlation has data', () {
      final data = InsightData(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
        symptomTrends: const [],
        wellbeingTrend: const [],
        flarePeriods: const [],
        foodTriggers: const [],
        sleepCorrelation: const SleepCorrelation(
          poorSleepAvg: 7.0,
          poorSleepDays: 3,
        ),
      );
      expect(data.isEmpty, isFalse);
    });
  });

  group('SleepCorrelation', () {
    test('hasData is false when both averages are null', () {
      const c = SleepCorrelation();
      expect(c.hasData, isFalse);
    });

    test('hasData is true when poorSleepAvg is present', () {
      const c = SleepCorrelation(poorSleepAvg: 6.5, poorSleepDays: 4);
      expect(c.hasData, isTrue);
    });

    test('hasData is true when goodSleepAvg is present', () {
      const c = SleepCorrelation(goodSleepAvg: 3.2, goodSleepDays: 7);
      expect(c.hasData, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Widget tests — InsightsScreen
  // ---------------------------------------------------------------------------

  group('InsightsScreen', () {
    Widget buildScreen() {
      return ProviderScope(
        overrides: [
          activeProfileProvider.overrideWith(_FakeActiveProfile.new),
          profileListProvider.overrideWith(_FakeProfileList.new),
          isarProvider.overrideWith((ref) => throw UnimplementedError()),
        ],
        child: const MaterialApp(home: InsightsScreen()),
      );
    }

    testWidgets('shows profile name in app bar', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Ethan'), findsWidgets);
    });

    testWidgets('shows date window segmented button', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('7 days'), findsOneWidget);
      expect(find.text('30 days'), findsOneWidget);
      expect(find.text('90 days'), findsOneWidget);
    });

    testWidgets('shows error message when Isar throws', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Failed to load insights'), findsWidgets);
    });
  });
}
