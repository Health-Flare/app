// The What's new preview scenarios (scripts/whats_new.sh run <name>) must
// each land in the state they describe, using the same rules as a real
// update. Guide: docs/testing/whats-new.md.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/database/app_schemas.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/features/whats_new/debug/whats_new_preview.dart';
import 'package:health_flare/features/whats_new/models/release_note.dart';
import 'package:health_flare/features/whats_new/whats_new_provider.dart';
import 'package:health_flare/features/whats_new/whats_new_rules.dart';

Future<WhatsNewState> _launch(Isar isar, WhatsNewScenario s) async {
  await applyPreviewScenario(isar, s);
  final record = await WhatsNewStore.settle(
    isar,
    releases: previewReleases,
    installed: s.installed!,
  );
  return WhatsNewState(
    record: record,
    releases: previewReleases,
    installed: s.installed!,
  );
}

List<String> _v(Iterable<ReleaseNote> r) => [for (final n in r) n.version];

void main() {
  late Isar isar;

  setUpAll(() async => Isar.initializeIsarCore(download: true));
  setUp(() async {
    isar = await Isar.open(
      appSchemas,
      directory: '',
      name: 'preview_${DateTime.now().microsecondsSinceEpoch}',
    );
    await MigrationRunner.run(isar);
    await isar.writeTxn(
      () => isar.profileIsars.put(
        ProfileIsar()
          ..id = 1
          ..name = 'Sarah',
      ),
    );
  });
  tearDown(() async => isar.close(deleteFromDisk: true));

  test('card: one card for 99.2', () async {
    final s = await _launch(isar, WhatsNewScenario.card);
    expect(_v(s.card), ['99.2.0']);
  });

  test('multi: one card covering 99.2 and 99.1', () async {
    final s = await _launch(isar, WhatsNewScenario.multi);
    expect(_v(s.card), ['99.2.0', '99.1.0']);
  });

  test('fixonly: no card, 99.3 is in history', () async {
    final s = await _launch(isar, WhatsNewScenario.fixonly);
    expect(s.card, isEmpty);
    expect(_v(s.history).first, '99.3.0');
  });

  test('seen: no card', () async {
    expect((await _launch(isar, WhatsNewScenario.seen)).card, isEmpty);
  });

  test('off: no card, highlights off', () async {
    final s = await _launch(isar, WhatsNewScenario.off);
    expect(s.card, isEmpty);
    expect(s.highlightsOn, isFalse);
  });

  test('every fixed scenario gives the same screen on every launch', () async {
    for (final sc in WhatsNewScenario.values) {
      if (sc.record == null || !sc.usesFixture) continue;
      final first = await _launch(isar, sc);
      final again = await _launch(isar, sc);
      expect(_v(again.card), _v(first.card), reason: sc.name);
    }
  });

  test('upgrade: starts with a card, keeps state, dismiss sticks', () async {
    var s = await _launch(isar, WhatsNewScenario.upgrade);
    expect(_v(s.card), ['99.2.0']);
    await WhatsNewStore.write(isar, markSeen(s.record, s.installed));
    s = await _launch(isar, WhatsNewScenario.upgrade);
    expect(s.card, isEmpty);
  });

  test('upgrade: expires after 5 shown opens', () async {
    for (var i = 0; i < kReleaseCardMaxOpens; i++) {
      final s = await _launch(isar, WhatsNewScenario.upgrade);
      expect(s.card, isNotEmpty, reason: 'open ${i + 1}');
      await WhatsNewStore.write(
        isar,
        s.record.copyWith(cardShownCount: s.record.cardShownCount + 1),
      );
    }
    expect((await _launch(isar, WhatsNewScenario.upgrade)).card, isEmpty);
  });

  test('upgrade after a real-version state starts fresh at 99.1', () async {
    await WhatsNewStore.write(
      isar,
      const WhatsNewRecord(lastSeenVersion: '1.10.0'),
    );
    final s = await _launch(isar, WhatsNewScenario.upgrade);
    expect(_v(s.card), ['99.2.0']);
  });

  test('reset clears everything, so no 99.x state is left behind', () async {
    await _launch(isar, WhatsNewScenario.off);
    await applyPreviewScenario(isar, WhatsNewScenario.reset);
    expect(await WhatsNewStore.read(isar), const WhatsNewRecord());
  });

  test('fixture versions can never collide with a real release', () async {
    final real = ReleaseNote.listFromJson(
      File('assets/whats_new/releases.json').readAsStringSync(),
    );
    for (final r in real) {
      expect(compareVersions(r.version, '99.0.0'), lessThan(0));
    }
  });

  test('a scenario on an empty database adds a demo profile, so it opens '
      'on the dashboard', () async {
    await isar.writeTxn(() => isar.profileIsars.clear());
    await _launch(isar, WhatsNewScenario.card);
    final profiles = await isar.profileIsars.where().findAll();
    expect(profiles.map((p) => p.name), ['Sam']);
    expect(profiles.single.firstLogShown, isTrue);
    expect(
      (await isar.appSettings.get(1))!.activeProfileId,
      profiles.single.id,
    );
    // And the card still shows: it's an update, not a fresh install.
    expect((await _launch(isar, WhatsNewScenario.card)).card, isNotEmpty);
  });

  test('a scenario never touches existing profiles', () async {
    await _launch(isar, WhatsNewScenario.card);
    final names = (await isar.profileIsars.where().findAll()).map(
      (p) => p.name,
    );
    expect(names, ['Sarah']);
  });

  test('previews are off unless asked for', () {
    // No --dart-define in tests: the app runs as normal.
    expect(previewScenarioFromEnvironment(), isNull);
  });
}
