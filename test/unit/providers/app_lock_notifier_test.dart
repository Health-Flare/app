import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/app_lock_provider.dart';
import 'package:health_flare/core/security/device_auth.dart';

import '../../helpers/app_lock_fakes.dart';

// docs/features/app-lock.feature (#100, #101): the lock rules, without UI.

class _Harness {
  _Harness({
    AppLockSettings settings = const AppLockSettings(),
    bool screenLock = true,
  }) : auth = FakeDeviceAuth(screenLock: screenLock),
       store = MemoryAppLockStore(settings) {
    container = ProviderContainer(
      overrides: appLockOverrides(
        auth: auth,
        store: store,
        window: window,
        clock: clock,
      ),
    );
  }

  final FakeDeviceAuth auth;
  final MemoryAppLockStore store;
  final window = FakeSecureWindow();
  final clock = FakeClock();
  late final ProviderContainer container;

  AppLockState get state => container.read(appLockProvider);
  AppLockNotifier get lock => container.read(appLockProvider.notifier);

  /// Background for [away], then come back.
  void leaveFor(Duration away) {
    lock.backgrounded();
    clock.advance(away);
    lock.resumed();
  }

  void dispose() => container.dispose();
}

const _on = AppLockSettings(enabled: true);

AppLockSettings _onWith(RelockAfter r) =>
    AppLockSettings(enabled: true, relockAfter: r);

void main() {
  group('defaults', () {
    test('the lock and hide in app switcher are off', () {
      final h = _Harness();
      addTearDown(h.dispose);
      expect(h.state.settings, const AppLockSettings());
      expect(h.state.settings.enabled, isFalse);
      expect(h.state.settings.hideInAppSwitcher, isFalse);
      expect(h.state.settings.relockAfter, RelockAfter.fifteenMinutes);
      expect(h.state.locked, isFalse);
    });

    test('a stored null or unknown re-lock time reads as 15 minutes', () {
      expect(RelockAfter.fromSeconds(null), RelockAfter.fifteenMinutes);
      expect(RelockAfter.fromSeconds(42), RelockAfter.fifteenMinutes);
      expect(RelockAfter.fromSeconds(0), RelockAfter.immediately);
      expect(RelockAfter.fromSeconds(60), RelockAfter.oneMinute);
      expect(RelockAfter.fromSeconds(300), RelockAfter.fiveMinutes);
    });

    test('the offered re-lock times, in order', () {
      expect(RelockAfter.values.map((r) => r.label), [
        'Immediately',
        '1 minute',
        '5 minutes',
        '15 minutes',
      ]);
    });
  });

  group('cold start', () {
    test('the app is locked when it starts with the lock on', () {
      final h = _Harness(settings: _on);
      addTearDown(h.dispose);
      expect(h.state.locked, isTrue);
      expect(h.state.paused, isFalse);
    });

    test('the app is not locked when it starts with the lock off', () {
      final h = _Harness();
      addTearDown(h.dispose);
      expect(h.state.locked, isFalse);
    });

    test('the lock pauses, and is kept, when the phone has no screen lock', () {
      final h = _Harness(settings: _on, screenLock: false);
      addTearDown(h.dispose);
      expect(h.state.locked, isFalse);
      expect(h.state.paused, isTrue);
      expect(h.state.settings.enabled, isTrue);
      expect(h.store.writes, 0);
    });

    test('hide in app switcher is applied from the start', () {
      final h = _Harness(
        settings: const AppLockSettings(hideInAppSwitcher: true),
      );
      addTearDown(h.dispose);
      h.state; // build
      expect(h.window.hidden, isTrue);
    });
  });

  group('turning the lock on', () {
    test('confirming turns it on with a 15 minute re-lock time', () async {
      final h = _Harness();
      addTearDown(h.dispose);

      expect(await h.lock.enable(), LockChange.done);

      expect(h.auth.reasons, [AppLockReasons.turnOn]);
      expect(h.state.settings.enabled, isTrue);
      expect(h.state.settings.relockAfter, RelockAfter.fifteenMinutes);
      expect(h.store.settings.enabled, isTrue);
      // Turning it on doesn't lock the person out of the screen they're on.
      expect(h.state.locked, isFalse);
    });

    test('cancelling the prompt leaves it off', () async {
      final h = _Harness();
      addTearDown(h.dispose);
      h.auth.next = DeviceAuthResult.cancelled;

      expect(await h.lock.enable(), LockChange.cancelled);

      expect(h.state.settings.enabled, isFalse);
      expect(h.store.writes, 0);
    });

    test('it can\'t be turned on without a screen lock on the phone', () async {
      final h = _Harness(screenLock: false);
      addTearDown(h.dispose);

      expect(await h.lock.enable(), LockChange.noScreenLock);

      expect(h.state.settings.enabled, isFalse);
      expect(h.store.writes, 0);
      expect(h.auth.prompts, 0);
    });

    test('turning it on does not turn on hide in app switcher', () async {
      final h = _Harness();
      addTearDown(h.dispose);
      await h.lock.enable();
      expect(h.state.settings.hideInAppSwitcher, isFalse);
      expect(h.window.hidden, isNot(true));
    });
  });

  group('turning the lock off', () {
    test('confirming turns it off', () async {
      final h = _Harness(settings: _on);
      addTearDown(h.dispose);
      await h.lock.unlock();
      h.auth.reasons.clear();

      expect(await h.lock.disable(), LockChange.done);

      expect(h.auth.reasons, [AppLockReasons.turnOff]);
      expect(h.state.settings.enabled, isFalse);
      expect(h.store.settings.enabled, isFalse);
    });

    test('cancelling the prompt keeps it on', () async {
      final h = _Harness(settings: _on);
      addTearDown(h.dispose);
      await h.lock.unlock();
      h.auth.next = DeviceAuthResult.cancelled;

      expect(await h.lock.disable(), LockChange.cancelled);

      expect(h.state.settings.enabled, isTrue);
      expect(h.store.settings.enabled, isTrue);
    });
  });

  group('re-lock time', () {
    test('a longer time asks for the phone\'s security first', () async {
      final h = _Harness(settings: _onWith(RelockAfter.oneMinute));
      addTearDown(h.dispose);
      await h.lock.unlock();
      h.auth.reasons.clear();
      h.auth.next = DeviceAuthResult.cancelled;

      expect(
        await h.lock.setRelockAfter(RelockAfter.fifteenMinutes),
        LockChange.cancelled,
      );
      expect(h.state.settings.relockAfter, RelockAfter.oneMinute);

      h.auth.next = DeviceAuthResult.success;
      expect(
        await h.lock.setRelockAfter(RelockAfter.fifteenMinutes),
        LockChange.done,
      );
      expect(h.auth.reasons, [
        AppLockReasons.relockLonger,
        AppLockReasons.relockLonger,
      ]);
      expect(h.state.settings.relockAfter, RelockAfter.fifteenMinutes);
      expect(h.store.settings.relockAfter, RelockAfter.fifteenMinutes);
    });

    test('a shorter time doesn\'t ask', () async {
      final h = _Harness(settings: _on);
      addTearDown(h.dispose);
      await h.lock.unlock();
      h.auth.reasons.clear();

      expect(
        await h.lock.setRelockAfter(RelockAfter.immediately),
        LockChange.done,
      );
      expect(h.auth.prompts, 0);
      expect(h.state.settings.relockAfter, RelockAfter.immediately);
      expect(h.store.settings.relockAfter, RelockAfter.immediately);
    });
  });

  group('locking after the background', () {
    final cases = <(RelockAfter, Duration, bool)>[
      (RelockAfter.immediately, const Duration(seconds: 1), true),
      (RelockAfter.oneMinute, const Duration(seconds: 59), false),
      (RelockAfter.oneMinute, const Duration(minutes: 1), true),
      (RelockAfter.fiveMinutes, const Duration(minutes: 4), false),
      (RelockAfter.fiveMinutes, const Duration(minutes: 5), true),
      (RelockAfter.fifteenMinutes, const Duration(minutes: 14), false),
      (RelockAfter.fifteenMinutes, const Duration(minutes: 15), true),
    ];
    for (final (relock, away, locks) in cases) {
      test(
        '${relock.label}, away $away: ${locks ? 'locked' : 'unlocked'}',
        () async {
          final h = _Harness(settings: _onWith(relock));
          addTearDown(h.dispose);
          await h.lock.unlock();
          expect(h.state.locked, isFalse);

          h.leaveFor(away);

          expect(h.state.locked, locks);
        },
      );
    }

    test('never locks while the lock is off', () {
      final h = _Harness();
      addTearDown(h.dispose);
      h.leaveFor(const Duration(hours: 3));
      expect(h.state.locked, isFalse);
    });

    test('coming back without having left does not lock', () async {
      final h = _Harness(settings: _onWith(RelockAfter.immediately));
      addTearDown(h.dispose);
      await h.lock.unlock();
      h.lock.resumed();
      expect(h.state.locked, isFalse);
    });
  });

  group('things the app opens itself', () {
    test('a trip out of the app it started does not lock it', () async {
      final h = _Harness(settings: _onWith(RelockAfter.immediately));
      addTearDown(h.dispose);
      await h.lock.unlock();

      final result = await h.lock.whileAway(() async {
        h.leaveFor(const Duration(minutes: 2)); // e.g. the camera
        return 'photo.jpg';
      });

      expect(result, 'photo.jpg');
      expect(h.state.locked, isFalse);
    });

    test('a later trip out of the app still locks it', () async {
      final h = _Harness(settings: _onWith(RelockAfter.immediately));
      addTearDown(h.dispose);
      await h.lock.unlock();
      await h.lock.whileAway(() async => h.leaveFor(Duration.zero));

      h.leaveFor(const Duration(seconds: 1));

      expect(h.state.locked, isTrue);
    });

    test('a failed trip out still ends the exemption', () async {
      final h = _Harness(settings: _onWith(RelockAfter.immediately));
      addTearDown(h.dispose);
      await h.lock.unlock();

      await expectLater(
        h.lock.whileAway<void>(() async => throw StateError('picker failed')),
        throwsStateError,
      );
      h.leaveFor(const Duration(seconds: 1));

      expect(h.state.locked, isTrue);
    });
  });

  group('unlocking', () {
    test('confirming unlocks', () async {
      final h = _Harness(settings: _on);
      addTearDown(h.dispose);

      await h.lock.unlock();

      expect(h.auth.reasons, [AppLockReasons.unlock]);
      expect(h.state.locked, isFalse);
    });

    test('cancelling stays locked', () async {
      final h = _Harness(settings: _on);
      addTearDown(h.dispose);
      h.auth.next = DeviceAuthResult.cancelled;

      await h.lock.unlock();

      expect(h.state.locked, isTrue);
    });

    test('the unlock prompt itself does not lock the app again', () async {
      final h = _Harness(settings: _onWith(RelockAfter.immediately));
      addTearDown(h.dispose);
      final answer = Completer<DeviceAuthResult>();
      h.auth.pending = answer;

      final unlocking = h.lock.unlock();
      // Android's passcode screen sends the app to the background.
      h.leaveFor(const Duration(seconds: 5));
      answer.complete(DeviceAuthResult.success);
      await unlocking;

      expect(h.state.locked, isFalse);
      expect(h.auth.prompts, 1);
    });

    test('the lock pauses when the phone\'s screen lock was removed', () async {
      final h = _Harness(settings: _on);
      addTearDown(h.dispose);
      h.auth.screenLock = false;

      await h.lock.unlock();

      expect(h.state.locked, isFalse);
      expect(h.state.paused, isTrue);
      expect(h.state.settings.enabled, isTrue);
      expect(h.store.settings.enabled, isTrue);
    });

    test('a paused lock does not lock on return', () async {
      final h = _Harness(
        settings: _onWith(RelockAfter.immediately),
        screenLock: false,
      );
      addTearDown(h.dispose);
      h.leaveFor(const Duration(minutes: 30));
      expect(h.state.locked, isFalse);
      expect(h.state.paused, isTrue);
    });

    test(
      'a paused lock comes back once the phone has a screen lock again',
      () async {
        final h = _Harness(
          settings: _onWith(RelockAfter.immediately),
          screenLock: false,
        );
        addTearDown(h.dispose);

        h.auth.screenLock = true;
        h.leaveFor(const Duration(seconds: 1));
        await pumpEventQueue();
        expect(h.state.paused, isFalse);

        h.leaveFor(const Duration(seconds: 1));
        expect(h.state.locked, isTrue);
      },
    );
  });

  group('hide in app switcher', () {
    test('turning it on and off needs no prompt and is saved', () async {
      final h = _Harness();
      addTearDown(h.dispose);

      await h.lock.setHideInAppSwitcher(true);
      expect(h.state.settings.hideInAppSwitcher, isTrue);
      expect(h.store.settings.hideInAppSwitcher, isTrue);
      expect(h.window.hidden, isTrue);

      await h.lock.setHideInAppSwitcher(false);
      expect(h.state.settings.hideInAppSwitcher, isFalse);
      expect(h.store.settings.hideInAppSwitcher, isFalse);
      expect(h.window.hidden, isFalse);

      expect(h.auth.prompts, 0);
    });

    test('it works without the app lock', () async {
      final h = _Harness();
      addTearDown(h.dispose);
      await h.lock.setHideInAppSwitcher(true);
      expect(h.state.settings.enabled, isFalse);
      expect(h.state.settings.hideInAppSwitcher, isTrue);
    });
  });
}
