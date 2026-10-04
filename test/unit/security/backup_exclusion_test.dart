import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/security/backup_exclusion.dart';

// The health database is not encrypted at rest, so it must stay out of
// iCloud and Google cloud backups. See docs/features/datastore.feature,
// "The database is not included in cloud backups".

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(backupExclusionChannel, null);
  });

  group('excludeFromBackup', () {
    test('on iOS, asks the native side to exclude the path', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(backupExclusionChannel, (call) async {
        calls.add(call);
        return true;
      });

      final ok = await excludeFromBackup('/docs');

      expect(ok, isTrue);
      expect(calls, hasLength(1));
      expect(calls.single.method, 'excludeFromBackup');
      expect(calls.single.arguments, {'path': '/docs'});
    });

    test('on Android, does nothing (the manifest handles it)', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      var called = false;
      messenger.setMockMethodCallHandler(backupExclusionChannel, (call) async {
        called = true;
        return true;
      });

      expect(await excludeFromBackup('/docs'), isFalse);
      expect(called, isFalse);
    });

    test('a native failure does not throw', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      messenger.setMockMethodCallHandler(backupExclusionChannel, (call) async {
        throw PlatformException(code: 'EXCLUDE_FROM_BACKUP_FAILED');
      });

      expect(await excludeFromBackup('/docs'), isFalse);
    });

    test('a missing native handler does not throw', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(await excludeFromBackup('/docs'), isFalse);
    });
  });

  group('Android backup configuration', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    test('turns off backup for Android 11 and below', () {
      expect(manifest, contains('android:allowBackup="false"'));
      expect(manifest, contains('android:fullBackupContent="false"'));
    });

    test('points Android 12+ at the extraction rules', () {
      expect(
        manifest,
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
      );
    });

    test('extraction rules exclude every domain from cloud backup', () {
      final rules = File(
        'android/app/src/main/res/xml/data_extraction_rules.xml',
      ).readAsStringSync();
      final cloud = RegExp(
        r'<cloud-backup>(.*?)</cloud-backup>',
        dotAll: true,
      ).firstMatch(rules)?.group(1);

      expect(cloud, isNotNull);
      for (final domain in [
        'root',
        'file',
        'database',
        'sharedpref',
        'external',
      ]) {
        expect(
          cloud,
          contains('<exclude domain="$domain" path="." />'),
          reason: '$domain must be excluded from cloud backup',
        );
      }
      expect(cloud, isNot(contains('<include')));
    });
  });

  test('iOS registers the native channel', () {
    final delegate = File('ios/Runner/AppDelegate.swift').readAsStringSync();
    expect(delegate, contains('org.healthflare.app/backup_exclusion'));
    expect(delegate, contains('isExcludedFromBackup = true'));
  });
}
