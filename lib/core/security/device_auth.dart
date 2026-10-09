import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

/// Outcome of asking for the phone's own security.
enum DeviceAuthResult {
  /// The person confirmed with their face, fingerprint or passcode.
  success,

  /// They dismissed the prompt, failed it, or the OS stopped it.
  cancelled,

  /// The phone has no passcode, fingerprint or face unlock set up.
  noScreenLock,
}

/// The phone's own security: biometrics, falling back to the passcode.
///
/// Health Flare stores no PIN or secret of its own (#100). Overridden in
/// tests with a fake.
abstract interface class DeviceAuth {
  /// Whether the phone has a screen lock the app can ask for.
  Future<bool> hasScreenLock();

  /// Shows the OS prompt with [reason].
  Future<DeviceAuthResult> authenticate({required String reason});
}

/// [DeviceAuth] backed by local_auth's Android and iOS implementations
/// (see pubspec.yaml for why not the umbrella package).
class LocalDeviceAuth implements DeviceAuth {
  LocalDeviceAuth([LocalAuthPlatform? auth]) : _auth = auth;

  final LocalAuthPlatform? _auth;

  LocalAuthPlatform get _platform => _auth ?? LocalAuthPlatform.instance;

  @override
  Future<bool> hasScreenLock() async {
    try {
      return await _platform.isDeviceSupported();
    } on LocalAuthException {
      return false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      // Desktop, tests, or an embedding without the plugin.
      return false;
    }
  }

  @override
  Future<DeviceAuthResult> authenticate({required String reason}) async {
    try {
      final ok = await _platform.authenticate(
        localizedReason: reason,
        authMessages: const [IOSAuthMessages(), AndroidAuthMessages()],
        options: const AuthenticationOptions(
          // Passcode fallback: a failed sensor or re-enrolled face must
          // never lock someone out of their own records (there is no account
          // to recover through).
          biometricOnly: false,
          // Legacy option; local_auth 3.x always passes false.
          useErrorDialogs: false,
        ),
      );
      return ok ? DeviceAuthResult.success : DeviceAuthResult.cancelled;
    } on LocalAuthException catch (e) {
      return switch (e.code) {
        LocalAuthExceptionCode.noCredentialsSet ||
        LocalAuthExceptionCode.noBiometricHardware ||
        LocalAuthExceptionCode.noBiometricsEnrolled =>
          // With biometricOnly false these only reach us when there is no
          // passcode either.
          DeviceAuthResult.noScreenLock,
        _ => DeviceAuthResult.cancelled,
      };
    } on PlatformException {
      return DeviceAuthResult.cancelled;
    } on MissingPluginException {
      return DeviceAuthResult.noScreenLock;
    }
  }
}

final deviceAuthProvider = Provider<DeviceAuth>((ref) => LocalDeviceAuth());

/// Whether this build offers the app lock and hide-in-app-switcher settings:
/// iOS and Android only (see docs/features/app-lock.feature). Overridden in
/// tests.
final appLockSupportedProvider = Provider<bool>((ref) => appLockSupported());

bool appLockSupported() =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);
