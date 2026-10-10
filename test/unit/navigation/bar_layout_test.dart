// Bar and default-layout rules (#137). Pure Dart, no database.
// Spec: docs/features/navigation-customization.feature ("Later updates")
// and docs/features/release-guides.feature ("Every change to the default
// bar comes with a guide", "Someone on the default bar is shown what
// changed").
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';

const _v1 = [
  'dashboard',
  'track',
  'care.medications',
  'track.meals',
  'journal',
  'track.sleep',
];
const _v2 = ['dashboard', 'track', 'care', 'journal'];
const _v3 = ['dashboard', 'track', 'care', 'journal', 'track.meals'];
const _defaults = {1: _v1, 2: _v2, 3: _v3};

void main() {
  group('default bars', () {
    test('version 1 is the bar every release up to 1.9.1 had', () {
      expect(defaultBarVersions[kLegacyBarVersion], [
        for (final item in legacyBar) item.id,
      ]);
    });

    test('Track and Care is version 2, behind its flag', () {
      expect(defaultBarVersions[2], _v2);
      expect(currentDefaultBarVersion(const FeatureFlags()), 1);
      expect(
        currentDefaultBarVersion(const FeatureFlags(trackAndCare: true)),
        2,
      );
    });

    test('every default bar only uses ids in use now', () {
      for (final bar in defaultBarVersions.values) {
        expect(knownNavIds.containsAll(bar), isTrue, reason: '$bar');
      }
    });
  });

  group('Every change to the default bar comes with a guide', () {
    test('every default bar after 1.9.1 names the guide that explains it', () {
      for (final v in defaultBarVersions.keys.where((v) => v > 1)) {
        expect(
          defaultBarGuideIds[v],
          isNotNull,
          reason:
              'Default bar v$v has no guide. Add its id to defaultBarGuideIds '
              '(lib/core/navigation/bar_layout.dart): nobody\'s bar changes '
              'without them being shown what changed.',
        );
      }
    });

    test('Track and Care is explained by its guide', () {
      expect(defaultBarGuideIds[2], 'track-and-care');
    });
  });

  group('A default bar follows a new default', () {
    const record = BarRecord(seenVersion: 1);

    test('my bar becomes the new default', () {
      expect(barFor(record, current: 2, defaults: _defaults), _v2);
    });

    test('and I am shown what changed: my old bar beside the new one', () {
      final change = pendingBarChange(record, current: 2, defaults: _defaults);
      expect(change, isNotNull);
      expect(change!.fromVersion, 1);
      expect(change.toVersion, 2);
      expect(change.customized, isFalse);
      expect(change.before, _v1);
      expect(change.newDefault, _v2);
    });
  });

  group('Updating from 1.9.1 or earlier counts as using the default bar', () {
    // A database from 1.9.1 or earlier has neither field: nothing stored,
    // no version recorded.
    const fromOld = BarRecord();

    test('my bar becomes the new default', () {
      expect(barFor(fromOld, current: 2, defaults: _defaults), _v2);
    });

    test('and I am shown what changed, from the 1.9.1 bar', () {
      final change = pendingBarChange(fromOld, current: 2, defaults: _defaults);
      expect(change, isNotNull);
      expect(change!.fromVersion, kLegacyBarVersion);
      expect(change.customized, isFalse);
      expect(change.before, _v1);
    });

    test('nothing to show while the default is still the 1.9.1 bar', () {
      expect(pendingBarChange(fromOld, current: 1, defaults: _defaults), null);
    });
  });

  group('A customized bar is kept as it is', () {
    const mine = ['dashboard', 'track.sleep', 'care.medications'];
    const record = BarRecord(storedBar: mine, seenVersion: 1);

    test('my bar stays exactly as I set it', () {
      expect(barFor(record, current: 2, defaults: _defaults), mine);
    });

    test('and the guide can say the default changed and mine was kept', () {
      final change = pendingBarChange(record, current: 2, defaults: _defaults);
      expect(change, isNotNull);
      expect(change!.customized, isTrue);
      expect(change.before, mine);
      expect(change.newDefault, _v2);
    });
  });

  group('Skipping versions shows the bar I last had, not one I never saw', () {
    test('what changed is shown from the bar I last had', () {
      final change = pendingBarChange(
        const BarRecord(seenVersion: 1),
        current: 3,
        defaults: _defaults,
      );
      expect(change!.fromVersion, 1);
      expect(change.before, _v1);
      expect(change.newDefault, _v3);
    });
  });

  group('seen version', () {
    test('nothing to show once the change has been seen', () {
      expect(
        pendingBarChange(
          const BarRecord(seenVersion: 2),
          current: 2,
          defaults: _defaults,
        ),
        isNull,
      );
    });

    test('nothing to show after a downgrade, or with the flag turned off', () {
      expect(
        pendingBarChange(
          const BarRecord(seenVersion: 2),
          current: 1,
          defaults: _defaults,
        ),
        isNull,
      );
    });

    test('marking a change seen never moves the version back', () {
      expect(markBarChangeSeen(const BarRecord(), 2).seenVersion, 2);
      expect(
        markBarChangeSeen(const BarRecord(seenVersion: 3), 2).seenVersion,
        3,
      );
    });

    test('a fresh install starts on the current default, with nothing to '
        'explain', () {
      final settled = settleBarLaunch(
        const BarRecord(),
        current: 2,
        hasProfiles: false,
      );
      expect(settled.seenVersion, 2);
      expect(pendingBarChange(settled, current: 2), isNull);
    });

    test('an update from 1.9.1 is not mistaken for a fresh install', () {
      expect(
        settleBarLaunch(const BarRecord(), current: 2, hasProfiles: true),
        const BarRecord(),
      );
    });

    test('a later launch changes nothing', () {
      const r = BarRecord(seenVersion: 1);
      expect(settleBarLaunch(r, current: 2, hasProfiles: false), r);
    });
  });

  group('choosing a bar', () {
    test(
      'a copy of the default is never stored: it is stored as "default"',
      () {
        final r = chooseBar(
          const BarRecord(),
          _v2,
          current: 2,
          defaults: _defaults,
        );
        expect(r.storedBar, isNull);
        expect(r.seenVersion, 2);
      },
    );

    test('a customized bar is stored as chosen, on the current version', () {
      final r = chooseBar(
        const BarRecord(seenVersion: 1),
        const ['dashboard', 'care'],
        current: 2,
        defaults: _defaults,
      );
      expect(r.storedBar, ['dashboard', 'care']);
      expect(r.seenVersion, 2);
    });

    test('"Use default" stores nothing', () {
      final r = chooseBar(
        const BarRecord(storedBar: ['dashboard', 'care', 'journal']),
        null,
        current: 2,
        defaults: _defaults,
      );
      expect(r.storedBar, isNull);
    });
  });
}
