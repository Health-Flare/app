// #165: Track and Care ships in 1.10.0; the flag and the old bar go.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/navigation/bar_layout.dart';

void main() {
  test('the default bar is v2, with no flag to turn it off', () {
    expect(kCurrentBarVersion, 2);
  });

  test('nothing in lib reads TRACK_AND_CARE or trackAndCare', () {
    final hits = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final s = f.readAsStringSync();
      if (s.contains('TRACK_AND_CARE') ||
          RegExp(r'\btrackAndCare\b').hasMatch(s)) {
        hits.add(f.path);
      }
    }
    expect(hits, isEmpty);
  });

  test('the old six-item bar is gone', () {
    final shell = File(
      'lib/features/shell/app_shell.dart',
    ).readAsStringSync();
    expect(shell, isNot(contains('_LegacyBar')));
  });
}
