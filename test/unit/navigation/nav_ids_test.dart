// Stable navigation ids (#136). Spec: docs/features/navigation-customization.feature
// (rule 2; "An id the app doesn't recognise is skipped safely"; "A pinned
// screen that was merged follows its replacement") and navigation.feature.
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/router/app_router.dart';

/// Every id that has ever shipped, one per line. Ids are stored in user
/// data and backups, so none may disappear: each must still be in the
/// registry or be in [retiredNavIds]. Add new ids here in the PR that adds
/// them; never delete a line.
const _snapshotPath = 'test/unit/navigation/known_nav_ids.txt';

List<String> _snapshot() => File(_snapshotPath)
    .readAsLinesSync()
    .map((l) => l.trim())
    .where((l) => l.isNotEmpty && !l.startsWith('#'))
    .toList();

final _idFormat = RegExp(r'^[a-z][a-z0-9-]*(\.[a-z][a-z0-9-]*)*$');

const _known = {'dashboard', 'track', 'care', 'track.sleep', 'track.activity'};

void main() {
  group('An id the app doesn\'t recognise is skipped safely', () {
    test('that item is left out, and the rest keeps its order', () {
      expect(
        resolveNavIds(
          ['dashboard', 'from-a-newer-version', 'care', 'track'],
          known: _known,
          retired: const {},
        ),
        ['dashboard', 'care', 'track'],
      );
    });

    test('if fewer than three items remain, the default bar is used', () {
      expect(
        resolveBarIds(
          ['dashboard', 'gone-1', 'gone-2', 'care'],
          defaultBar: const ['dashboard', 'track', 'care'],
          known: _known,
          retired: const {},
        ),
        ['dashboard', 'track', 'care'],
      );
    });

    test('three or more left: the person\'s bar is kept', () {
      expect(
        resolveBarIds(
          ['care', 'unknown', 'dashboard', 'track'],
          defaultBar: const ['dashboard', 'track', 'care'],
          known: _known,
          retired: const {},
        ),
        ['care', 'dashboard', 'track'],
      );
    });

    test('nothing stored follows the default', () {
      expect(
        resolveBarIds(
          null,
          defaultBar: const ['dashboard', 'track', 'care'],
          known: _known,
        ),
        ['dashboard', 'track', 'care'],
      );
    });

    test('the stored choice is not rewritten', () {
      final stored = List<String>.unmodifiable([
        'dashboard',
        'unknown',
        'care',
        'track',
      ]);
      resolveBarIds(
        stored,
        defaultBar: const ['dashboard', 'track', 'care'],
        known: _known,
        retired: const {},
      );
      expect(stored, ['dashboard', 'unknown', 'care', 'track']);
    });
  });

  group('A pinned screen that was merged follows its replacement', () {
    const merged = {'track.activity': 'track.sleep'};

    test('the pin points at the tab it was merged into', () {
      expect(
        resolveNavIds(
          ['dashboard', 'track.activity', 'care'],
          known: _known.difference({'track.activity'}),
          retired: merged,
        ),
        ['dashboard', 'track.sleep', 'care'],
      );
    });

    test('if that tab is already in the bar, the duplicate is removed', () {
      expect(
        resolveNavIds(
          ['dashboard', 'track.sleep', 'care', 'track.activity'],
          known: _known.difference({'track.activity'}),
          retired: merged,
        ),
        ['dashboard', 'track.sleep', 'care'],
      );
    });

    test('chains of merges are followed', () {
      expect(
        resolveNavId(
          'a',
          known: const {'c'},
          retired: const {'a': 'b', 'b': 'c'},
        ),
        'c',
      );
    });

    test('a replacement that is itself unknown is dropped', () {
      expect(
        resolveNavId('a', known: const {'c'}, retired: const {'a': 'b'}),
        isNull,
      );
    });

    test('a cycle is dropped, not looped on', () {
      expect(
        resolveNavId(
          'a',
          known: const {'c'},
          retired: const {'a': 'b', 'b': 'a'},
        ),
        isNull,
      );
    });
  });

  group('the registry', () {
    test('ids are lowercase, dot-separated, and unique', () {
      final features = [for (final f in navFeatures) f.id];
      final places = [
        for (final s in navSections) ...[s.id, for (final t in s.tabs) t.id],
      ];
      for (final id in [...features, ...places]) {
        expect(_idFormat.hasMatch(id), isTrue, reason: id);
      }
      expect(features.toSet(), hasLength(features.length));
      expect(places.toSet(), hasLength(places.length));
      expect(knownNavIds, {...features, ...places});
    });

    test('a feature and its tab share one id', () {
      final tabs = {
        for (final s in navSections) ...[for (final t in s.tabs) t.id],
      };
      expect({for (final f in navFeatures) f.id}, tabs);
    });

    test('The primary navigation has four sections, in order', () {
      expect(
        [for (final s in navSections) s.id],
        ['dashboard', 'track', 'care', 'journal'],
      );
      expect(
        [for (final s in navSections) s.label],
        ['Dashboard', 'Track', 'Care', 'Journal'],
      );
    });

    test('each section has its tabs, in the spec\'s order', () {
      String tabs(String section) => navSections
          .firstWhere((s) => s.id == section)
          .tabs
          .map((t) => t.label)
          .join(', ');
      expect(tabs('track'), 'Symptoms, Vitals, Meals, Sleep, Activity');
      expect(tabs('care'), 'Medications, Appointments, Conditions, Flares');
      expect(tabs('journal'), 'Entries, Check-ins');
      expect(tabs('dashboard'), '');
    });

    test('tab ids are their section id plus a name', () {
      for (final s in navSections) {
        for (final t in s.tabs) {
          expect(t.id, startsWith('${s.id}.'));
        }
      }
    });

    test('every list screen is exactly one tab', () {
      final routes = [
        for (final s in navSections) ...[for (final t in s.tabs) t.route],
      ];
      // Symptoms, Vitals and Conditions share the Tracking screen today;
      // #141 gives each its own place.
      final ownScreens = routes.where((r) => r != AppRoutes.tracking).toList();
      expect(ownScreens.toSet(), hasLength(ownScreens.length));
      expect(
        routes.toSet(),
        containsAll({
          AppRoutes.tracking,
          AppRoutes.meals,
          AppRoutes.sleep,
          AppRoutes.activity,
          AppRoutes.medications,
          AppRoutes.appointments,
          AppRoutes.flareHistory,
          AppRoutes.journal,
          AppRoutes.checkinHistory,
        }),
      );
    });

    test('Features in use: these can be turned off, all on by default', () {
      expect(
        [
          for (final f in navFeatures)
            if (f.canTurnOff) f.label,
        ],
        [
          'Vitals',
          'Meals',
          'Sleep',
          'Activity',
          'Medications',
          'Appointments',
          'Flares',
          'Journal',
          'Check-ins',
        ],
      );
    });

    test('Symptoms and Conditions are always on', () {
      expect(
        [
          for (final f in navFeatures)
            if (!f.canTurnOff) f.label,
        ],
        ['Symptoms', 'Conditions'],
      );
    });

    test('every tab belongs to a feature', () {
      final features = {for (final f in navFeatures) f.id};
      for (final s in navSections) {
        for (final t in s.tabs) {
          expect(features, contains(t.featureId), reason: t.id);
        }
      }
    });

    test('the bar today uses the same ids it will have in Track and Care', () {
      expect(
        [for (final b in legacyBar) b.id],
        [
          'dashboard',
          'track',
          'care.medications',
          'track.meals',
          'journal',
          'track.sleep',
        ],
      );
      expect(
        [for (final b in legacyBar) b.label],
        ['Dashboard', 'Tracking', 'Meds', 'Meals', 'Journal', 'Sleep'],
      );
      for (final b in legacyBar) {
        expect(knownNavIds, contains(b.id));
      }
    });
  });

  group('ids are forever (release check)', () {
    test('every id that has shipped is still known or has a replacement', () {
      for (final id in _snapshot()) {
        expect(
          resolveNavId(id),
          isNotNull,
          reason:
              '"$id" was removed from the registry without an entry in '
              'retiredNavIds. Ids are stored in user data and backups: add '
              'the id it was replaced by to retiredNavIds.',
        );
      }
    });

    test('every id in the registry is in the snapshot', () {
      final missing = knownNavIds.difference(_snapshot().toSet());
      expect(
        missing,
        isEmpty,
        reason:
            'New ids: add them to $_snapshotPath, one per line. That file '
            'is the record of every id that has shipped.',
      );
    });

    test('a retired id is never reused', () {
      for (final id in retiredNavIds.keys) {
        expect(knownNavIds, isNot(contains(id)), reason: id);
      }
    });

    test('every replacement resolves to a known id', () {
      for (final id in retiredNavIds.keys) {
        expect(resolveNavId(id), isNotNull, reason: id);
      }
    });
  });

  group('FeatureFlags', () {
    test('trackAndCare is off unless the build turns it on', () {
      expect(const FeatureFlags().trackAndCare, isFalse);
      expect(FeatureFlags.fromEnvironment().trackAndCare, isFalse);
    });

    test(
      'the provider gives the build\'s flags, and tests can override it',
      () {
        final plain = ProviderContainer();
        addTearDown(plain.dispose);
        expect(plain.read(featureFlagsProvider).trackAndCare, isFalse);

        final on = ProviderContainer(
          overrides: [
            featureFlagsProvider.overrideWithValue(
              const FeatureFlags(trackAndCare: true),
            ),
          ],
        );
        addTearDown(on.dispose);
        expect(on.read(featureFlagsProvider).trackAndCare, isTrue);
      },
    );
  });
}
