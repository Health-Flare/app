import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/rollup_changes.dart';

// Changelog fragments: each PR adds a file under changes/ instead of a line
// in CHANGELOG.md, so open PRs stop conflicting on it after every merge.
// These pin the roll-up done at release time.

const _changelog = '''# Changelog

<!-- header -->

## [Unreleased]

### Added
- Existing feature.

### Changed
- _Nothing yet._

### Deprecated
- _Nothing yet._

### Removed
- _Nothing yet._

### Fixed
- _Nothing yet._

### Security
- Existing security line.

## [1.9.1] - 2026-09-24

### Fixed
- Old fix.
''';

String _section(String changelog, String name) {
  final start = changelog.indexOf(
    '### $name',
    changelog.indexOf('[Unreleased]'),
  );
  final end = changelog.indexOf(RegExp(r'\n(### |## \[)'), start + 1);
  return changelog.substring(start, end).trim();
}

void main() {
  group('parseFragment', () {
    test('section comes from the file name', () {
      final f = parseFragment('115-profile-sheet.fixed.md', '- Fixed it.\n');
      expect(f.section, 'Fixed');
      expect(f.bullets, ['- Fixed it.']);
    });

    test('several bullets, and wrapped lines join their bullet', () {
      final f = parseFragment(
        '104-size-cap.security.md',
        '- First line\n  wraps here.\n- Second.\n',
      );
      expect(f.bullets, ['- First line\n  wraps here.', '- Second.']);
    });

    test('ignores blank lines and comments', () {
      final f = parseFragment(
        '1-x.added.md',
        '<!-- one bullet per change -->\n\n- Thing.\n\n',
      );
      expect(f.bullets, ['- Thing.']);
    });

    for (final bad in [
      'fixed.md',
      '115-sheet.md',
      '115-sheet.bugfix.md',
      'Notes.fixed.md',
      '115-sheet.fixed.txt',
    ]) {
      test('rejects the file name "$bad"', () {
        expect(() => parseFragment(bad, '- x'), throwsA(isA<FragmentError>()));
      });
    }

    test('rejects text that is not a bullet', () {
      expect(
        () => parseFragment('1-x.fixed.md', 'Fixed a thing.'),
        throwsA(isA<FragmentError>()),
      );
    });

    test('rejects an empty fragment', () {
      expect(
        () => parseFragment('1-x.fixed.md', '\n\n'),
        throwsA(isA<FragmentError>()),
      );
    });
  });

  group('rollUp', () {
    test('appends to the right subsection after existing entries', () {
      final out = rollUp(_changelog, [
        Fragment('104-cap.security.md', 'Security', ['- New security line.']),
      ]);
      expect(
        _section(out, 'Security'),
        '### Security\n- Existing security line.\n- New security line.',
      );
    });

    test('replaces the "Nothing yet" placeholder', () {
      final out = rollUp(_changelog, [
        Fragment('115-sheet.fixed.md', 'Fixed', ['- Sheet closes.']),
      ]);
      expect(_section(out, 'Fixed'), '### Fixed\n- Sheet closes.');
    });

    test('orders fragments by file name, so the result is the same on '
        'every machine', () {
      final out = rollUp(_changelog, [
        Fragment('117-b.fixed.md', 'Fixed', ['- B.']),
        Fragment('115-a.fixed.md', 'Fixed', ['- A.']),
      ]);
      expect(_section(out, 'Fixed'), '### Fixed\n- A.\n- B.');
    });

    test('leaves released versions and the header untouched', () {
      final out = rollUp(_changelog, [
        Fragment('1-x.added.md', 'Added', ['- New.']),
      ]);
      expect(out, startsWith('# Changelog\n\n<!-- header -->\n\n'));
      expect(
        out.substring(out.indexOf('## [1.9.1]')),
        _changelog.substring(_changelog.indexOf('## [1.9.1]')),
      );
    });

    test('keeps every subsection, in Keep a Changelog order', () {
      final out = rollUp(_changelog, [
        Fragment('1-x.removed.md', 'Removed', ['- Gone.']),
      ]);
      final unreleased = out.substring(
        out.indexOf('## [Unreleased]'),
        out.indexOf('## [1.9.1]'),
      );
      final headings = RegExp(
        r'^### (\w+)',
        multiLine: true,
      ).allMatches(unreleased).map((m) => m.group(1)).toList();
      expect(headings, sections);
    });

    test('with no fragments, Unreleased is unchanged', () {
      expect(rollUp(_changelog, const []), _changelog);
    });
  });

  group('the real repo', () {
    test('preview shows the Unreleased section, not the header comment '
        'that mentions it', () {
      const changelog = '''# Changelog

<!--
- Rename `## [Unreleased]` to `## [X.Y.Z] - YYYY-MM-DD`.
-->

## [Unreleased]

### Added
- New thing.

## [1.0.0] - 2026-01-01

### Added
- Old thing.
''';
      final preview = unreleasedSection(changelog);
      expect(preview, startsWith('## [Unreleased]\n'));
      expect(preview, contains('- New thing.'));
      expect(preview, isNot(contains('Rename')));
      expect(preview, isNot(contains('Old thing.')));
    });

    test('fragment comments are not rolled into the changelog', () {
      final f = parseFragment(
        '138-x.changed.md',
        '<!-- Track and Care (#141) moves this. Edit this bullet then. -->\n'
            '- The dashboard has an "All appointments" link.\n',
      );
      expect(f.bullets, ['- The dashboard has an "All appointments" link.']);
    });

    test('every fragment in changes/ is valid', () {
      // Same check CI runs: a malformed fragment fails here, in the PR that
      // adds it, not at release time.
      expect(() => loadFragments(Directory('changes')), returnsNormally);
    });

    test('rolling up the real CHANGELOG.md keeps it intact', () {
      final real = File('CHANGELOG.md').readAsStringSync();
      expect(rollUp(real, const []), real);
    });
  });
}
