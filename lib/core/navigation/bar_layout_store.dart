import 'package:isar_community/isar.dart';

import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/models/profile_isar.dart';

/// Reads and writes the bar on the [AppSettings] singleton (#137). The bar
/// is per device; which features are in use is per profile.
class BarLayoutStore {
  BarLayoutStore._();

  static Future<BarRecord> read(Isar isar) async {
    final s = await isar.appSettings.get(1);
    if (s == null) return const BarRecord();
    return BarRecord(
      storedBar: s.bottomBarIds,
      seenVersion: s.bottomBarLayoutVersion,
    );
  }

  static Future<void> write(Isar isar, BarRecord record) async {
    await isar.writeTxn(() async {
      final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
      s
        ..bottomBarIds = record.storedBar == null
            ? null
            : List.of(record.storedBar!)
        ..bottomBarLayoutVersion = record.seenVersion;
      await isar.appSettings.put(s);
    });
  }

  /// Applies [settleBarLaunch] and saves the result. Called from `main()`
  /// before onboarding can create a profile.
  static Future<BarRecord> settle(Isar isar, {required int current}) async {
    final before = await read(isar);
    final after = settleBarLaunch(
      before,
      current: current,
      hasProfiles: await isar.profileIsars.count() > 0,
    );
    if (after != before) await write(isar, after);
    return after;
  }
}
