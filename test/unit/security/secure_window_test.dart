import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/security/secure_window.dart';

// docs/features/app-lock.feature, "Hide in app switcher" (#101), and the
// native wiring the app lock (#100) needs.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(secureWindowChannel, null));

  group('PlatformSecureWindow', () {
    test('asks the native side to hide and show the app', () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(secureWindowChannel, (call) async {
        calls.add(call);
        return null;
      });

      await const PlatformSecureWindow().setHidden(true);
      await const PlatformSecureWindow().setHidden(false);

      expect(calls.map((c) => c.method), ['setHidden', 'setHidden']);
      expect(calls.map((c) => c.arguments), [
        {'hidden': true},
        {'hidden': false},
      ]);
    });

    test('a missing or failing native side never throws', () async {
      await const PlatformSecureWindow().setHidden(true);

      messenger.setMockMethodCallHandler(secureWindowChannel, (call) async {
        throw PlatformException(code: 'boom');
      });
      await const PlatformSecureWindow().setHidden(true);
    });
  });

  group('Android', () {
    final activity = File(
      'android/app/src/main/kotlin/org/healthflare/app/healthflare/MainActivity.kt',
    ).readAsStringSync();

    test('MainActivity is a FlutterFragmentActivity (local_auth needs it)', () {
      expect(activity, contains('FlutterFragmentActivity()'));
    });

    test('MainActivity sets FLAG_SECURE over the secure_window channel', () {
      expect(activity, contains('org.healthflare.app/secure_window'));
      expect(activity, contains('FLAG_SECURE'));
    });
  });

  group('iOS', () {
    test('Info.plist explains Face ID use', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      expect(plist, contains('NSFaceIDUsageDescription'));
    });

    test('the secure_window channel is registered', () {
      final delegate = File('ios/Runner/AppDelegate.swift').readAsStringSync();
      expect(delegate, contains('org.healthflare.app/secure_window'));
    });

    test('the window is covered when the app stops being active', () {
      final scene = File('ios/Runner/SceneDelegate.swift').readAsStringSync();
      expect(scene, contains('sceneWillResignActive'));
      expect(scene, contains('sceneDidBecomeActive'));
    });
  });
}
