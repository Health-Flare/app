import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/app_lock_provider.dart';
import 'package:health_flare/core/security/device_auth.dart';
import 'package:health_flare/features/settings/widgets/privacy_settings_section.dart';

import '../helpers/app_lock_fakes.dart';

// docs/features/app-lock.feature: Settings > Privacy (#100, #101).

const _noScreenLock =
    "Set a screen lock in your phone's settings first, then come back to turn "
    'this on.';

class _Setup {
  _Setup({
    AppLockSettings settings = const AppLockSettings(),
    bool screenLock = true,
    this.supported = true,
  }) : auth = FakeDeviceAuth(screenLock: screenLock),
       store = MemoryAppLockStore(settings);

  final FakeDeviceAuth auth;
  final MemoryAppLockStore store;
  final bool supported;
  final window = FakeSecureWindow();
  final clock = FakeClock();

  Future<void> pump(WidgetTester tester) async {
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
            body: ListView(children: const [PrivacySettingsSection()]),
          ),
        ),
      ),
    );
    await tester.pump();
  }
}

Finder _switch(String title) => find.widgetWithText(SwitchListTile, title);

bool _isOn(WidgetTester tester, String title) =>
    tester.widget<SwitchListTile>(_switch(title)).value;

Future<void> _tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

const _lockOn = AppLockSettings(enabled: true);

void main() {
  testWidgets('both settings start off and Lock after is hidden', (
    tester,
  ) async {
    await _Setup().pump(tester);

    expect(find.text('Privacy'), findsOneWidget);
    expect(_isOn(tester, 'App lock'), isFalse);
    expect(_isOn(tester, 'Hide in app switcher'), isFalse);
    expect(find.text('Lock after'), findsNothing);
  });

  testWidgets('the app lock copy says it does not encrypt', (tester) async {
    await _Setup().pump(tester);
    expect(
      find.textContaining('face, fingerprint or phone passcode'),
      findsOneWidget,
    );
    expect(
      find.textContaining("doesn't encrypt the records stored on your phone"),
      findsOneWidget,
    );
  });

  group('turning the lock on', () {
    testWidgets('confirming turns it on and suggests hiding the app', (
      tester,
    ) async {
      final s = _Setup();
      await s.pump(tester);

      await _tapAndSettle(tester, _switch('App lock'));

      expect(s.auth.reasons, [AppLockReasons.turnOn]);
      expect(
        find.text('Also hide Health Flare in the app switcher?'),
        findsOneWidget,
      );
      // Not switched on until the person accepts.
      expect(s.store.settings.hideInAppSwitcher, isFalse);

      await _tapAndSettle(tester, find.text('Hide it'));

      expect(_isOn(tester, 'App lock'), isTrue);
      expect(_isOn(tester, 'Hide in app switcher'), isTrue);
      expect(s.store.settings.hideInAppSwitcher, isTrue);
      expect(find.text('Lock after'), findsOneWidget);
      expect(find.text('15 minutes'), findsOneWidget);
    });

    testWidgets('declining the suggestion leaves the app switcher alone', (
      tester,
    ) async {
      final s = _Setup();
      await s.pump(tester);

      await _tapAndSettle(tester, _switch('App lock'));
      await _tapAndSettle(tester, find.text('Not now'));

      expect(_isOn(tester, 'App lock'), isTrue);
      expect(_isOn(tester, 'Hide in app switcher'), isFalse);
      expect(s.store.settings.hideInAppSwitcher, isFalse);
    });

    testWidgets('no suggestion when the app is already hidden', (tester) async {
      final s = _Setup(
        settings: const AppLockSettings(hideInAppSwitcher: true),
      );
      await s.pump(tester);

      await _tapAndSettle(tester, _switch('App lock'));

      expect(_isOn(tester, 'App lock'), isTrue);
      expect(
        find.text('Also hide Health Flare in the app switcher?'),
        findsNothing,
      );
    });

    testWidgets('cancelling the prompt leaves it off', (tester) async {
      final s = _Setup()..auth.next = DeviceAuthResult.cancelled;
      await s.pump(tester);

      await _tapAndSettle(tester, _switch('App lock'));

      expect(_isOn(tester, 'App lock'), isFalse);
      expect(
        find.text('Also hide Health Flare in the app switcher?'),
        findsNothing,
      );
    });

    testWidgets('without a screen lock on the phone it says what to do', (
      tester,
    ) async {
      final s = _Setup(screenLock: false);
      await s.pump(tester);

      await _tapAndSettle(tester, _switch('App lock'));

      expect(_isOn(tester, 'App lock'), isFalse);
      expect(find.text(_noScreenLock), findsOneWidget);
    });
  });

  group('turning the lock off', () {
    testWidgets('asks for the phone\'s security first', (tester) async {
      final s = _Setup(settings: _lockOn);
      await s.pump(tester);
      await tester.pump();
      s.auth.reasons.clear();

      await _tapAndSettle(tester, _switch('App lock'));

      expect(s.auth.reasons, [AppLockReasons.turnOff]);
      expect(_isOn(tester, 'App lock'), isFalse);
      expect(find.text('Lock after'), findsNothing);
    });

    testWidgets('cancelling keeps it on', (tester) async {
      final s = _Setup(settings: _lockOn);
      await s.pump(tester);
      await tester.pump();
      s.auth.next = DeviceAuthResult.cancelled;

      await _tapAndSettle(tester, _switch('App lock'));

      expect(_isOn(tester, 'App lock'), isTrue);
    });
  });

  group('Lock after', () {
    testWidgets('offers the four times', (tester) async {
      await _Setup(settings: _lockOn).pump(tester);

      await _tapAndSettle(tester, find.text('Lock after'));

      for (final label in [
        'Immediately',
        '1 minute',
        '5 minutes',
        '15 minutes',
      ]) {
        expect(
          find.widgetWithText(RadioListTile<RelockAfter>, label),
          findsOneWidget,
        );
      }
    });

    testWidgets('a shorter time is saved without asking', (tester) async {
      final s = _Setup(settings: _lockOn);
      await s.pump(tester);
      s.auth.reasons.clear();

      await _tapAndSettle(tester, find.text('Lock after'));
      await _tapAndSettle(tester, find.text('Immediately'));

      expect(s.auth.prompts, 0);
      expect(s.store.settings.relockAfter, RelockAfter.immediately);
      expect(find.text('Immediately'), findsOneWidget);
    });

    testWidgets('a longer time asks first', (tester) async {
      final s = _Setup(
        settings: const AppLockSettings(
          enabled: true,
          relockAfter: RelockAfter.oneMinute,
        ),
      );
      await s.pump(tester);
      s.auth.reasons.clear();

      await _tapAndSettle(tester, find.text('Lock after'));
      await _tapAndSettle(tester, find.text('15 minutes'));

      expect(s.auth.reasons, [AppLockReasons.relockLonger]);
      expect(s.store.settings.relockAfter, RelockAfter.fifteenMinutes);
    });
  });

  group('hide in app switcher', () {
    testWidgets('works on its own, with no prompt', (tester) async {
      final s = _Setup();
      await s.pump(tester);

      await _tapAndSettle(tester, _switch('Hide in app switcher'));
      expect(_isOn(tester, 'Hide in app switcher'), isTrue);
      expect(_isOn(tester, 'App lock'), isFalse);
      expect(s.window.hidden, isTrue);

      await _tapAndSettle(tester, _switch('Hide in app switcher'));
      expect(_isOn(tester, 'Hide in app switcher'), isFalse);
      expect(s.window.hidden, isFalse);
      expect(s.auth.prompts, 0);
    });

    testWidgets('on Android it says it also blocks screenshots', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await _Setup().pump(tester);

      expect(
        find.textContaining('blocks screenshots and screen recording'),
        findsOneWidget,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('on iPhone it does not claim to block screenshots', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await _Setup().pump(tester);

      expect(find.textContaining('screenshots'), findsNothing);
      expect(find.textContaining('app switcher'), findsWidgets);
      debugDefaultTargetPlatformOverride = null;
    });
  });

  testWidgets('desktop and web builds show neither setting', (tester) async {
    await _Setup(supported: false).pump(tester);

    expect(find.text('Privacy'), findsNothing);
    expect(find.text('App lock'), findsNothing);
    expect(find.text('Hide in app switcher'), findsNothing);
  });
}
