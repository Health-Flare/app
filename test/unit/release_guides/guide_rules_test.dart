// Release guide rules and content (#145). Pure.
// Spec: docs/features/release-guides.feature.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/features/release_guides/guide_rules.dart';
import 'package:health_flare/features/release_guides/release_guide.dart';

final _monday = DateTime(2026, 11, 2, 9);

void main() {
  group('The guide card comes back once if put off', () {
    GuideCardMode mode({
      DateTime? putOffOn,
      DateTime? now,
      bool hidden = false,
      bool pending = true,
    }) => guideCardMode(
      pending: pending,
      record: GuideRecord(putOffOn: putOffOn),
      now: now ?? _monday,
      hiddenThisSession: hidden,
    );

    test('first time: "Not now"', () {
      expect(mode(), GuideCardMode.notNow);
    });

    test('put off: hidden for the rest of this session', () {
      expect(mode(hidden: true), GuideCardMode.hidden);
    });

    test('opened again the same day: still hidden', () {
      expect(
        mode(putOffOn: _monday, now: _monday.add(const Duration(hours: 5))),
        GuideCardMode.hidden,
      );
    });

    test('a later day: one more time, with "Dismiss"', () {
      expect(
        mode(putOffOn: _monday, now: _monday.add(const Duration(days: 1))),
        GuideCardMode.dismiss,
      );
    });

    test('nothing pending: no card', () {
      expect(mode(pending: false), GuideCardMode.hidden);
    });
  });

  group('An update with a guide says plainly what moved', () {
    test('the card', () {
      expect(guideCardTitle(customized: false), 'The bottom bar has changed');
      expect(
        trackAndCareGuide.cardBody,
        'Meds, Meals and Sleep have moved. Nothing has been removed.',
      );
    });

    test('Someone with a custom bar is told their bar was kept', () {
      expect(
        guideCardTitle(customized: true),
        'The default bottom bar has changed. Yours has been kept.',
      );
    });
  });

  test('"Show me" opens the guide: four steps, in order', () {
    expect(trackAndCareGuide.steps, [
      'Four sections now',
      'Where things moved',
      'Keep it or change it',
      'Finding this again',
    ]);
  });

  test('The guide shows the new bar next to the old one: one line each', () {
    expect(trackAndCareGuide.sectionLines, {
      'dashboard': "Today, and what's coming up",
      'track': 'Symptoms, vitals, meals, sleep and activity',
      'care': 'Medications, appointments, conditions, flares',
      'journal': 'Journal entries and daily check-ins',
    });
  });

  group('Every moved screen is listed with where it went', () {
    test('moved', () {
      expect(
        [for (final r in trackAndCareGuide.moved) (r.was, r.now)],
        [
          ('Tracking', 'Track'),
          ('Meds', 'Care > Medications'),
          ('Meals', 'Track > Meals'),
          ('Sleep', 'Track > Sleep'),
          ('Journal', 'Journal > Entries'),
        ],
      );
    });

    test('a place of their own', () {
      expect(
        [for (final r in trackAndCareGuide.ownPlace) (r.was, r.now)],
        [
          ('Appointments', 'Care > Appointments'),
          ('Activity', 'Track > Activity'),
          ('Check-ins', 'Journal > Check-ins'),
          ('Flares', 'Care > Flares'),
        ],
      );
    });

    test('"Pin" only on what used to be in the bar: Meds, Meals, Sleep', () {
      expect(
        [
          for (final r in [
            ...trackAndCareGuide.moved,
            ...trackAndCareGuide.ownPlace,
          ])
            if (r.pinnable) r.was,
        ],
        ['Meds', 'Meals', 'Sleep'],
      );
    });

    test('every row opens a real section or tab', () {
      final ids = {
        for (final s in navSections) ...[s.id, for (final t in s.tabs) t.id],
      };
      for (final r in [
        ...trackAndCareGuide.moved,
        ...trackAndCareGuide.ownPlace,
      ]) {
        expect(ids, contains(r.tabId), reason: r.was);
      }
    });
  });

  group('"Pin"', () {
    test('the pinned line says the bar is now your own', () {
      expect(
        pinnedLine('Sleep'),
        'Sleep is in your bar. Your bar is now your own, so later updates '
        "won't change it.",
      );
    });

    test('with a full bar', () {
      expect(
        pinFullLine('Sleep'),
        'The bar holds five items. Remove one to add Sleep.',
      );
    });
  });

  group('Keep it or change it', () {
    test('The guide offers to keep it like before: new layout first', () {
      expect(guideChoices(customized: false), [
        GuideChoice.useNew,
        GuideChoice.likeBefore,
        GuideChoice.setUpMyself,
      ]);
      expect(
        [for (final c in guideChoices(customized: false)) choiceLabel(c)],
        ['Use the new layout', 'Keep it like before', 'Set it up myself'],
      );
    });

    test('a custom bar: "Keep my bar" first', () {
      expect(
        [for (final c in guideChoices(customized: true)) choiceLabel(c)],
        ['Keep my bar', 'Use the new layout', 'Set it up myself'],
      );
    });
  });

  group('A pinned screen that moved is explained, not silently swapped', () {
    String label(String id) =>
        {'track.activity': 'Activity', 'track.sleep': 'Sleep'}[id] ?? id;

    test('the card names the old and the new screen', () {
      expect(
        movedPinNotes(
          ['dashboard', 'track', 'track.activity', 'care'],
          retired: const {'track.activity': 'track.sleep'},
          label: label,
        ),
        ['Activity is now part of Sleep, so your bar shows Sleep.'],
      );
    });

    test('nothing merged, or the default bar: nothing to say', () {
      expect(movedPinNotes(['dashboard', 'track', 'care']), isEmpty);
      expect(movedPinNotes(null), isEmpty);
    });
  });

  group('Every change to the default bar comes with a guide', () {
    test('each default bar after 1.9.1 names a guide that exists', () {
      for (final v in defaultBarVersions.keys.where((v) => v > 1)) {
        expect(releaseGuides, contains(defaultBarGuideIds[v]), reason: 'v$v');
      }
    });

    test('tool/known_guide_ids.txt lists every guide, for the release '
        'checks', () {
      final listed = File('tool/known_guide_ids.txt')
          .readAsLinesSync()
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty && !l.startsWith('#'))
          .toSet();
      expect(listed, releaseGuides.keys.toSet());
    });
  });
}
