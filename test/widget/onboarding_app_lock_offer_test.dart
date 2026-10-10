import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/app_lock_provider.dart';
import 'package:health_flare/core/security/device_auth.dart';
import 'package:health_flare/features/onboarding/widgets/onboarding_privacy_zone.dart';

import '../helpers/app_lock_fakes.dart';

// docs/features/app-lock.feature: the onboarding privacy step offers the
// app lock (#100).

class _Setup {
  _Setup({bool screenLock = true, this.supported = true})
    : auth = FakeDeviceAuth(screenLock: screenLock);

  final FakeDeviceAuth auth;
  final bool supported;
  final store = MemoryAppLockStore();
  final window = FakeSecureWindow();
  final clock = FakeClock();

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: appLockOverrides(
          auth: auth,
          store: store,
          window: window,
          clock: clock,
          supported: supported,
        ),
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
}

Finder get _offer => find.widgetWithText(SwitchListTile, 'Lock Health Flare');

void main() {
  testWidgets('the privacy step offers the lock, switched off', (tester) async {
    await _Setup().pump(tester);

    expect(_offer, findsOneWidget);
    expect(tester.widget<SwitchListTile>(_offer).value, isFalse);
    expect(
      find.textContaining('face, fingerprint or phone passcode'),
      findsOneWidget,
    );
    expect(
      find.textContaining("doesn't encrypt the records stored on your phone"),
      findsOneWidget,
    );
  });

  testWidgets('switching it on and confirming turns the lock on', (
    tester,
  ) async {
    final s = _Setup();
    await s.pump(tester);

    await tester.tap(_offer);
    await tester.pumpAndSettle();

    expect(s.auth.reasons, [AppLockReasons.turnOn]);
    expect(s.store.settings.enabled, isTrue);
    expect(s.store.settings.relockAfter, RelockAfter.fifteenMinutes);
    // Same suggestion as Settings.
    expect(
      find.text('Also hide Health Flare in the app switcher?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(_offer).value, isTrue);
  });

  testWidgets('cancelling leaves it off', (tester) async {
    final s = _Setup()..auth.next = DeviceAuthResult.cancelled;
    await s.pump(tester);

    await tester.tap(_offer);
    await tester.pumpAndSettle();

    expect(s.store.settings.enabled, isFalse);
    expect(tester.widget<SwitchListTile>(_offer).value, isFalse);
  });

  testWidgets('without a screen lock it says what to do', (tester) async {
    final s = _Setup(screenLock: false);
    await s.pump(tester);

    await tester.tap(_offer);
    await tester.pumpAndSettle();

    expect(s.store.settings.enabled, isFalse);
    expect(
      find.text(
        "Set a screen lock in your phone's settings first, then come back "
        'to turn this on.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('desktop and web builds don\'t offer it', (tester) async {
    await _Setup(supported: false).pump(tester);
    expect(find.text('Lock Health Flare'), findsNothing);
    // The rest of the step is still there.
    expect(find.text('Your records live on this device.'), findsOneWidget);
  });
}
