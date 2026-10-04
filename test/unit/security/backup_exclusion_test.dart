import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/security/backup_exclusion.dart';

// Pre-upgrade safety copies (snapshots/) stay out of phone backups; the
// database itself stays in (#96, #97, #99). See docs/features/datastore.feature,
// "Safety copies are not in phone backups" (#110).

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

      final ok = await excludeFromBackup('/docs/snapshots');

      expect(ok, isTrue);
      expect(calls, hasLength(1));
      expect(calls.single.method, 'excludeFromBackup');
      expect(calls.single.arguments, {'path': '/docs/snapshots'});
    });

    test('on Android, does nothing (the backup rules handle it)', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      var called = false;
      messenger.setMockMethodCallHandler(backupExclusionChannel, (call) async {
        called = true;
        return true;
      });

      expect(await excludeFromBackup('/docs/snapshots'), isFalse);
      expect(called, isFalse);
    });

    test('a native failure does not throw', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      messenger.setMockMethodCallHandler(backupExclusionChannel, (call) async {
        throw PlatformException(code: 'EXCLUDE_FROM_BACKUP_FAILED');
      });

      expect(await excludeFromBackup('/docs/snapshots'), isFalse);
    });

    test('a missing native handler does not throw', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(await excludeFromBackup('/docs/snapshots'), isFalse);
    });
  });

  group('Android backup rules', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    // path_provider's documents directory on Android is
    // Context.getDir("flutter"), i.e. <data dir>/app_flutter.
    const snapshotsRule =
        '<exclude domain="root" path="app_flutter/snapshots" />';

    test('backup stays on', () {
      expect(manifest, isNot(contains('android:allowBackup="false"')));
      expect(manifest, isNot(contains('android:fullBackupContent="false"')));
    });

    test('points Android 11 and below at the full backup rules', () {
      expect(
        manifest,
        contains('android:fullBackupContent="@xml/backup_rules"'),
      );
    });

    test('points Android 12+ at the extraction rules', () {
      expect(
        manifest,
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
      );
    });

    test('Android 11 and below: excludes only the snapshots folder', () {
      final rules = File(
        'android/app/src/main/res/xml/backup_rules.xml',
      ).readAsStringSync();
      final body = RegExp(
        r'<full-backup-content>(.*?)</full-backup-content>',
        dotAll: true,
      ).firstMatch(rules)?.group(1);

      expect(body, isNotNull);
      expect(_rules(body!), [snapshotsRule]);
    });

    for (final section in ['cloud-backup', 'device-transfer']) {
      test('Android 12+ $section: excludes only the snapshots folder', () {
        final rules = File(
          'android/app/src/main/res/xml/data_extraction_rules.xml',
        ).readAsStringSync();
        final body = RegExp(
          '<$section>(.*?)</$section>',
          dotAll: true,
        ).firstMatch(rules)?.group(1);

        expect(body, isNotNull, reason: '$section section missing');
        expect(_rules(body!), [snapshotsRule]);
      });
    }
  });

  test('iOS registers the native channel', () {
    final delegate = File('ios/Runner/AppDelegate.swift').readAsStringSync();
    expect(delegate, contains('org.healthflare.app/backup_exclusion'));
    expect(delegate, contains('isExcludedFromBackup = true'));
  });
}

/// Every `include` and `exclude` element in [xml], comments
/// stripped, whitespace normalised.
List<String> _rules(String xml) {
  final noComments = xml.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
  return RegExp(r'<(include|exclude)\b[^>]*/>')
      .allMatches(noComments)
      .map((m) => m.group(0)!.replaceAll(RegExp(r'\s+'), ' '))
      .toList();
}
