import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/clock_provider.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/security/device_auth.dart';
import 'package:health_flare/core/security/secure_window.dart';
import 'package:health_flare/data/database/app_settings.dart';

// App lock (#100) and hide in app switcher (#101).
// Spec: docs/features/app-lock.feature

/// How long the app may be in the background before it locks again.
enum RelockAfter {
  immediately(Duration.zero, 'Immediately'),
  oneMinute(Duration(minutes: 1), '1 minute'),
  fiveMinutes(Duration(minutes: 5), '5 minutes'),
  fifteenMinutes(Duration(minutes: 15), '15 minutes');

  const RelockAfter(this.duration, this.label);

  final Duration duration;
  final String label;

  static const fallback = RelockAfter.fifteenMinutes;

  /// The stored value, or [fallback] for null or a value no longer offered.
  static RelockAfter fromSeconds(int? seconds) => RelockAfter.values.firstWhere(
    (r) => r.duration.inSeconds == seconds,
    orElse: () => fallback,
  );
}

/// The persisted, device-local lock settings.
class AppLockSettings {
  const AppLockSettings({
    this.enabled = false,
    this.relockAfter = RelockAfter.fallback,
    this.hideInAppSwitcher = false,
  });

  final bool enabled;
  final RelockAfter relockAfter;
  final bool hideInAppSwitcher;

  AppLockSettings copyWith({
    bool? enabled,
    RelockAfter? relockAfter,
    bool? hideInAppSwitcher,
  }) => AppLockSettings(
    enabled: enabled ?? this.enabled,
    relockAfter: relockAfter ?? this.relockAfter,
    hideInAppSwitcher: hideInAppSwitcher ?? this.hideInAppSwitcher,
  );

  @override
  bool operator ==(Object other) =>
      other is AppLockSettings &&
      other.enabled == enabled &&
      other.relockAfter == relockAfter &&
      other.hideInAppSwitcher == hideInAppSwitcher;

  @override
  int get hashCode => Object.hash(enabled, relockAfter, hideInAppSwitcher);

  @override
  String toString() =>
      'AppLockSettings(enabled: $enabled, relockAfter: $relockAfter, '
      'hideInAppSwitcher: $hideInAppSwitcher)';
}

/// What the gate shows right now.
class AppLockState {
  const AppLockState({
    this.settings = const AppLockSettings(),
    this.locked = false,
    this.paused = false,
  });

  final AppLockSettings settings;

  /// The lock screen is shown and nothing behind it can be read or reached.
  final bool locked;

  /// The lock is on, but the phone has no screen lock to ask for, so the app
  /// opens unlocked and says so. The setting is kept.
  final bool paused;

  AppLockState copyWith({
    AppLockSettings? settings,
    bool? locked,
    bool? paused,
  }) => AppLockState(
    settings: settings ?? this.settings,
    locked: locked ?? this.locked,
    paused: paused ?? this.paused,
  );
}

/// Result of changing a lock setting that may need the phone's security.
enum LockChange {
  done,
  cancelled,

  /// The phone has no screen lock, so the lock can't be turned on.
  noScreenLock,
}

/// Reads and writes [AppLockSettings]. Overridden in widget tests with an
/// in-memory store (pumping several Isar-backed trees in one file hangs).
abstract interface class AppLockStore {
  Future<AppLockSettings> read();
  Future<void> write(AppLockSettings settings);
}

/// [AppLockStore] over the [AppSettings] singleton.
class IsarAppLockStore implements AppLockStore {
  const IsarAppLockStore(this._isar);

  final Isar _isar;

  static AppLockSettings fromRow(AppSettings? row) => row == null
      ? const AppLockSettings()
      : AppLockSettings(
          enabled: row.appLockEnabled,
          relockAfter: RelockAfter.fromSeconds(row.appLockRelockSeconds),
          hideInAppSwitcher: row.hideInAppSwitcher,
        );

  @override
  Future<AppLockSettings> read() async =>
      fromRow(await _isar.appSettings.get(1));

  @override
  Future<void> write(AppLockSettings settings) async {
    throw UnimplementedError('#100');
  }
}

final appLockStoreProvider = Provider<AppLockStore>(
  (ref) => IsarAppLockStore(ref.watch(isarProvider)),
);

/// Prompt text shown by the OS when Health Flare asks for the phone's
/// security.
abstract final class AppLockReasons {
  static const unlock = 'Unlock Health Flare';
  static const turnOn = 'Turn on the app lock';
  static const turnOff = 'Turn off the app lock';
  static const relockLonger = 'Change when Health Flare locks';
}

class AppLockNotifier extends Notifier<AppLockState> {
  /// Called from [main] before [runApp]: a locked app must be locked on its
  /// very first frame.
  void preload(AppLockSettings settings, {required bool hasScreenLock}) {
    throw UnimplementedError('#100');
  }

  @override
  AppLockState build() => const AppLockState();

  /// Turns the lock on after the person confirms with the phone's security.
  Future<LockChange> enable() async => throw UnimplementedError('#100');

  /// Turns the lock off after the person confirms with the phone's security.
  Future<LockChange> disable() async => throw UnimplementedError('#100');

  /// A longer time asks for the phone's security first; a shorter one
  /// doesn't.
  Future<LockChange> setRelockAfter(RelockAfter value) async =>
      throw UnimplementedError('#100');

  Future<void> setHideInAppSwitcher(bool hidden) async =>
      throw UnimplementedError('#100');

  /// The app left the screen.
  void backgrounded() => throw UnimplementedError('#100');

  /// The app came back to the screen.
  void resumed() => throw UnimplementedError('#100');

  /// Asks for the phone's security and unlocks on success. If the phone no
  /// longer has a screen lock, the lock is paused instead.
  Future<void> unlock() async => throw UnimplementedError('#100');

  /// Runs [action], which takes the person out of the app on purpose (camera,
  /// file picker, share sheet, permission prompt), without locking on return.
  Future<T> whileAway<T>(Future<T> Function() action) =>
      throw UnimplementedError('#100');

  // Referenced so the stub compiles with the dependencies the real
  // implementation uses.
  // ignore: unused_element
  void _deps() => (
    ref.read(clockProvider),
    ref.read(deviceAuthProvider),
    ref.read(secureWindowProvider),
    ref.read(appLockStoreProvider),
  );
}

final appLockProvider = NotifierProvider<AppLockNotifier, AppLockState>(
  AppLockNotifier.new,
);
