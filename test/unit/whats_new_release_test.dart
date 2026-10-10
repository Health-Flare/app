// What's new in the release process (#140). Spec: docs/feature-releases.md
// ("Sort the change first", "Releasing"). A user-facing release can't go
// out without a What's new entry, and a move can't go out without a guide.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/rollup_changes.dart';
import '../../tool/whats_new_release.dart';

String _releases(List<Map<String, Object?>> entries) =>
    '${const JsonEncoder.withIndent('  ').convert({'releases': entries})}\n';

Map<String, Object?> _entry(String json, String version) =>
    ((jsonDecode(json) as Map)['releases'] as List)
        .cast<Map<String, Object?>>()
        .firstWhere((r) => r['version'] == version);

const _h = {'title': 'Naps in Quick Log', 'body': 'Log a nap from Quick Log.'};

final _shipped = _releases([
  {
    'version': '1.10.0',
    'date': '2026-10-20',
    'highlights': [_h],
    'changes': ['You can log a nap.'],
  },
  {
    'version': '1.9.1',
    'date': '2026-09-24',
    'changes': ['Quick Log reads what you type more accurately.'],
  },
]);

void main() {
  group('fragment kind', () {
    test('fixed and security fragments are fixes', () {
      expect(parseFragment('1-a.fixed.md', '- x').kind, ChangeKind.fix);
      expect(parseFragment('1-a.security.md', '- x').kind, ChangeKind.fix);
    });

    test('added fragments are additions', () {
      expect(parseFragment('1-a.added.md', '- x').kind, ChangeKind.addition);
    });

    for (final section in ['changed', 'removed', 'deprecated']) {
      test('a $section fragment must say what kind it is', () {
        expect(
          () => parseFragment('1-a.$section.md', '- x'),
          throwsA(
            isA<FragmentError>().having(
              (e) => e.message,
              'message',
              contains('<!-- kind: fix -->'),
            ),
          ),
        );
      });
    }

    test('the kind is a comment line, kept out of the changelog', () {
      final f = parseFragment(
        '1-a.changed.md',
        '<!-- kind: addition -->\n- The card shows three.\n',
      );
      expect(f.kind, ChangeKind.addition);
      expect(f.bullets, ['- The card shows three.']);
    });

    test('a move names its guide', () {
      final f = parseFragment(
        '141-sections.changed.md',
        '<!-- kind: move; guide: track-and-care -->\n- Meds moved into Care.\n',
      );
      expect(f.kind, ChangeKind.move);
      expect(f.guide, 'track-and-care');
    });

    test('No move ships without a guide', () {
      expect(
        () => parseFragment('1-a.changed.md', '<!-- kind: move -->\n- x'),
        throwsA(
          isA<FragmentError>().having(
            (e) => e.message,
            'message',
            contains('release guide'),
          ),
        ),
      );
    });

    test('only a move has a guide', () {
      expect(
        () => parseFragment(
          '1-a.fixed.md',
          '<!-- kind: fix; guide: something -->\n- x',
        ),
        throwsA(isA<FragmentError>()),
      );
    });

    for (final bad in [
      '<!-- kind: moved -->',
      '<!-- kind: move; guide: Track And Care -->',
      '<!-- kind -->',
      '<!-- Kind: tweak -->',
    ]) {
      test('rejects "$bad" with the right syntax in the message', () {
        expect(
          () => parseFragment('1-a.changed.md', '$bad\n- x'),
          throwsA(
            isA<FragmentError>().having(
              (e) => e.message,
              'message',
              contains('<!-- kind: move; guide: <guide-id> -->'),
            ),
          ),
        );
      });
    }

    test('other comments are still just comments', () {
      final f = parseFragment(
        '1-a.added.md',
        '<!-- Track and Care (#141) moves this. -->\n- x',
      );
      expect(f.kind, ChangeKind.addition);
    });

    test('kind given twice is an error', () {
      expect(
        () => parseFragment(
          '1-a.changed.md',
          '<!-- kind: fix -->\n<!-- kind: addition -->\n- x',
        ),
        throwsA(isA<FragmentError>()),
      );
    });
  });

  group('versions', () {
    test('release versions are X.Y.Z', () {
      expect(isReleaseVersion('1.10.0'), isTrue);
      expect(isReleaseVersion('1.10'), isFalse);
      expect(isReleaseVersion('1.10.0+14'), isFalse);
      expect(isReleaseVersion('v1.10.0'), isFalse);
    });

    test('reads the version from pubspec.yaml without the build number', () {
      expect(
        readPubspecVersion('name: health_flare\nversion: 1.9.1+13\n'),
        '1.9.1',
      );
    });
  });

  group('changesFromUnreleased', () {
    const changelog = '''# Changelog

<!-- - Rename `## [Unreleased]` -->

## [Unreleased]

### Added
- **Weather tracking**: captured at log time.
- Settings shows the `App version`, e.g. "1.9.1".

### Changed
- _Nothing yet._

### Fixed
- A long fix that
  wraps onto a second line.

## [1.9.1] - 2026-09-24

### Added
- Old thing.
''';

    test('one plain line per bullet, in changelog order', () {
      expect(changesFromUnreleased(changelog), [
        'Weather tracking: captured at log time.',
        'Settings shows the App version, e.g. "1.9.1".',
        'A long fix that wraps onto a second line.',
      ]);
    });
  });

  group('draftWhatsNew', () {
    test('adds a draft entry at the top for a new version', () {
      final out = draftWhatsNew(
        _shipped,
        version: '1.11.0',
        changes: ['A change.'],
        guides: const {},
      );
      final releases = (jsonDecode(out) as Map)['releases'] as List;
      expect((releases.first as Map)['version'], '1.11.0');
      expect(_entry(out, '1.11.0'), {
        'version': '1.11.0',
        'date': null,
        'draft': true,
        'highlights': <Object?>[],
        'changes': ['A change.'],
      });
    });

    test('keeps highlights already written, replaces changes, marks it a '
        'draft to review again', () {
      final out = draftWhatsNew(
        _shipped,
        version: '1.10.0',
        changes: ['New list.'],
        guides: const {},
      );
      final e = _entry(out, '1.10.0');
      expect(e['highlights'], [_h]);
      expect(e['changes'], ['New list.']);
      expect(e['draft'], isTrue);
    });

    test('a release with a move lists its guide', () {
      final out = draftWhatsNew(
        _shipped,
        version: '1.11.0',
        changes: ['Meds moved into Care.'],
        guides: {'track-and-care'},
      );
      expect(_entry(out, '1.11.0')['guideId'], 'track-and-care');
    });

    test('one release has one guide: two different guides is an error', () {
      expect(
        () => draftWhatsNew(
          _shipped,
          version: '1.11.0',
          changes: ['x'],
          guides: {'track-and-care', 'accessibility'},
        ),
        throwsA(
          isA<ReleaseError>().having(
            (e) => e.message,
            'message',
            contains('one guide'),
          ),
        ),
      );
    });

    test('other releases are untouched, and the file stays in the same '
        'format', () {
      final out = draftWhatsNew(
        _shipped,
        version: '1.11.0',
        changes: ['x'],
        guides: const {},
      );
      expect(_entry(out, '1.9.1'), _entry(_shipped, '1.9.1'));
      expect(out, endsWith('}\n'));
    });

    test('redrafting the real file changes only the drafted entry', () {
      final real = File(releasesJsonPath).readAsStringSync();
      final versions = [
        for (final r in (jsonDecode(real) as Map)['releases'] as List)
          (r as Map)['version'] as String,
      ];
      final out = draftWhatsNew(
        real,
        version: '99.0.0',
        changes: ['x'],
        guides: const {},
      );
      // Same text below the new entry: no reformatting of the rest.
      expect(
        out.substring(out.indexOf('"version": "${versions.first}"')),
        real.substring(real.indexOf('"version": "${versions.first}"')),
      );
    });
  });

  group('validateReleases', () {
    test('a good file has no errors', () {
      expect(validateReleases(_shipped, pubspecVersion: '1.10.0'), isEmpty);
    });

    test('The pubspec version must have a What\'s new entry', () {
      expect(validateReleases(_shipped, pubspecVersion: '1.11.0'), [
        contains('1.11.0 has no entry'),
      ]);
    });

    test('a fix-only release may have no highlights', () {
      expect(validateReleases(_shipped, pubspecVersion: '1.9.1'), isEmpty);
    });

    test('a draft for the next version is fine on main', () {
      final drafted = draftWhatsNew(
        _shipped,
        version: '1.11.0',
        changes: ['x'],
        guides: const {},
      );
      expect(validateReleases(drafted, pubspecVersion: '1.10.0'), isEmpty);
    });

    test('a draft for the version being shipped is not', () {
      final drafted = draftWhatsNew(
        _shipped,
        version: '1.10.0',
        changes: ['x'],
        guides: const {},
      );
      expect(
        validateReleases(drafted, pubspecVersion: '1.10.0'),
        contains(contains('1.10.0 is still a draft')),
      );
    });

    test('a shipped version needs a date', () {
      final undated = _releases([
        {
          'version': '1.10.0',
          'date': null,
          'changes': ['x'],
        },
      ]);
      expect(validateReleases(undated, pubspecVersion: '1.10.0'), [
        contains('1.10.0 has no date'),
      ]);
    });

    final cases = <String, List<Map<String, Object?>>>{
      'more than 4 highlights': [
        {
          'version': '1.0.0',
          'date': '2026-01-01',
          'highlights': List.filled(5, _h),
        },
      ],
      'an empty highlight title': [
        {
          'version': '1.0.0',
          'date': '2026-01-01',
          'highlights': [
            {'title': '', 'body': 'x'},
          ],
        },
      ],
      'a misspelt key': [
        {'version': '1.0.0', 'date': '2026-01-01', 'highlight': <Object?>[]},
      ],
      'a bad version': [
        {'version': '1.0', 'date': '2026-01-01'},
      ],
      'a bad date': [
        {'version': '1.0.0', 'date': '1 Jan 2026'},
      ],
      'a duplicate version': [
        {'version': '1.0.0', 'date': '2026-01-01'},
        {'version': '1.0.0', 'date': '2026-01-01'},
      ],
      'oldest first': [
        {'version': '1.0.0', 'date': '2026-01-01'},
        {'version': '1.1.0', 'date': '2026-02-01'},
      ],
      'a bad guide id': [
        {'version': '1.0.0', 'date': '2026-01-01', 'guideId': 'Track and Care'},
      ],
    };
    cases.forEach((name, entries) {
      test('rejects $name', () {
        expect(validateReleases(_releases(entries)), isNotEmpty);
      });
    });

    test('rejects text that is not JSON, without throwing', () {
      expect(validateReleases('{ nope'), [contains('not valid JSON')]);
    });
  });

  group('stampRelease', () {
    test('dates a ready entry', () {
      final ready = _releases([
        {
          'version': '1.11.0',
          'date': null,
          'changes': ['x'],
        },
        ..._shippedEntries(),
      ]);
      final out = stampRelease(ready, '1.11.0', '2026-11-01');
      expect(_entry(out, '1.11.0')['date'], '2026-11-01');
    });

    test('refuses a version with no entry, and says what to run', () {
      expect(
        () => stampRelease(_shipped, '1.11.0', '2026-11-01'),
        throwsA(
          isA<ReleaseError>().having(
            (e) => e.message,
            'message',
            contains('--write --version 1.11.0'),
          ),
        ),
      );
    });

    test('refuses a draft, and says to write the highlights', () {
      final drafted = draftWhatsNew(
        _shipped,
        version: '1.11.0',
        changes: ['x'],
        guides: const {},
      );
      expect(
        () => stampRelease(drafted, '1.11.0', '2026-11-01'),
        throwsA(
          isA<ReleaseError>().having(
            (e) => e.message,
            'message',
            contains('highlights'),
          ),
        ),
      );
    });

    test('refuses a bad date', () {
      final ready = _releases([
        {'version': '1.11.0', 'date': null},
      ]);
      expect(
        () => stampRelease(ready, '1.11.0', '11/01/2026'),
        throwsA(isA<ReleaseError>()),
      );
    });
  });

  group('the real repo', () {
    test('releases.json is valid and the pubspec version is ready to ship', () {
      // Same check CI runs: a release with no What's new entry, a draft left
      // in, or a malformed entry fails here.
      final errors = validateReleases(
        File(releasesJsonPath).readAsStringSync(),
        pubspecVersion: readPubspecVersion(
          File('pubspec.yaml').readAsStringSync(),
        ),
      );
      expect(errors, isEmpty);
    });

    test('every fragment says what kind of change it is', () {
      expect(() => loadFragments(Directory('changes')), returnsNormally);
    });
  });
}

List<Map<String, Object?>> _shippedEntries() =>
    ((jsonDecode(_shipped) as Map)['releases'] as List)
        .cast<Map<String, Object?>>();
