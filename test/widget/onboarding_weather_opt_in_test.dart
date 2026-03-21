import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/features/onboarding/widgets/weather_opt_in_sheet.dart';

Widget _buildSheet({required void Function(bool) onResult}) {
  return MaterialApp(
    home: Scaffold(body: WeatherTrackingOptInSheet(onResult: onResult)),
  );
}

void main() {
  group('WeatherTrackingOptInSheet', () {
    testWidgets('shows a descriptive title', (tester) async {
      await tester.pumpWidget(_buildSheet(onResult: (_) {}));
      expect(find.text('Track weather with every log'), findsOneWidget);
    });

    testWidgets('shows an explanation mentioning barometric pressure', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSheet(onResult: (_) {}));
      expect(
        find.textContaining('barometric pressure', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('shows both action buttons', (tester) async {
      await tester.pumpWidget(_buildSheet(onResult: (_) {}));
      expect(find.text('Enable weather tracking'), findsOneWidget);
      expect(find.text('No thanks'), findsOneWidget);
    });

    testWidgets('"No thanks" calls onResult(false)', (tester) async {
      bool? result;
      await tester.pumpWidget(_buildSheet(onResult: (v) => result = v));

      await tester.tap(find.text('No thanks'));
      await tester.pump();

      expect(result, false);
    });

    testWidgets('"Enable weather tracking" calls onResult(true)', (
      tester,
    ) async {
      bool? result;
      await tester.pumpWidget(_buildSheet(onResult: (v) => result = v));

      await tester.tap(find.text('Enable weather tracking'));
      await tester.pump();

      expect(result, true);
    });
  });
}
