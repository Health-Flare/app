// Issue #83: vitals (e.g. temperature) never appeared on the insights screen.
// Specs: docs/features/reports.feature, "Vital trends" scenarios.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/features/reports/models/insight_data.dart';
import 'package:health_flare/features/reports/widgets/trend_chart.dart';
import 'package:health_flare/features/reports/widgets/vital_trends_card.dart';
import 'package:health_flare/models/vital_type.dart';

final _start = DateTime(2026, 9, 1);
final _end = DateTime(2026, 9, 30, 23, 59, 59);

InsightData _data({
  List<VitalTrend> vitals = const [],
  List<InsightFlarePeriod> flares = const [],
}) => InsightData(
  start: _start,
  end: _end,
  symptomTrends: const [],
  wellbeingTrend: const [],
  flarePeriods: flares,
  foodTriggers: const [],
  sleepCorrelation: const SleepCorrelation(),
  weatherImpact: const [],
  vitalTrends: vitals,
);

final _temperature = VitalTrend(
  type: VitalType.temperature,
  unit: '°C',
  points: [
    TrendPoint(date: DateTime(2026, 9, 10, 8), value: 36.8),
    TrendPoint(date: DateTime(2026, 9, 11, 8), value: 38.9),
    TrendPoint(date: DateTime(2026, 9, 12, 20), value: 37.6),
  ],
);

final _weight = VitalTrend(
  type: VitalType.weight,
  unit: 'kg',
  points: [TrendPoint(date: DateTime(2026, 9, 10), value: 70)],
);

final _bloodPressure = VitalTrend(
  type: VitalType.bloodPressure,
  unit: 'mmHg',
  points: [
    TrendPoint(date: DateTime(2026, 9, 10), value: 120),
    TrendPoint(date: DateTime(2026, 9, 12), value: 135),
  ],
  secondaryPoints: [
    TrendPoint(date: DateTime(2026, 9, 10), value: 80),
    TrendPoint(date: DateTime(2026, 9, 12), value: 88),
  ],
);

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

LineChartData _chartData(WidgetTester tester) =>
    tester.widget<LineChart>(find.byType(LineChart)).data;

void main() {
  group('VitalTrendsCard', () {
    testWidgets('shows the temperature chart with its unit', (tester) async {
      await tester.pumpWidget(
        _host(VitalTrendsCard(data: _data(vitals: [_temperature]))),
      );

      expect(find.text('Temperature'), findsWidgets);
      expect(find.textContaining('°C'), findsWidgets);
      expect(find.byType(TrendChart), findsOneWidget);
      expect(_chartData(tester).lineBarsData.single.spots, hasLength(3));
    });

    testWidgets('offers only vital types that have readings', (tester) async {
      await tester.pumpWidget(
        _host(VitalTrendsCard(data: _data(vitals: [_temperature, _weight]))),
      );

      await tester.tap(find.byType(DropdownButton<VitalType>));
      await tester.pumpAndSettle();

      expect(find.text('Temperature'), findsWidgets);
      expect(find.text('Weight'), findsWidgets);
      expect(find.text('Heart Rate'), findsNothing);
    });

    testWidgets('switching the picker charts the chosen vital', (tester) async {
      await tester.pumpWidget(
        _host(VitalTrendsCard(data: _data(vitals: [_temperature, _weight]))),
      );

      await tester.tap(find.byType(DropdownButton<VitalType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weight').last);
      await tester.pumpAndSettle();

      final spots = _chartData(tester).lineBarsData.single.spots;
      expect(spots.map((s) => s.y), [70]);
      expect(find.textContaining('kg'), findsWidgets);
    });

    testWidgets('blood pressure draws systolic and diastolic lines', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(VitalTrendsCard(data: _data(vitals: [_bloodPressure]))),
      );

      final bars = _chartData(tester).lineBarsData;
      expect(bars, hasLength(2));
      expect(bars[0].spots.map((s) => s.y), [120, 135]);
      expect(bars[1].spots.map((s) => s.y), [80, 88]);
      expect(find.textContaining('Systolic'), findsOneWidget);
      expect(find.textContaining('Diastolic'), findsOneWidget);
    });

    testWidgets('flare periods are shaded behind vital charts', (tester) async {
      await tester.pumpWidget(
        _host(
          VitalTrendsCard(
            data: _data(
              vitals: [_temperature],
              flares: [
                InsightFlarePeriod(
                  start: DateTime(2026, 9, 11),
                  end: DateTime(2026, 9, 13),
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        _chartData(tester).rangeAnnotations.verticalRangeAnnotations,
        hasLength(1),
      );
      expect(find.byType(FlareLegendChip), findsOneWidget);
    });

    testWidgets('renders nothing when there are no vitals', (tester) async {
      await tester.pumpWidget(_host(VitalTrendsCard(data: _data())));

      expect(find.byType(TrendChart), findsNothing);
    });
  });

  group('TrendChart fitToData', () {
    Widget chart(List<TrendPoint> points, {bool fit = true}) => MaterialApp(
      home: SizedBox(
        width: 300,
        height: 180,
        child: TrendChart(
          points: points,
          windowStart: _start,
          windowEnd: _end,
          fitToData: fit,
        ),
      ),
    );

    testWidgets('y-axis contains every reading', (tester) async {
      await tester.pumpWidget(chart(_temperature.points));

      final d = _chartData(tester);
      expect(d.minY, lessThanOrEqualTo(36.8));
      expect(d.maxY, greaterThanOrEqualTo(38.9));
    });

    testWidgets('y-axis is not the 0–10 severity scale', (tester) async {
      await tester.pumpWidget(chart(_temperature.points));

      final d = _chartData(tester);
      expect(d.minY, greaterThan(10));
    });

    testWidgets('a single reading still gets a non-zero range', (tester) async {
      await tester.pumpWidget(
        chart([TrendPoint(date: DateTime(2026, 9, 10), value: 37.0)]),
      );

      final d = _chartData(tester);
      expect(d.maxY, greaterThan(d.minY));
      expect(d.minY, lessThanOrEqualTo(37.0));
      expect(d.maxY, greaterThanOrEqualTo(37.0));
    });

    testWidgets('readings keep their time of day on the x-axis', (
      tester,
    ) async {
      await tester.pumpWidget(
        chart([
          TrendPoint(date: DateTime(2026, 9, 15, 8), value: 37.2),
          TrendPoint(date: DateTime(2026, 9, 15, 20), value: 38.6),
        ]),
      );

      final xs = _chartData(tester).lineBarsData.single.spots.map((s) => s.x);
      expect(xs.first, isNot(xs.last));
    });

    testWidgets('severity charts are unchanged (0–10)', (tester) async {
      await tester.pumpWidget(
        chart([TrendPoint(date: DateTime(2026, 9, 10), value: 6)], fit: false),
      );

      final d = _chartData(tester);
      expect(d.minY, 0);
      expect(d.maxY, 10);
    });
  });
}
