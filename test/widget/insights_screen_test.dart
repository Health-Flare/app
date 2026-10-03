import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/reports/models/insight_data.dart';
import 'package:health_flare/features/reports/screens/insights_screen.dart';
import 'package:health_flare/features/reports/services/insights_query_service.dart';
import 'package:health_flare/features/reports/widgets/vital_trends_card.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/vital_type.dart';

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _FakeProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [Profile(id: 1, name: 'Ethan')];
}

// ---------------------------------------------------------------------------
// Unit tests: InsightData model helpers
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
        weatherImpact: const [],
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
        weatherImpact: const [],
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
        weatherImpact: const [],
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
  // Widget tests: InsightsScreen
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

  // ---------------------------------------------------------------------------
  // Issue #83: vitals on the insights screen. The query itself is covered
  // against real Isar in test/unit/insights_vitals_test.dart; real Isar in a
  // widget test hangs here (see settings_backup_encryption_test.dart), so
  // this checks the screen's wiring through [insightsQueryProvider].
  // ---------------------------------------------------------------------------

  group('InsightsScreen vitals', () {
    InsightData vitalsOnly(String unit) => InsightData(
      start: DateTime(2026, 9, 1),
      end: DateTime(2026, 9, 30),
      symptomTrends: const [],
      wellbeingTrend: const [],
      flarePeriods: const [],
      foodTriggers: const [],
      sleepCorrelation: const SleepCorrelation(),
      weatherImpact: const [],
      vitalTrends: [
        VitalTrend(
          type: VitalType.temperature,
          unit: unit,
          points: [TrendPoint(date: DateTime(2026, 9, 20, 8), value: 38.4)],
        ),
      ],
    );

    Widget build(Profile profile, List<String?> unitsAsked) => ProviderScope(
      overrides: [
        activeProfileProvider.overrideWith(_FakeActiveProfile.new),
        profileListProvider.overrideWith(_FakeProfileList.new),
        activeProfileDataProvider.overrideWith((ref) => profile),
        isarProvider.overrideWith((ref) => throw UnimplementedError()),
        insightsQueryProvider.overrideWithValue(({
          required profileId,
          required start,
          required end,
          temperatureUnit,
        }) async {
          unitsAsked.add(temperatureUnit);
          return vitalsOnly(temperatureUnit ?? '°C');
        }),
      ],
      child: const MaterialApp(home: InsightsScreen()),
    );

    testWidgets('vitals alone show a Vitals section, not the empty state', (
      tester,
    ) async {
      await tester.pumpWidget(build(Profile(id: 1, name: 'Ethan'), []));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Vitals'), findsOneWidget);
      expect(find.byType(VitalTrendsCard), findsOneWidget);
      expect(find.text('Not enough data yet'), findsNothing);
    });

    testWidgets('passes the profile temperature unit to the query', (
      tester,
    ) async {
      final asked = <String?>[];
      await tester.pumpWidget(
        build(Profile(id: 1, name: 'Ethan', temperatureUnit: '°F'), asked),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(asked, ['°F']);
      expect(find.textContaining('Temperature in °F'), findsOneWidget);
    });

    testWidgets('"As logged" passes no unit', (tester) async {
      final asked = <String?>[];
      await tester.pumpWidget(build(Profile(id: 1, name: 'Ethan'), asked));
      await tester.pump(const Duration(milliseconds: 100));

      expect(asked, [null]);
    });
  });
}
