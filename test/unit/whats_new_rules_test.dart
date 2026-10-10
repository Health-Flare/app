// What's new card rules (#139). Spec: docs/features/whats-new.feature.
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/features/whats_new/models/release_note.dart';
import 'package:health_flare/features/whats_new/whats_new_rules.dart';

const _h = [ReleaseHighlight(title: 'New thing', body: 'It does a thing.')];

final _releases = [
  const ReleaseNote(version: '1.13.0', highlights: _h), // not shipped yet
  const ReleaseNote(version: '1.12.0', highlights: _h),
  const ReleaseNote(version: '1.11.0'), // fixes only
  const ReleaseNote(version: '1.10.0', highlights: _h),
  const ReleaseNote(version: '1.9.1'),
];

List<String> _versions(List<ReleaseNote> r) => [for (final n in r) n.version];

void main() {
  group('compareVersions', () {
    test('compares each part as a number', () {
      expect(compareVersions('1.10.0', '1.9.1'), greaterThan(0));
      expect(compareVersions('1.9.1', '1.10.0'), lessThan(0));
      expect(compareVersions('2.0.0', '1.99.99'), greaterThan(0));
      expect(compareVersions('1.10.0', '1.10.0'), 0);
    });

    test('ignores build numbers and missing parts', () {
      expect(compareVersions('1.10.0+14', '1.10.0'), 0);
      expect(compareVersions('1.10', '1.10.0'), 0);
    });
  });

  group('releasesUpTo', () {
    test('lists shipped releases newest first, never a future one', () {
      expect(_versions(releasesUpTo(_releases.reversed.toList(), '1.12.0')), [
        '1.12.0',
        '1.11.0',
        '1.10.0',
        '1.9.1',
      ]);
    });
  });

  group('cardReleases', () {
    test('An update with highlights shows one quiet card', () {
      expect(
        _versions(
          cardReleases(
            releases: _releases,
            lastSeen: '1.9.1',
            installed: '1.10.0',
          ),
        ),
        ['1.10.0'],
      );
    });

    test('A bug-fix-only update shows nothing', () {
      expect(
        cardReleases(
          releases: _releases,
          lastSeen: '1.10.0',
          installed: '1.11.0',
        ),
        isEmpty,
      );
    });

    test('Updating past several versions shows one card', () {
      expect(
        _versions(
          cardReleases(
            releases: _releases,
            lastSeen: '1.9.1',
            installed: '1.12.0',
          ),
        ),
        ['1.12.0', '1.10.0'],
      );
    });

    test('Going back to an older version shows nothing', () {
      expect(
        cardReleases(
          releases: _releases,
          lastSeen: '1.12.0',
          installed: '1.11.0',
        ),
        isEmpty,
      );
    });
  });

  group('settleLaunch', () {
    test('A fresh install sees no release card', () {
      final r = settleLaunch(
        record: const WhatsNewRecord(),
        releases: _releases,
        installed: '1.12.0',
        hasProfiles: false,
      );
      expect(r.lastSeenVersion, '1.12.0');
    });

    test('The first release with What\'s new tells existing users about '
        'it, and only it', () {
      final r = settleLaunch(
        record: const WhatsNewRecord(),
        releases: _releases,
        installed: '1.12.0',
        hasProfiles: true,
      );
      expect(r.lastSeenVersion, '1.11.0');
      expect(
        _versions(
          cardReleases(
            releases: _releases,
            lastSeen: r.lastSeenVersion!,
            installed: '1.12.0',
          ),
        ),
        ['1.12.0'],
      );
    });

    test('an existing user on the oldest bundled release starts from '
        'nothing', () {
      final r = settleLaunch(
        record: const WhatsNewRecord(),
        releases: _releases,
        installed: '1.9.1',
        hasProfiles: true,
      );
      expect(r.lastSeenVersion, kNoVersion);
    });

    test('Highlights off: updates count as seen, so turning them back on '
        "doesn't bring back missed cards", () {
      final r = settleLaunch(
        record: const WhatsNewRecord(
          lastSeenVersion: '1.10.0',
          highlightsOff: true,
        ),
        releases: _releases,
        installed: '1.12.0',
        hasProfiles: true,
      );
      expect(r.lastSeenVersion, '1.12.0');
      expect(r.highlightsOff, isTrue);
    });

    test('An ignored card goes away on its own after 5 shown opens', () {
      const shownFive = WhatsNewRecord(
        lastSeenVersion: '1.9.1',
        cardVersion: '1.10.0',
        cardShownCount: kReleaseCardMaxOpens,
      );
      final r = settleLaunch(
        record: shownFive,
        releases: _releases,
        installed: '1.10.0',
        hasProfiles: true,
      );
      expect(r.lastSeenVersion, '1.10.0');
      expect(r.cardShownCount, 0);
      expect(r.cardVersion, isNull);
    });

    test('a card shown 4 times is still there', () {
      const shownFour = WhatsNewRecord(
        lastSeenVersion: '1.9.1',
        cardVersion: '1.10.0',
        cardShownCount: 4,
      );
      final r = settleLaunch(
        record: shownFour,
        releases: _releases,
        installed: '1.10.0',
        hasProfiles: true,
      );
      expect(r, shownFour);
    });

    test('a newer release joining the card restarts the open count', () {
      const shownFour = WhatsNewRecord(
        lastSeenVersion: '1.9.1',
        cardVersion: '1.10.0',
        cardShownCount: 4,
      );
      final r = settleLaunch(
        record: shownFour,
        releases: _releases,
        installed: '1.12.0',
        hasProfiles: true,
      );
      expect(r.lastSeenVersion, '1.9.1');
      expect(r.cardVersion, '1.12.0');
      expect(r.cardShownCount, 0);
    });

    test('Going back to an older version never moves last seen back', () {
      const seen = WhatsNewRecord(lastSeenVersion: '1.12.0');
      final r = settleLaunch(
        record: seen,
        releases: _releases,
        installed: '1.11.0',
        hasProfiles: true,
      );
      expect(r.lastSeenVersion, '1.12.0');
    });

    test('Restoring onto a newer version still shows that version\'s card', () {
      // The backup carried lastSeen 1.10.0; this device runs 1.12.0.
      const restored = WhatsNewRecord(lastSeenVersion: '1.10.0');
      final r = settleLaunch(
        record: restored,
        releases: _releases,
        installed: '1.12.0',
        hasProfiles: true,
      );
      expect(
        _versions(
          cardReleases(
            releases: _releases,
            lastSeen: r.lastSeenVersion!,
            installed: '1.12.0',
          ),
        ),
        ['1.12.0'],
      );
    });
  });

  group('markSeen', () {
    test('Dismissing is final for that release', () {
      const pending = WhatsNewRecord(
        lastSeenVersion: '1.9.1',
        cardVersion: '1.10.0',
        cardShownCount: 2,
      );
      final r = markSeen(pending, '1.10.0');
      expect(r.lastSeenVersion, '1.10.0');
      expect(r.cardVersion, isNull);
      expect(r.cardShownCount, 0);
    });

    test('never moves last seen back', () {
      const seen = WhatsNewRecord(lastSeenVersion: '1.12.0');
      expect(markSeen(seen, '1.11.0').lastSeenVersion, '1.12.0');
    });
  });
}
