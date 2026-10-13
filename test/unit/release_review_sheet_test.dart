// tool/release_review_sheet.dart (#171): sorts the review shots and builds
// the contact sheet.
import 'package:flutter_test/flutter_test.dart';

import '../../tool/release_review_sheet.dart';

void main() {
  group('parseShot', () {
    test('variant, step number and step name from the driver name', () {
      final s = parseShot('dark-200__07_show_me_outlined')!;
      expect(s.variant, 'dark-200');
      expect(s.step, 7);
      expect(s.name, 'show_me_outlined');
      expect(s.fileName, '07_show_me_outlined.png');
    });

    test('anything else is not a review shot', () {
      expect(parseShot('track_and_care_01_dashboard'), isNull);
      expect(parseShot('light-100__intro'), isNull);
      expect(parseShot('purple-100__01_x'), isNull);
    });
  });

  test('variants are always shown in the same order', () {
    expect(reviewVariants, ['light-100', 'dark-100', 'light-200', 'dark-200']);
  });

  group('contactSheet', () {
    final shots = {
      'iphone': [
        parseShot('dark-100__01_guide_card')!,
        parseShot('light-100__01_guide_card')!,
        parseShot('light-100__02_guide_four_sections')!,
      ],
      'android': [parseShot('light-100__01_guide_card')!],
    };
    final html = contactSheet(shots, title: 'Health Flare 1.10.0 review');

    test('one row per step, named in plain words', () {
      expect(html, contains('<title>Health Flare 1.10.0 review</title>'));
      expect(html, contains('01 · Guide card'));
      expect(html, contains('02 · Guide four sections'));
      expect(
        html.indexOf('01 · Guide card'),
        lessThan(html.indexOf('02 · Guide four sections')),
      );
    });

    test('variants side by side, in order, linking the sorted files', () {
      final row = html.substring(
        html.indexOf('01 · Guide card'),
        html.indexOf('02 · Guide four sections'),
      );
      expect(
        row.indexOf('iphone/light-100/01_guide_card.png'),
        lessThan(row.indexOf('iphone/dark-100/01_guide_card.png')),
      );
      expect(row, contains('android/light-100/01_guide_card.png'));
    });

    test('a missing shot says so instead of leaving a gap', () {
      final row = html.substring(html.indexOf('02 · Guide four sections'));
      expect(row, contains('missing'));
    });

    test('a device with no shots at all is named, with why', () {
      final empty = contactSheet({
        'iphone': shots['iphone']!,
        'android': [],
      }, title: 't');
      expect(empty, contains('android: no screenshots'));
    });
  });
}
