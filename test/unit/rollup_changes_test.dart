import 'dart:convert';
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
      final f = parseFragment(
        '115-profile-sheet.fixed.fix.md',
        '- Fixed it.\n',
      );
      expect(f.section, 'Fixed');
      expect(f.bullets, ['- Fixed it.']);
    });

    test('several bullets, and wrapped lines join their bullet', () {
      final f = parseFragment(
        '104-size-cap.security.fix.md',
        '- First line\n  wraps here.\n- Second.\n',
      );
      expect(f.bullets, ['- First line\n  wraps here.', '- Second.']);
    });

    test('ignores blank lines and comments', () {
      final f = parseFragment(
        '1-x.added.addition.md',
        '<!-- one bullet per change -->\n\n- Thing.\n\n',
      );
      expect(f.bullets, ['- Thing.']);
    });

    test('Every changelog fragment says what kind of change it is', () {
      expect(parseFragment('1-x.fixed.fix.md', '- x').kind, ChangeKind.fix);
      expect(
        parseFragment('1-x.added.addition.md', '- x').kind,
        ChangeKind.addition,
      );
      expect(parseFragment('1-x.changed.move.md', '- x').kind, ChangeKind.move);
    });

    for (final bad in [
      'fixed.md',
      '115-sheet.md',
      '115-sheet.bugfix.md',
      'Notes.fixed.fix.md',
      '115-sheet.fixed.fix.txt',
      // Kind missing or unknown.
      '115-sheet.fixed.md',
      '115-sheet.fixed.bug.md',
      '115-sheet.fix.fixed.md',
    ]) {
      test('rejects the file name "$bad"', () {
        expect(() => parseFragment(bad, '- x'), throwsA(isA<FragmentError>()));
      });
    }

    test('rejects text that is not a bullet', () {
      expect(
        () => parseFragment('1-x.fixed.fix.md', 'Fixed a thing.'),
        throwsA(isA<FragmentError>()),
      );
    });

    test('rejects an empty fragment', () {
      expect(
        () => parseFragment('1-x.fixed.fix.md', '\n\n'),
        throwsA(isA<FragmentError>()),
      );
    });
  });

  group('rollUp', () {
    test('appends to the right subsection after existing entries', () {
      final out = rollUp(_changelog, [
        Fragment('104-cap.security.md', 'Security', [
          '- New security line.',
        ], kind: ChangeKind.fix),
      ]);
      expect(
        _section(out, 'Security'),
        '### Security\n- Existing security line.\n- New security line.',
      );
    });

    test('replaces the "Nothing yet" placeholder', () {
      final out = rollUp(_changelog, [
        Fragment('115-sheet.fixed.md', 'Fixed', [
          '- Sheet closes.',
        ], kind: ChangeKind.fix),
      ]);
      expect(_section(out, 'Fixed'), '### Fixed\n- Sheet closes.');
    });

    test('orders fragments by file name, so the result is the same on '
        'every machine', () {
      final out = rollUp(_changelog, [
        Fragment('117-b.fixed.md', 'Fixed', ['- B.'], kind: ChangeKind.fix),
        Fragment('115-a.fixed.md', 'Fixed', ['- A.'], kind: ChangeKind.fix),
      ]);
      expect(_section(out, 'Fixed'), '### Fixed\n- A.\n- B.');
    });

    test('leaves released versions and the header untouched', () {
      final out = rollUp(_changelog, [
        Fragment('1-x.added.md', 'Added', ['- New.'], kind: ChangeKind.fix),
      ]);
      expect(out, startsWith('# Changelog\n\n<!-- header -->\n\n'));
      expect(
        out.substring(out.indexOf('## [1.9.1]')),
        _changelog.substring(_changelog.indexOf('## [1.9.1]')),
      );
    });

    test('keeps every subsection, in Keep a Changelog order', () {
      final out = rollUp(_changelog, [
        Fragment('1-x.removed.md', 'Removed', [
          '- Gone.',
        ], kind: ChangeKind.fix),
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

  group('What\'s new draft', () {
    // Release content the app bundles (assets/whats_new/releases.json, #139).
    // --write drafts the entry for the release; a person writes highlights.
    const released = '''{
  "releases": [
    {
      "version": "1.9.1",
      "date": "2026-09-24",
      "changes": [
        "Old change."
      ]
    }
  ]
}
''';

    List<dynamic> releasesOf(String json) =>
        (jsonDecode(json) as Map<String, dynamic>)['releases'] as List;

    Map<String, dynamic> entryFor(String json, String version) => releasesOf(
      json,
    ).cast<Map<String, dynamic>>().firstWhere((r) => r['version'] == version);

    test('Rolling up a release drafts its What\'s new entry', () {
      final rolled = rollUp(_changelog, [
        Fragment('7-naps.added.addition.md', 'Added', [
          '- Naps can be logged from\n  Quick Log.',
        ], kind: ChangeKind.addition),
      ]);
      final out = draftWhatsNew(
        released,
        version: '1.10.0',
        date: '2026-10-20',
        changes: unreleasedChanges(rolled),
        highlights: true,
        guide: false,
      );

      final top = releasesOf(out).first as Map<String, dynamic>;
      expect(top['version'], '1.10.0');
      expect(top['date'], '2026-10-20');
      expect(top['changes'], [
        'Existing feature.',
        'Naps can be logged from Quick Log.',
        'Existing security line.',
      ]);
      final highlights = top['highlights'] as List;
      expect(highlights, hasLength(1));
      expect((highlights.single as Map)['title'], todo);
      expect(top['guideId'], isNull);
      // The released entry is untouched.
      expect(entryFor(out, '1.9.1'), entryFor(released, '1.9.1'));
      expect(out, endsWith('}\n'));
    });

    test('Rolling up drafts into the release being written', () {
      const pending = '''{
  "releases": [
    {
      "version": "1.10.0",
      "date": null,
      "highlights": [
        {
          "title": "Naps",
          "body": "Log a nap."
        }
      ],
      "changes": [
        "Written by hand."
      ]
    },
    {
      "version": "1.9.1",
      "date": "2026-09-24",
      "changes": []
    }
  ]
}
''';
      expect(pendingVersion(pending), '1.10.0');
      expect(pendingVersion(released), isNull);

      final out = draftWhatsNew(
        pending,
        version: '1.10.0',
        date: '2026-10-20',
        changes: const ['From the changelog.'],
        highlights: true,
        guide: false,
      );
      expect(releasesOf(out), hasLength(2));
      final entry = entryFor(out, '1.10.0');
      expect(entry['date'], '2026-10-20');
      expect(entry['changes'], ['Written by hand.']);
      expect(entry['highlights'], [
        {'title': 'Naps', 'body': 'Log a nap.'},
      ]);
    });

    test('drafting over a version that already has a date is refused', () {
      expect(
        () => draftWhatsNew(
          released,
          version: '1.9.1',
          date: '2026-10-20',
          changes: const [],
          highlights: false,
          guide: false,
        ),
        throwsA(isA<FragmentError>()),
      );
    });

    test('A fix-only release drafts no highlights', () {
      const fixesOnly = '''## [Unreleased]

### Added
- _Nothing yet._

### Fixed
- Old fix.

### Security
- Old security fix.
''';
      final fix = Fragment('1-a.fixed.fix.md', 'Fixed', [
        '- A.',
      ], kind: ChangeKind.fix);
      final addition = Fragment('2-b.added.addition.md', 'Added', [
        '- B.',
      ], kind: ChangeKind.addition);
      expect(needsHighlights(fixesOnly, [fix]), isFalse);
      expect(needsHighlights(fixesOnly, [fix, addition]), isTrue);
      // Entries already in Unreleased outside Fixed and Security count too.
      expect(needsHighlights(_changelog, [fix]), isTrue);

      final out = draftWhatsNew(
        released,
        version: '1.9.2',
        date: '2026-10-20',
        changes: const ['A.'],
        highlights: false,
        guide: false,
      );
      expect(entryFor(out, '1.9.2')['highlights'], isEmpty);
    });

    test('A release with a move drafts a guide placeholder', () {
      final out = draftWhatsNew(
        released,
        version: '1.10.0',
        date: '2026-10-20',
        changes: const ['Meds moved into Care.'],
        highlights: true,
        guide: true,
      );
      expect(entryFor(out, '1.10.0')['guideId'], todo);
    });

    test('a guide already named is kept', () {
      const pending = '''{
  "releases": [
    {
      "version": "1.10.0",
      "date": null,
      "highlights": [],
      "changes": [],
      "guideId": "track-and-care"
    }
  ]
}
''';
      final out = draftWhatsNew(
        pending,
        version: '1.10.0',
        date: '2026-10-20',
        changes: const ['Meds moved into Care.'],
        highlights: true,
        guide: true,
      );
      expect(entryFor(out, '1.10.0')['guideId'], 'track-and-care');
    });
  });

  group('What\'s new check', () {
    String releases(List<Map<String, dynamic>> entries) =>
        jsonEncode({'releases': entries});

    final move = Fragment('141-track-care.changed.move.md', 'Changed', [
      '- Meds moved into Care.',
    ], kind: ChangeKind.move);

    test('reads the version from pubspec.yaml without the build number', () {
      expect(appVersion('name: x\nversion: 1.9.1+13\n'), '1.9.1');
    });

    test('CI fails when the app version has no What\'s new entry', () {
      final problems = checkWhatsNew(
        releasesJson: releases([
          {'version': '1.9.1', 'date': '2026-09-24'},
        ]),
        version: '1.10.0',
        fragments: const [],
      );
      expect(problems, hasLength(1));
      expect(problems.single, contains('1.10.0'));
      expect(problems.single, contains('releases.json'));
    });

    test('A fix-only release may have an empty What\'s new entry', () {
      final problems = checkWhatsNew(
        releasesJson: releases([
          {
            'version': '1.9.2',
            'date': null,
            'highlights': <Object>[],
            'changes': <Object>[],
          },
        ]),
        version: '1.9.2',
        fragments: const [],
      );
      expect(problems, isEmpty);
    });

    test('CI fails when a released entry still has a TODO', () {
      final todoHighlight = {'title': todo, 'body': '$todo: write these'};
      // The app version's entry, dated or not.
      expect(
        checkWhatsNew(
          releasesJson: releases([
            {
              'version': '1.10.0',
              'date': null,
              'highlights': [todoHighlight],
            },
          ]),
          version: '1.10.0',
          fragments: const [],
        ).single,
        contains('1.10.0'),
      );
      // Any dated entry: rolled up for release, pubspec not bumped yet.
      expect(
        checkWhatsNew(
          releasesJson: releases([
            {'version': '1.10.0', 'date': '2026-10-20', 'guideId': todo},
            {'version': '1.9.1', 'date': '2026-09-24'},
          ]),
          version: '1.9.1',
          fragments: const [],
        ).single,
        contains('1.10.0'),
      );
      // The release being written may hold a TODO until it's rolled up.
      expect(
        checkWhatsNew(
          releasesJson: releases([
            {
              'version': '1.10.0',
              'date': null,
              'highlights': [todoHighlight],
            },
            {'version': '1.9.1', 'date': '2026-09-24'},
          ]),
          version: '1.9.1',
          fragments: const [],
        ),
        isEmpty,
      );
    });

    test('CI fails when a move has no guide', () {
      // No release being written at all.
      expect(
        checkWhatsNew(
          releasesJson: releases([
            {'version': '1.9.1', 'date': '2026-09-24'},
          ]),
          version: '1.9.1',
          fragments: [move],
        ).single,
        contains(move.fileName),
      );
      // The release being written names no guide, or only a placeholder.
      for (final guide in [null, todo]) {
        expect(
          checkWhatsNew(
            releasesJson: releases([
              {'version': '1.10.0', 'date': null, 'guideId': guide},
              {'version': '1.9.1', 'date': '2026-09-24'},
            ]),
            version: '1.9.1',
            fragments: [move],
          ).single,
          contains(move.fileName),
        );
      }
      // With a guide, the move passes.
      expect(
        checkWhatsNew(
          releasesJson: releases([
            {'version': '1.10.0', 'date': null, 'guideId': 'track-and-care'},
            {'version': '1.9.1', 'date': '2026-09-24'},
          ]),
          version: '1.9.1',
          fragments: [move],
        ),
        isEmpty,
      );
    });

    test('an unreadable releases.json is a problem, not a crash', () {
      final problems = checkWhatsNew(
        releasesJson: '{"releases": [',
        version: '1.9.1',
        fragments: const [],
      );
      expect(problems.single, contains('releases.json'));
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
        '138-x.changed.addition.md',
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

    test('the real What\'s new content passes the release check', () {
      // Same check the release script runs: pubspec.yaml's version has an
      // entry, nothing released holds a TODO, and every move has a guide.
      final problems = checkWhatsNew(
        releasesJson: File(releasesPath).readAsStringSync(),
        version: appVersion(File('pubspec.yaml').readAsStringSync()),
        fragments: loadFragments(Directory('changes')),
      );
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test('The release script refuses an unfinished What\'s new entry', () {
      final script = File('scripts/release.sh').readAsStringSync();
      expect(script, contains('tool/rollup_changes.dart --check --version'));
    });

    test('The release checklist points to the feature release rules', () {
      final kit = File('docs/release-kit.md').readAsStringSync();
      final checklist = kit.substring(kit.indexOf('## Release checklist'));
      expect(checklist, contains('feature-releases.md'));
    });

    test('rolling up the real CHANGELOG.md keeps it intact', () {
      final real = File('CHANGELOG.md').readAsStringSync();
      expect(rollUp(real, const []), real);
    });
  });
}
