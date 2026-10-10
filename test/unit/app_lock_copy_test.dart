import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// docs/features/app-lock.feature, "Lock copy never claims encryption"
// (#100). The lock is a screen in front of the app; the database on the
// phone is stored as before. Copy must not suggest otherwise.

final _overclaims = <RegExp>[
  RegExp(r'\bencrypts\b', caseSensitive: false),
  RegExp(r'\bencrypted\b', caseSensitive: false),
  RegExp(r'\bsecures?\b', caseSensitive: false),
  RegExp(r'\bprotects?\b', caseSensitive: false),
  RegExp(r'\bsafe from\b', caseSensitive: false),
];

const _lockCopyFiles = [
  'lib/features/app_lock/app_lock_gate.dart',
  'lib/features/settings/widgets/privacy_settings_section.dart',
  'lib/features/onboarding/widgets/app_lock_offer.dart',
  'lib/core/providers/app_lock_provider.dart',
  'ios/Runner/Info.plist',
];

/// Dart string literals only, so explanatory comments can say what
/// the lock does not do.
Iterable<String> _strings(String path) sync* {
  final text = File(path).readAsStringSync();
  if (!path.endsWith('.dart')) {
    yield text;
    return;
  }
  final code = text
      .split('\n')
      .where((l) => !l.trimLeft().startsWith('//'))
      .join('\n');
  final quoted = [
    RegExp(r"'((?:[^'\\]|\\.)*)'"),
    RegExp(r'"((?:[^"\\]|\\.)*)"'),
  ];
  for (final re in quoted) {
    for (final m in re.allMatches(code)) {
      yield m.group(1)!;
    }
  }
}

void main() {
  test('no app lock copy claims to encrypt or protect the data', () {
    final hits = <String>[];
    for (final path in _lockCopyFiles) {
      for (final s in _strings(path)) {
        for (final claim in _overclaims) {
          if (claim.hasMatch(s)) hits.add('$path: "$s"');
        }
      }
    }
    expect(hits, isEmpty);
  });
}
