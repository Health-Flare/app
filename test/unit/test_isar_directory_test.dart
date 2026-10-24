import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Issue #208: tests that opened Isar with an empty directory wrote their
// databases into the repo root and never removed them. Every test that
// opens Isar must use `isarTestDir` from test/helpers/isar_test_dir.dart.

void main() {
  test('no test opens Isar in the working directory', () {
    // Built from parts so this file doesn't match itself.
    const empty = "''";
    final pattern = RegExp(r'directory\s*[:=]\s*' + RegExp.escape(empty));

    final offenders = <String>[];
    for (final entity in Directory('test').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].trimLeft().startsWith('//')) continue;
        if (pattern.hasMatch(lines[i])) {
          offenders.add('${entity.path}:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Use `directory: isarTestDir` (test/helpers/isar_test_dir.dart) '
          'so the database is deleted after the test file.',
    );
  });

  test('files that use isarTestDir set up the directory', () {
    final missing = <String>[];
    for (final entity in Directory('test').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('isar_test_dir.dart')) continue;
      final source = entity.readAsStringSync();
      if (source.contains('isarTestDir') &&
          !source.contains('useIsarTestDirectory()')) {
        missing.add(entity.path);
      }
    }
    expect(missing, isEmpty);
  });
}
