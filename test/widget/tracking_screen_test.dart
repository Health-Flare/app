import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/tracking/screens/tracking_screen.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/user_condition.dart';

class _EmptyConditions extends UserConditionListNotifier {
  @override
  List<UserCondition> build() => const [];
}

Widget _buildTracking() {
  final router = GoRouter(
    initialLocation: AppRoutes.tracking,
    routes: [
      GoRoute(
        path: AppRoutes.tracking,
        builder: (_, _) => const TrackingScreen(),
      ),
      GoRoute(
        path: AppRoutes.symptomsNew,
        builder: (_, _) => const Scaffold(body: Text('Log symptom screen')),
      ),
      GoRoute(
        path: AppRoutes.vitalsNew,
        builder: (_, _) => const Scaffold(body: Text('Log vital screen')),
      ),
      GoRoute(
        path: AppRoutes.illness,
        builder: (_, _) => const Scaffold(body: Text('Add condition screen')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
      activeProfileSymptomEntriesProvider.overrideWith((ref) => const []),
      activeProfileVitalEntriesProvider.overrideWith((ref) => const []),
      userConditionListProvider.overrideWith(_EmptyConditions.new),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('Tracking symptoms add opens the symptom form', (tester) async {
    await tester.pumpWidget(_buildTracking());
    await tester.pump();

    expect(find.byTooltip('Log symptom'), findsOneWidget);
    expect(find.text('What would you like to log?'), findsNothing);

    await tester.tap(find.byTooltip('Log symptom'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Log symptom screen'), findsOneWidget);
    expect(find.text('What would you like to log?'), findsNothing);
  });

  testWidgets('Tracking vitals add opens the vital form', (tester) async {
    await tester.pumpWidget(_buildTracking());
    await tester.pump();

    await tester.tap(find.text('Vitals'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byTooltip('Log vital'), findsOneWidget);

    await tester.tap(find.byTooltip('Log vital'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Log vital screen'), findsOneWidget);
  });

  testWidgets('Tracking conditions add opens the condition screen', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTracking());
    await tester.pump();

    await tester.tap(find.text('Conditions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byTooltip('Add condition'), findsOneWidget);

    await tester.tap(find.byTooltip('Add condition'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Add condition screen'), findsOneWidget);
  });
}
