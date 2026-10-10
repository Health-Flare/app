import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/security/device_auth.dart';
import 'package:health_flare/features/onboarding/widgets/onboarding_privacy_zone.dart';

// docs/features/onboarding.feature, "Your privacy" step. The copy must match
// what the app does: records are in the phone's own backup, and optional
// weather sends an approximate location to Open-Meteo (see #98).

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      // The app lock offer has its own tests (onboarding_app_lock_offer_test).
      overrides: [appLockSupportedProvider.overrideWithValue(false)],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OnboardingPrivacyZone(onNext: () {}),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('headline and facts mention phone backups, not "never leaves"', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Your records live on this device.'), findsOneWidget);
    expect(
      find.textContaining(
        "Your records are included in your phone's own backup. Otherwise",
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Health Flare has no server'), findsOneWidget);
    expect(find.textContaining('stays on this device'), findsNothing);
    expect(find.textContaining('Nothing is uploaded'), findsNothing);
  });

  testWidgets(
    'details explain backups, how each platform protects them, and weather',
    (tester) async {
      await _pump(tester);
      await tester.tap(find.text('How does this work?  ›'));
      await tester.pumpAndSettle();

      expect(find.textContaining('iCloud Backup on iPhone'), findsOneWidget);
      expect(find.textContaining('Advanced Data Protection'), findsOneWidget);
      expect(find.textContaining('screen lock'), findsOneWidget);
      expect(find.textContaining('Manage Account Storage'), findsOneWidget);
      expect(find.textContaining('sent to Open-Meteo'), findsOneWidget);
      expect(find.textContaining('This is the only copy'), findsNothing);
      expect(find.textContaining('There is no cloud backup'), findsNothing);
      expect(find.textContaining('You can restore a profile'), findsNothing);
    },
  );
}
