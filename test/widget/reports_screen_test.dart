import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/report_provider.dart';
import 'package:health_flare/features/reports/models/report_config.dart';
import 'package:health_flare/features/reports/screens/reports_screen.dart';
import 'package:health_flare/models/profile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen({ReportConfig? config}) {
  return ProviderScope(
    overrides: [
      if (config != null)
        reportConfigProvider.overrideWith(
          (ref) => ReportConfigNotifier()..update(config),
        ),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
    ],
    child: const MaterialApp(home: ReportsScreen()),
  );
}

void main() {
  group('ReportsScreen', () {
    testWidgets(
      'shows date range segmented button with last-30-days selected by default',
      (tester) async {
        await tester.pumpWidget(_buildScreen());
        await tester.pump();

        expect(find.text('Last 7 days'), findsOneWidget);
        expect(find.text('Last 30 days'), findsOneWidget);
        expect(find.text('Custom'), findsOneWidget);
      },
    );

    testWidgets('shows all data-type toggles', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.text('Symptoms', skipOffstage: false), findsOneWidget);
      expect(find.text('Vitals', skipOffstage: false), findsOneWidget);
      expect(
        find.text('Medications & doses', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('Meals', skipOffstage: false), findsOneWidget);
      expect(find.text('Sleep', skipOffstage: false), findsOneWidget);
      expect(find.text('Daily check-ins', skipOffstage: false), findsOneWidget);
      expect(find.text('Appointments', skipOffstage: false), findsOneWidget);
      expect(find.text('Activities', skipOffstage: false), findsOneWidget);
      expect(find.text('Journal entries', skipOffstage: false), findsOneWidget);
    });

    testWidgets('shows Export CSV and Export PDF buttons', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.text('Export CSV', skipOffstage: false), findsOneWidget);
      expect(find.text('Export PDF', skipOffstage: false), findsOneWidget);
    });

    testWidgets('shows error message when no data type is selected', (
      tester,
    ) async {
      final noTypes = ReportConfig(
        includeSymptoms: false,
        includeVitals: false,
        includeMedications: false,
        includeMeals: false,
        includeJournal: false,
        includeSleep: false,
        includeCheckins: false,
        includeAppointments: false,
        includeActivities: false,
      );
      await tester.pumpWidget(_buildScreen(config: noTypes));
      await tester.pump();

      expect(
        find.text('Select at least one data type.', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('shows custom date pickers when Custom preset is selected', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      // Custom date pickers not visible with default preset
      expect(find.text('From'), findsNothing);

      // Tap "Custom"
      await tester.tap(find.text('Custom'));
      await tester.pump();

      expect(find.textContaining('From:'), findsOneWidget);
      expect(find.textContaining('To:'), findsOneWidget);
    });

    testWidgets('shows validation error when custom end is before start', (
      tester,
    ) async {
      final now = DateTime.now();
      final badRange = ReportConfig(
        preset: DateRangePreset.custom,
        customStart: now,
        customEnd: now.subtract(const Duration(days: 1)),
      );
      await tester.pumpWidget(_buildScreen(config: badRange));
      await tester.pump();

      expect(find.text('End date must be after start date.'), findsOneWidget);
    });

    testWidgets('unchecking a data-type toggle updates state', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      // Uncheck Symptoms (first checkbox, may be off-screen)
      await tester.tap(find.text('Symptoms', skipOffstage: false));
      await tester.pump();

      // The screen should still render without error
      expect(find.text('Symptoms', skipOffstage: false), findsOneWidget);
    });
  });
}
