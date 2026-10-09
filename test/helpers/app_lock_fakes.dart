import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;

import 'package:health_flare/core/providers/app_lock_provider.dart';
import 'package:health_flare/core/providers/clock_provider.dart';
import 'package:health_flare/core/security/device_auth.dart';
import 'package:health_flare/core/security/secure_window.dart';

/// [DeviceAuth] whose answers the test sets.
class FakeDeviceAuth implements DeviceAuth {
  FakeDeviceAuth({
    this.screenLock = true,
    this.next = DeviceAuthResult.success,
  });

  /// Whether the phone has a screen lock.
  bool screenLock;

  /// What the next [authenticate] call answers, unless [pending] is set.
  DeviceAuthResult next;

  /// When set, [authenticate] waits on this instead of answering at once, so
  /// a test can send lifecycle events while the OS prompt is up.
  Completer<DeviceAuthResult>? pending;

  /// Reason passed to each [authenticate] call, in order.
  final reasons = <String>[];

  int get prompts => reasons.length;

  @override
  Future<bool> hasScreenLock() async => screenLock;

  @override
  Future<DeviceAuthResult> authenticate({required String reason}) async {
    reasons.add(reason);
    if (!screenLock) return DeviceAuthResult.noScreenLock;
    final p = pending;
    if (p != null) return p.future;
    return next;
  }
}

/// [SecureWindow] that records each call.
class FakeSecureWindow implements SecureWindow {
  final calls = <bool>[];

  bool? get hidden => calls.isEmpty ? null : calls.last;

  @override
  Future<void> setHidden(bool hidden) async => calls.add(hidden);
}

/// In-memory [AppLockStore].
class MemoryAppLockStore implements AppLockStore {
  MemoryAppLockStore([this.settings = const AppLockSettings()]);

  AppLockSettings settings;
  int writes = 0;

  @override
  Future<AppLockSettings> read() async => settings;

  @override
  Future<void> write(AppLockSettings settings) async {
    writes++;
    this.settings = settings;
  }
}

/// A clock the test moves by hand.
class FakeClock {
  FakeClock([DateTime? start]) : now = start ?? DateTime(2026, 10, 9, 9);

  DateTime now;

  void advance(Duration d) => now = now.add(d);

  DateTime call() => now;
}

/// Overrides for every app lock seam. [settings] and [screenLock] are what
/// `main` would have read before the first frame.
List<Override> appLockOverrides({
  required FakeDeviceAuth auth,
  required MemoryAppLockStore store,
  required FakeSecureWindow window,
  required FakeClock clock,
  bool supported = true,
}) => [
  deviceAuthProvider.overrideWithValue(auth),
  appLockStoreProvider.overrideWithValue(store),
  secureWindowProvider.overrideWithValue(window),
  clockProvider.overrideWithValue(clock.call),
  appLockSupportedProvider.overrideWithValue(supported),
  appLockProvider.overrideWith(
    () =>
        AppLockNotifier()
          ..preload(store.settings, hasScreenLock: auth.screenLock),
  ),
];
