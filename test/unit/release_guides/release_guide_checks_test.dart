// Release checks for guides (#145): a guide named in releases.json or in a
// move fragment must exist. Spec: release-guides.feature, "Every change to
// the default bar comes with a guide" ("the release cannot be cut without
// it").
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/rollup_changes.dart';
import '../../../tool/whats_new_release.dart';

String _releases(String? guide) => jsonEncode({
  'releases': [
    {
      'version': '1.10.0',
      'date': '2026-11-01',
      'highlights': <Object>[],
      'changes': ['Something.'],
      'guideId': ?guide,
    },
  ],
});

void main() {
  const known = {'track-and-care'};

  test('a guide that exists passes', () {
    expect(
      validateReleases(_releases('track-and-care'), knownGuides: known),
      isEmpty,
    );
  });

  test('a guide that does not exist fails, and says where guides live', () {
    final errors = validateReleases(
      _releases('accessibility'),
      knownGuides: known,
    );
    expect(errors, hasLength(1));
    expect(errors.single, contains('"accessibility"'));
    expect(errors.single, contains('tool/known_guide_ids.txt'));
  });

  test('a move fragment naming a guide that does not exist fails', () {
    final f = parseFragment(
      'x.changed.md',
      '<!-- kind: move; guide: accessibility -->\n- Text size moved.\n',
    );
    final errors = checkFragmentGuides([f], known);
    expect(errors.single, contains('x.changed.md'));
    expect(errors.single, contains('accessibility'));
  });

  test('known guides are read from tool/known_guide_ids.txt', () {
    expect(
      readKnownGuides(File('tool/known_guide_ids.txt').readAsStringSync()),
      contains('track-and-care'),
    );
  });
}
