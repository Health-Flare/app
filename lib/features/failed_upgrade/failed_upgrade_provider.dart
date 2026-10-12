import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:health_flare/core/providers/app_lock_provider.dart';
import 'package:health_flare/core/providers/backup_provider.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/backup_service.dart';
import 'package:health_flare/data/database/failed_upgrade.dart';

/// The upgrade that stopped retrying this launch (#112), or null. `main()`
/// overrides it from [IsarService.lastMigration].
final failedUpgradeProvider = Provider<FailedUpgrade?>((ref) => null);

/// What the card and the Settings section do. Overridden in widget tests.
abstract class FailedUpgradeActions {
  /// For "Copy details": the OS and its version.
  String get platform;

  bool safetyCopyExists(String path);

  /// Saves a backup of the current data on the phone, before a restore.
  /// Returns its path.
  Future<String> saveBackupFirst();

  Future<void> share(String path);

  /// "Export a backup": the normal export, with the share sheet.
  Future<void> exportBackup();

  /// Stages [snapshotPath] to replace the data on the next launch.
  Future<void> restore(String snapshotPath);
}

final failedUpgradeActionsProvider = Provider<FailedUpgradeActions>(
  _AppFailedUpgradeActions.new,
);

class _AppFailedUpgradeActions implements FailedUpgradeActions {
  _AppFailedUpgradeActions(this.ref);

  final Ref ref;

  @override
  String get platform =>
      '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';

  @override
  bool safetyCopyExists(String path) => File(path).existsSync();

  @override
  Future<String> saveBackupFirst() async {
    final exported = await BackupService.export(ref.read(isarProvider));
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/backups');
    if (!dir.existsSync()) await dir.create(recursive: true);
    final stamp = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll(RegExp(r'[-:]'), '')
        .split('.')
        .first;
    final path = '${dir.path}/healthflare_before_restore_${stamp}Z.isar';
    // Out of temp (swept at launch) into documents, where it stays.
    await File(exported).copy(path);
    await File(exported).delete();
    return path;
  }

  @override
  Future<void> share(String path) => ref
      .read(appLockProvider.notifier)
      .whileAway(
        () => SharePlus.instance.share(
          ShareParams(files: [XFile(path)], subject: 'Health Flare backup'),
        ),
      );

  @override
  Future<void> exportBackup() => ref.read(backupProvider.notifier).export();

  @override
  Future<void> restore(String snapshotPath) =>
      ref.read(backupProvider.notifier).restoreSafetyCopy(snapshotPath);
}
