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
  Future<void> write(AppLockSettings settings) => _isar.writeTxn(() async {
    final row = await _isar.appSettings.get(1) ?? (AppSettings()..id = 1);
    row
      ..appLockEnabled = settings.enabled
      ..appLockRelockSeconds = settings.relockAfter.duration.inSeconds
      ..hideInAppSwitcher = settings.hideInAppSwitcher;
    await _isar.appSettings.put(row);
  });
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
  AppLockSettings? _preloaded;
  bool _preloadedScreenLock = true;

  /// When the app last left the screen, or null while it's on screen (or
  /// left only for something the app opened itself).
  DateTime? _backgroundedAt;

  /// Trips out of the app that the app started on purpose ([whileAway]),
  /// including the OS unlock prompt itself.
  int _away = 0;

  /// Called from [main] before [runApp]: a locked app must be locked on its
  /// very first frame.
  void preload(AppLockSettings settings, {required bool hasScreenLock}) {
    _preloaded = settings;
    _preloadedScreenLock = hasScreenLock;
  }

  DeviceAuth get _auth => ref.read(deviceAuthProvider);

  @override
  AppLockState build() {
    final settings = _preloaded;
    // main() always preloads, hot restart included (it re-runs main). Only
    // tests and tools that build the app without main() get the defaults.
    if (settings == null) return const AppLockState();
    _preloaded = null;
    if (settings.hideInAppSwitcher) {
      ref.read(secureWindowProvider).setHidden(true);
    }
    return AppLockState(
      settings: settings,
      locked: settings.enabled && _preloadedScreenLock,
      paused: settings.enabled && !_preloadedScreenLock,
    );
  }

  Future<void> _save(AppLockSettings settings) async {
    await ref.read(appLockStoreProvider).write(settings);
    if (!ref.mounted) return;
    state = state.copyWith(settings: settings);
  }

  /// Shows the OS prompt without the prompt itself counting as leaving the
  /// app (Android's passcode screen sends the app to the background).
  Future<DeviceAuthResult> _ask(String reason) =>
      whileAway(() => _auth.authenticate(reason: reason));

  /// Turns the lock on after the person confirms with the phone's security.
  Future<LockChange> enable() async {
    if (!await _auth.hasScreenLock()) return LockChange.noScreenLock;
    switch (await _ask(AppLockReasons.turnOn)) {
      case DeviceAuthResult.success:
        break;
      case DeviceAuthResult.cancelled:
        return LockChange.cancelled;
      case DeviceAuthResult.noScreenLock:
        return LockChange.noScreenLock;
    }
    await _save(state.settings.copyWith(enabled: true));
    state = state.copyWith(locked: false, paused: false);
    return LockChange.done;
  }

  /// Turns the lock off after the person confirms with the phone's security.
  ///
  /// While the lock is paused (the phone has no screen lock to ask for) it
  /// turns off without a prompt: the app is already open to whoever holds
  /// the phone.
  Future<LockChange> disable() async {
    final result = await _ask(AppLockReasons.turnOff);
    if (result == DeviceAuthResult.cancelled) return LockChange.cancelled;
    if (result == DeviceAuthResult.noScreenLock && !state.paused) {
      return LockChange.noScreenLock;
    }
    await _save(state.settings.copyWith(enabled: false));
    state = state.copyWith(locked: false, paused: false);
    return LockChange.done;
  }

  /// A longer time asks for the phone's security first; a shorter one
  /// doesn't.
  Future<LockChange> setRelockAfter(RelockAfter value) async {
    final current = state.settings.relockAfter;
    if (value == current) return LockChange.done;
    if (value.duration > current.duration && !state.paused) {
      final result = await _ask(AppLockReasons.relockLonger);
      if (result == DeviceAuthResult.cancelled) return LockChange.cancelled;
      if (result == DeviceAuthResult.noScreenLock) {
        return LockChange.noScreenLock;
      }
    }
    await _save(state.settings.copyWith(relockAfter: value));
    return LockChange.done;
  }

  Future<void> setHideInAppSwitcher(bool hidden) async {
    await ref.read(secureWindowProvider).setHidden(hidden);
    await _save(state.settings.copyWith(hideInAppSwitcher: hidden));
  }

  /// The app left the screen.
  void backgrounded() {
    if (_away > 0) return;
    _backgroundedAt ??= ref.read(clockProvider)();
  }

  /// The app came back to the screen.
  void resumed() {
    final leftAt = _backgroundedAt;
    _backgroundedAt = null;
    if (leftAt == null || !state.settings.enabled || state.locked) return;
    if (state.paused) {
      _checkPauseLifted();
      return;
    }
    final away = ref.read(clockProvider)().difference(leftAt);
    if (away >= state.settings.relockAfter.duration) {
      state = state.copyWith(locked: true);
    }
  }

  /// A paused lock comes back once the phone has a screen lock again. It
  /// locks next time the app is away, not under the person's hands.
  Future<void> _checkPauseLifted() async {
    if (!await _auth.hasScreenLock()) return;
    if (!ref.mounted) return;
    state = state.copyWith(paused: false);
  }

  /// Asks for the phone's security and unlocks on success. If the phone no
  /// longer has a screen lock, the lock is paused instead.
  Future<void> unlock() async {
    if (!state.locked || _away > 0) return;
    final result = await _ask(AppLockReasons.unlock);
    if (!ref.mounted) return;
    switch (result) {
      case DeviceAuthResult.success:
        state = state.copyWith(locked: false);
      case DeviceAuthResult.noScreenLock:
        state = state.copyWith(locked: false, paused: true);
      case DeviceAuthResult.cancelled:
        break;
    }
  }

  /// Runs [action], which takes the person out of the app on purpose (camera,
  /// file picker, share sheet, permission prompt), without locking on return.
  Future<T> whileAway<T>(Future<T> Function() action) async {
    _away++;
    try {
      return await action();
    } finally {
      _away--;
      // Leaving during the trip doesn't count; leaving after it does.
      if (_away == 0) _backgroundedAt = null;
    }
  }
}

final appLockProvider = NotifierProvider<AppLockNotifier, AppLockState>(
  AppLockNotifier.new,
);
