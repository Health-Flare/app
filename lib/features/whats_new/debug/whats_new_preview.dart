import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/profile_ids.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/features/whats_new/models/release_note.dart';
import 'package:health_flare/features/whats_new/whats_new_provider.dart';
import 'package:health_flare/features/whats_new/whats_new_rules.dart';

/// Preview scenarios for What's new: put a debug build straight into a
/// card state without editing pubspec.yaml or releases.json.
///
///   flutter run --dart-define=WHATS_NEW_PREVIEW=card
///   bash scripts/whats_new.sh run card
///
/// Ignored in release builds. Full guide: docs/testing/whats-new.md.
///
/// Every scenario except [WhatsNewScenario.upgrade] and
/// [WhatsNewScenario.reset] sets the stored state on every launch, so the
/// same screen comes back each time. Use `upgrade` to try dismiss and
/// relaunch for real.
enum WhatsNewScenario {
  card(
    'One release with highlights: one card, "What\'s new in 99.2".',
    installed: '99.2.0',
    record: WhatsNewRecord(lastSeenVersion: '99.1.0'),
  ),
  multi(
    'Skipped a version: one card covering 99.2 and 99.1.',
    installed: '99.2.0',
    record: WhatsNewRecord(lastSeenVersion: '99.0.0'),
  ),
  fixonly(
    'Fix-only update to 99.3.0: no card, 99.3.0 is in history.',
    installed: '99.3.0',
    record: WhatsNewRecord(lastSeenVersion: '99.2.0'),
  ),
  seen(
    'Card already dismissed: no card, full history.',
    installed: '99.2.0',
    record: WhatsNewRecord(lastSeenVersion: '99.2.0'),
  ),
  off(
    '"Show update highlights" off: no card, switch off in Settings.',
    installed: '99.2.0',
    record: WhatsNewRecord(lastSeenVersion: '99.2.0', highlightsOff: true),
  ),
  upgrade(
    'Real flow, state kept between launches: dismiss, relaunch, count '
    'to 5 opens. Starts from an update to 99.2.0.',
    installed: '99.2.0',
    record: null,
  ),
  reset(
    'Back to real releases and version, What\'s new state cleared. Run '
    'this after previewing, or real cards may not show on this install.',
    installed: null,
    record: WhatsNewRecord(),
  );

  const WhatsNewScenario(
    this.description, {
    required this.installed,
    required this.record,
  });

  final String description;

  /// Version the app pretends to be. Null: the real installed version.
  final String? installed;

  /// State written at launch. Null: keep what's stored.
  final WhatsNewRecord? record;

  /// Uses [previewReleases] instead of the bundled file.
  bool get usesFixture => installed != null;

  static WhatsNewScenario? byName(String name) {
    for (final s in values) {
      if (s.name == name) return s;
    }
    return null;
  }
}

/// The scenario from `--dart-define=WHATS_NEW_PREVIEW`, or null. Always
/// null in release builds.
WhatsNewScenario? previewScenarioFromEnvironment() {
  if (kReleaseMode) return null;
  const name = String.fromEnvironment('WHATS_NEW_PREVIEW');
  if (name.isEmpty) return null;
  final s = WhatsNewScenario.byName(name);
  if (s == null) {
    debugPrint(
      "What's new preview: unknown scenario '$name'. Known: "
      '${WhatsNewScenario.values.map((s) => s.name).join(', ')}',
    );
  }
  return s;
}

/// Writes the scenario's starting state. Call before
/// [WhatsNewStore.settle], which then applies the normal launch rules on
/// top (so expiry and counting behave exactly as in a real update).
///
/// On an empty database (fresh simulator, or `flutter drive` reinstalled
/// the app) it also adds a demo profile, "Sam", with onboarding done, so
/// the scenario opens straight on the dashboard.
Future<void> applyPreviewScenario(Isar isar, WhatsNewScenario s) async {
  if (s != WhatsNewScenario.reset) await _ensureDemoProfile(isar);
  var record = s.record;
  if (record == null) {
    // upgrade: keep state between launches, but start from 99.1 the first
    // time (or after another scenario left real-version state behind).
    final stored = await WhatsNewStore.read(isar);
    final last = stored.lastSeenVersion;
    final fromPreview = last != null && compareVersions(last, '99.0.0') >= 0;
    record = fromPreview
        ? stored
        : const WhatsNewRecord(lastSeenVersion: '99.1.0');
  }
  await WhatsNewStore.write(isar, record);
}

Future<void> _ensureDemoProfile(Isar isar) async {
  if (await isar.profileIsars.count() > 0) return;
  await isar.writeTxn(() async {
    final id = await nextProfileId(isar);
    await isar.profileIsars.put(
      ProfileIsar()
        ..id = id
        ..name = 'Sam'
        ..firstLogShown = true
        ..weatherOptInShown = true,
    );
    final settings = await isar.appSettings.get(1) ?? AppSettings();
    settings.activeProfileId = id;
    await isar.appSettings.put(settings);
  });
}

/// Provider overrides so the app reads the fixture releases and pretends
/// to be the scenario's version.
List<Override> previewOverrides(WhatsNewScenario s) => [
  if (s.usesFixture) ...[
    releaseNotesProvider.overrideWith((ref) async => previewReleases),
    installedVersionProvider.overrideWith((ref) async => s.installed!),
  ],
];

/// Fixture releases for previews, tests and screenshots. Version 99 so it
/// can never be mistaken for a real release.
final previewReleases = <ReleaseNote>[
  ReleaseNote(
    version: '99.3.0',
    date: DateTime(2099, 3, 20),
    changes: const [
      'A missed dose no longer exports as taken.',
      'The sleep form keeps your wake time when you change the date.',
    ],
  ),
  ReleaseNote(
    version: '99.2.0',
    date: DateTime(2099, 3, 1),
    highlights: const [
      ReleaseHighlight(
        title: 'Naps in Quick Log',
        body: 'Type "napped 2 to 3" and it is saved as a nap.',
      ),
      ReleaseHighlight(
        title: 'Calmer reminders',
        body: 'Reminders wait until you have been on your phone for a bit.',
      ),
    ],
    changes: const [
      'You can log a nap from Quick Log.',
      'Reminders wait until the phone has been in use for a minute.',
      'Fixed: the check-in card sometimes showed yesterday.',
    ],
  ),
  ReleaseNote(
    version: '99.1.0',
    date: DateTime(2099, 2, 10),
    highlights: const [
      ReleaseHighlight(
        title: 'Notes on any vital',
        body:
            'Add a note to a blood pressure or temperature reading, such as '
            '"after climbing stairs". Notes show on the chart and in exports.',
      ),
      ReleaseHighlight(
        title: 'Bigger buttons on the check-in',
        body: 'Every check-in button is easier to hit with a shaky hand.',
      ),
      ReleaseHighlight(
        title: 'Reports remember your dates',
        body: 'The report screen keeps the last range you picked.',
      ),
    ],
    changes: const [
      'Vitals can have a note.',
      'Check-in buttons are at least 56 dp.',
      'Reports remember the last date range.',
    ],
  ),
  ReleaseNote(
    version: '99.0.0',
    date: DateTime(2099, 1, 15),
    highlights: const [
      ReleaseHighlight(
        title: 'A new look for the dashboard',
        body: 'Cards line up and read top to bottom.',
      ),
    ],
    changes: const ['The dashboard cards share one layout.'],
  ),
];
