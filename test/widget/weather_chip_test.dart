import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/features/shared/widgets/weather_chip.dart';
import 'package:health_flare/models/weather_snapshot.dart';

final _snapshot = WeatherSnapshot(
  temperatureCelsius: 18.4,
  weatherCode: 2, // Mainly clear
  pressureHPa: 1012.6,
  humidityPercent: 62,
  windSpeedKmh: 14,
  capturedAt: DateTime(2026, 5, 4, 9, 30),
);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('WeatherSnapshot.detailString', () {
    test('rounds pressure to whole hPa and includes humidity', () {
      expect(_snapshot.detailString, 'Pressure 1013 hPa · Humidity 62%');
    });
  });

  group('WeatherChip', () {
    testWidgets('shows only conditions and temperature by default', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(WeatherChip(snapshot: _snapshot)));

      expect(find.text('Mainly clear, 18°C'), findsOneWidget);
      expect(find.textContaining('hPa'), findsNothing);
      expect(find.textContaining('Humidity'), findsNothing);
    });

    testWidgets('shows pressure and humidity when showDetails is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(WeatherChip(snapshot: _snapshot, showDetails: true)),
      );

      expect(find.text('Mainly clear, 18°C'), findsOneWidget);
      expect(find.text('Pressure 1013 hPa · Humidity 62%'), findsOneWidget);
    });

    testWidgets('renders nothing when snapshot is null', (tester) async {
      await tester.pumpWidget(
        _wrap(const WeatherChip(snapshot: null, showDetails: true)),
      );

      expect(find.byType(Text), findsNothing);
    });
  });
}
