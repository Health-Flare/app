import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Native channel that hides the app in the app switcher (#101).
/// Registered in android/.../MainActivity.kt and ios/Runner/AppDelegate.swift.
const secureWindowChannel = MethodChannel('org.healthflare.app/secure_window');

/// Hides or shows the app's content in the OS app switcher.
///
/// Android sets FLAG_SECURE, which also blanks screenshots and screen
/// recording. iOS covers the window while the app isn't active.
abstract interface class SecureWindow {
  Future<void> setHidden(bool hidden);
}

/// [SecureWindow] over [secureWindowChannel].
class PlatformSecureWindow implements SecureWindow {
  const PlatformSecureWindow();

  /// Never throws: failing to set the flag must not stop the app opening.
  @override
  Future<void> setHidden(bool hidden) async {
    if (kIsWeb) return;
    try {
      await secureWindowChannel.invokeMethod<void>('setHidden', {
        'hidden': hidden,
      });
    } on MissingPluginException {
      // Desktop, tests, or an embedding without the handler.
    } on PlatformException {
      debugPrint('Health Flare: could not change app switcher hiding.');
    }
  }
}

final secureWindowProvider = Provider<SecureWindow>(
  (ref) => const PlatformSecureWindow(),
);
