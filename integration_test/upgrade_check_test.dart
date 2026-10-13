// ignore_for_file: avoid_print
//
// The real upgrade, on a device (#181). scripts/upgrade_test.sh installs a
// released build, gives it a fixture database (test/fixtures/upgrades/),
// launches it once, then runs this with the current build installed over
// it. The app starts through its real main(): real documents folder, real
// startup migration, real safety copy. Nothing here opens a database of its
// own.
//
//   bash scripts/upgrade_test.sh 1.9.1
//
// UPGRADE_MANIFEST carries the fixture's manifest.json, base64.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/failed_upgrade.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/database/pre_migration_snapshot.dart';
import 'package:health_flare/data/models/dose_log_isar.dart';
import 'package:health_flare/data/models/journal_entry_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/main.dart' as app;

Future<void> _waitFor(WidgetTester tester, Finder f, {int seconds = 30}) async {
  final end = DateTime.now().add(Duration(seconds: seconds));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (f.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $f');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const encoded = String.fromEnvironment('UPGRADE_MANIFEST');
  final manifest = encoded.isEmpty
      ? null
      : jsonDecode(utf8.decode(base64.decode(encoded))) as Map<String, dynamic>;

  testWidgets('the app opens on the old data, upgraded', (tester) async {
    expect(manifest, isNotNull, reason: 'run via scripts/upgrade_test.sh');
    final release = manifest!['release'];
    final docs = (await getApplicationDocumentsDirectory()).path;
    expect(
      File('$docs/healthflare.isar').existsSync(),
      isTrue,
      reason:
          'the $release data is still on the device after installing '
          'over it',
    );

    // main() is `void main() async`: it returns before startup is done.
    app.main();
    await _waitFor(tester, find.byType(NavigationBar));
    // Android needs its surface converted once before any screenshot.
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
    await tester.pump(const Duration(seconds: 2));
    await binding.takeScreenshot('upgrade_from_${release}_first_screen');

    // The release guide card, not a failed update.
    try {
      await _waitFor(tester, find.text('The bottom bar has changed'));
    } on TestFailure {
      final shown = find
          .byType(Text)
          .evaluate()
          .map((e) => (e.widget as Text).data)
          .whereType<String>()
          .toList();
      print('On screen instead: $shown');
      rethrow;
    }
    expect(find.text("This update didn't finish"), findsNothing);
    await binding.takeScreenshot('upgrade_from_${release}_dashboard');

    final isar = Isar.getInstance('healthflare')!;
    final settings = (await isar.appSettings.get(1))!;
    expect(settings.schemaVersion, MigrationRunner.targetVersion);
    expect(settings.activeProfileId, manifest['activeProfileId']);
    expect(FailedUpgrade.read(docs), isNull);
    final snapshots = Directory(PreMigrationSnapshot.directoryPath(docs));
    expect(
      snapshots.listSync().where((f) => f.path.endsWith('.isar')),
      isNotEmpty,
      reason: 'the safety copy from before the upgrade',
    );

    final profiles = {
      for (final p in await isar.profileIsars.where().findAll())
        '${p.id}': p.name,
    };
    expect(profiles, manifest['profiles']);
    final kept = manifest['kept'] as Map;
    expect(
      await isar.journalEntryIsars.filter().profileIdLessThan(3).count(),
      kept['journalEntries'],
    );
    expect(await isar.doseLogIsars.count(), kept['doseLogs']);

    // And it's on screen: Sarah's journal entry.
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byTooltip('Journal'),
      ),
    );
    await _waitFor(tester, find.text('Rough day'));
    await binding.takeScreenshot('upgrade_from_${release}_journal');
    print('✓ Upgraded from $release on this device');
  });
}
