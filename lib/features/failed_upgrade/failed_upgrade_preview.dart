import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/database/failed_upgrade.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/database/pre_migration_snapshot.dart';

/// `--dart-define=FAILED_UPGRADE_PREVIEW=true` (debug builds only): open as
/// if an upgrade had stopped retrying, to see the card and Settings (#112).
/// Nothing in the data changes.
bool failedUpgradePreviewFromEnvironment() =>
    !kReleaseMode && const bool.fromEnvironment('FAILED_UPGRADE_PREVIEW');

/// A stopped failure whose safety copy is a fresh copy of the current data,
/// so trying "Restore" in the preview puts back exactly what's there.
Future<FailedUpgrade> previewFailedUpgrade(
  Isar isar,
  String documentsDir,
) async {
  final dir = Directory(PreMigrationSnapshot.directoryPath(documentsDir));
  if (!dir.existsSync()) await dir.create(recursive: true);
  final now = DateTime.now().toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  final stamp =
      '${now.year}${two(now.month)}${two(now.day)}T'
      '${two(now.hour)}${two(now.minute)}${two(now.second)}Z';
  final path = '${dir.path}/healthflare_pre_v16_$stamp.isar';
  if (File(path).existsSync()) await File(path).delete();
  await isar.copyToFile(path);
  return FailedUpgrade(
    appVersion: 'preview',
    fromVersion: 16,
    reachedVersion: 17,
    failedStep: 18,
    targetVersion: MigrationRunner.targetVersion,
    attempts: FailedUpgrade.maxAttempts,
    error: 'StateError: Bad state: preview, nothing failed',
    snapshotPath: path,
    snapshotTakenAt: now,
  );
}
