import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/data/database/failed_upgrade.dart';

// TODO(#112): stubs.
abstract class FailedUpgradeActions {
  String get platform;
  bool safetyCopyExists(String path);
  Future<String> saveBackupFirst();
  Future<void> share(String path);
  Future<void> exportBackup();
  Future<void> restore(String snapshotPath);
}

final failedUpgradeProvider = Provider<FailedUpgrade?>((ref) => null);

final failedUpgradeActionsProvider = Provider<FailedUpgradeActions>(
  (ref) => throw UnimplementedError(),
);
