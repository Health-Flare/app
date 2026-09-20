import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/shell/app_shell.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _placeholder(String label) => Scaffold(body: Center(child: Text(label)));

/// A minimal shell router mirroring the tab destinations wired into
/// [AppShell], so the NavigationBar can be exercised without booting the
/// full app router (which requires onboarding/profile providers).
Widget _buildShell() {
  final router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, _) => _placeholder('Dashboard screen'),
          ),
          GoRoute(
            path: AppRoutes.tracking,
            builder: (context, _) => _placeholder('Tracking screen'),
          ),
          GoRoute(
            path: AppRoutes.medications,
            builder: (context, _) => _placeholder('Medications screen'),
          ),
          GoRoute(
            path: AppRoutes.meals,
            builder: (context, _) => _placeholder('Meals screen'),
          ),
          GoRoute(
            path: AppRoutes.journal,
            builder: (context, _) => _placeholder('Journal screen'),
          ),
          GoRoute(
            path: AppRoutes.sleep,
            builder: (context, _) => _placeholder('Sleep screen'),
          ),
        ],
      ),
    ],
  );

  return MaterialApp.router(routerConfig: router);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AppShell navigation bar', () {
    testWidgets('shows a Sleep destination alongside the other tabs', (
      tester,
    ) async {
      await tester.pumpWidget(_buildShell());
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Sleep'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping Sleep navigates to the sleep screen', (tester) async {
      await tester.pumpWidget(_buildShell());
      await tester.pump();

      await tester.tap(find.text('Sleep'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sleep screen'), findsOneWidget);
    });

    testWidgets('Sleep destination is selected when on the sleep route', (
      tester,
    ) async {
      await tester.pumpWidget(_buildShell());
      await tester.pump();
      await tester.tap(find.text('Sleep'));
      await tester.pumpAndSettle();

      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 5);
    });

    // Regression: "Medications" is more than twice as long as its shortest
    // sibling label and, with all 6 destinations always labelled, was the
    // one most likely to wrap or misalign on narrow screens.
    testWidgets(
      'shows "Meds", not the longer "Medications", for the medications tab',
      (tester) async {
        await tester.pumpWidget(_buildShell());
        await tester.pump();

        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Meds'),
          ),
          findsOneWidget,
        );
        expect(find.text('Medications'), findsNothing);
      },
    );

    testWidgets('tapping Meds navigates to the medications screen', (
      tester,
    ) async {
      await tester.pumpWidget(_buildShell());
      await tester.pump();

      await tester.tap(find.text('Meds'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Medications screen'), findsOneWidget);
    });
  });
}
