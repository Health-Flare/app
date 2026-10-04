import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/data/services/weather_service.dart';

// Privacy copy must be checkably true (see #98). Health Flare's records are
// included in the phone's own backup, and opt-in weather sends an approximate
// location to Open-Meteo. These tests fail if copy that says otherwise comes
// back in the app, the OS permission prompts, or the privacy policy.

/// Phrases that were false and must not return.
final _bannedClaims = <RegExp>[
  RegExp(r'never leaves? (your|this) (device|phone)', caseSensitive: false),
  RegExp(r'stays on (your|this) device', caseSensitive: false),
  RegExp(r'never (stored or )?transmitted', caseSensitive: false),
  RegExp(r'never shared', caseSensitive: false),
  RegExp(r'no network calls', caseSensitive: false),
  RegExp(r'does not transmit data', caseSensitive: false),
  RegExp(r'nothing is uploaded', caseSensitive: false),
  RegExp(r'no data (ever )?leaves', caseSensitive: false),
  RegExp(r'not collect,? transmit', caseSensitive: false),
  RegExp(r'no cloud backup', caseSensitive: false),
];

/// User-facing copy surfaces: app UI, OS permission prompts, the policy.
List<File> _copyFiles() => [
  ...Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart')),
  File('ios/Runner/Info.plist'),
  File('macos/Runner/Info.plist'),
  File('docs/privacy-policy.md'),
  File('docs/privacy-policy.html'),
  File('SECURITY.md'),
];

/// Drops Dart comments so explanatory comments can quote the old wording.
String _withoutDartComments(String source) => source
    .split('\n')
    .where((line) => !line.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  group('privacy copy', () {
    test('no surface repeats a claim the app does not keep', () {
      final hits = <String>[];
      for (final file in _copyFiles()) {
        var text = file.readAsStringSync();
        if (file.path.endsWith('.dart')) text = _withoutDartComments(text);
        // Join adjacent Dart string literals so a phrase split across
        // lines ('never ' 'shared') is still caught.
        final joined = text.replaceAll(RegExp(r"'\s*\n\s*'"), '');
        for (final claim in _bannedClaims) {
          if (claim.hasMatch(joined)) {
            hits.add('${file.path}: ${claim.pattern}');
          }
        }
      }
      expect(hits, isEmpty);
    });

    test('the privacy policy explains phone backups', () {
      for (final path in [
        'docs/privacy-policy.md',
        'docs/privacy-policy.html',
      ]) {
        final policy = File(path).readAsStringSync();
        expect(policy, contains('Phone backups'), reason: path);
        expect(policy, contains('Advanced Data Protection'), reason: path);
        expect(policy, contains('screen lock'), reason: path);
      }
    });

    test('the privacy policy explains the weather request', () {
      for (final path in [
        'docs/privacy-policy.md',
        'docs/privacy-policy.html',
      ]) {
        final policy = File(path).readAsStringSync();
        expect(policy, contains('Open-Meteo'), reason: path);
        expect(policy, contains('approximate location'), reason: path);
      }
    });

    test('the iOS location prompt names Open-Meteo', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      final prompts = RegExp(
        r'<key>NSLocation\w*UsageDescription</key>\s*<string>([^<]*)</string>',
      ).allMatches(plist).map((m) => m.group(1)!).toList();
      expect(prompts, isNotEmpty);
      for (final prompt in prompts) {
        expect(prompt, contains('Open-Meteo'));
        expect(prompt, contains('approximate location'));
      }
    });

    test('the md and html policies have the same sections', () {
      final mdHeadings = RegExp(r'^## (.+)$', multiLine: true)
          .allMatches(File('docs/privacy-policy.md').readAsStringSync())
          .map((m) => m.group(1)!)
          .where((h) => h != 'The short version') // rendered as a summary box
          .toList();
      final htmlHeadings = RegExp(r'<h2>([^<]+)</h2>')
          .allMatches(File('docs/privacy-policy.html').readAsStringSync())
          .map((m) => m.group(1)!.replaceAll('&quot;', '"'))
          .toList();
      expect(htmlHeadings, mdHeadings);
    });
  });

  group('weather location precision', () {
    test('coordinates are rounded to about 1 km before sending', () {
      expect(roundCoordinate(43.651070), '43.65');
      expect(roundCoordinate(-79.347015), '-79.35');
      expect(roundCoordinate(0.004), '0.00');
    });

    test('the request uses the rounded values', () {
      final source = File(
        'lib/data/services/weather_service.dart',
      ).readAsStringSync();
      expect(
        source,
        contains(r'latitude=${roundCoordinate(position.latitude)}'),
      );
      expect(
        source,
        contains(r'longitude=${roundCoordinate(position.longitude)}'),
      );
      expect(source, isNot(contains(r'latitude=${position.latitude}')));
    });
  });
}
