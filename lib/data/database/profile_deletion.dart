import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/activity_entry_isar.dart';
import 'package:health_flare/data/models/appointment_isar.dart';
import 'package:health_flare/data/models/daily_checkin_isar.dart';
import 'package:health_flare/data/models/dose_log_isar.dart';
import 'package:health_flare/data/models/elimination_entry_isar.dart';
import 'package:health_flare/data/models/flare_isar.dart';
import 'package:health_flare/data/models/fluid_intake_isar.dart';
import 'package:health_flare/data/models/journal_entry_isar.dart';
import 'package:health_flare/data/models/meal_entry_isar.dart';
import 'package:health_flare/data/models/medication_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/data/models/sleep_entry_isar.dart';
import 'package:health_flare/data/models/symptom_entry_isar.dart';
import 'package:health_flare/data/models/user_condition_isar.dart';
import 'package:health_flare/data/models/user_symptom_isar.dart';
import 'package:health_flare/data/models/vital_entry_isar.dart';

/// Number of collections that carry a `profileId` and must be cleared when
/// a profile is deleted. Kept in step with [deleteProfileData] and its test
/// (test/unit/providers/profile_delete_test.dart).
const profileScopedCollectionCount = 15;

/// Deletes every row that belongs to [profileId], in every profile-scoped
/// collection.
///
/// Must be called inside an `isar.writeTxn`, so the caller makes the whole
/// deletion (rows plus the profile itself) one atomic change: if anything
/// throws, nothing is deleted.
///
/// Shared catalogue rows (ConditionIsar, SymptomIsar) are not touched; they
/// carry no profileId and other profiles may use them.
///
/// When adding a collection with a `profileId`, add it here, bump
/// [profileScopedCollectionCount], and seed it in the test.
Future<void> deleteProfileData(Isar isar, int profileId) async {
  await isar.journalEntryIsars.filter().profileIdEqualTo(profileId).deleteAll();
  await isar.userConditionIsars
      .filter()
      .profileIdEqualTo(profileId)
      .deleteAll();
  await isar.userSymptomIsars.filter().profileIdEqualTo(profileId).deleteAll();
  await isar.sleepEntryIsars.filter().profileIdEqualTo(profileId).deleteAll();
  await isar.symptomEntryIsars.filter().profileIdEqualTo(profileId).deleteAll();
  await isar.vitalEntryIsars.filter().profileIdEqualTo(profileId).deleteAll();
  await isar.doseLogIsars.filter().profileIdEqualTo(profileId).deleteAll();
  await isar.medicationIsars.filter().profileIdEqualTo(profileId).deleteAll();
  await isar.mealEntryIsars.filter().profileIdEqualTo(profileId).deleteAll();
  await isar.flareIsars.filter().profileIdEqualTo(profileId).deleteAll();
  await isar.dailyCheckinIsars.filter().profileIdEqualTo(profileId).deleteAll();
  await isar.appointmentIsars.filter().profileIdEqualTo(profileId).deleteAll();
  await isar.activityEntryIsars
      .filter()
      .profileIdEqualTo(profileId)
      .deleteAll();
  await isar.fluidIntakeIsars.filter().profileIdEqualTo(profileId).deleteAll();
  await isar.eliminationEntryIsars
      .filter()
      .profileIdEqualTo(profileId)
      .deleteAll();
}

/// Deletes rows whose profileId matches no existing profile, and returns how
/// many orphaned profile ids were cleared.
///
/// Versions before v18 only removed journal entries when a profile was
/// deleted, so devices can hold health data for deleted profiles that no
/// screen shows but every backup carries. The v17 to v18 migration runs this
/// once. Must be called inside an `isar.writeTxn`.
///
/// Does nothing when no profiles exist at all: on a real device that state
/// means something else went wrong, and deleting everything would turn a bug
/// into data loss.
Future<int> deleteOrphanedProfileData(Isar isar) async {
  final liveIds = (await isar.profileIsars.where().idProperty().findAll())
      .toSet();
  if (liveIds.isEmpty) return 0;

  final orphanIds = <int>{};
  void collect(List<int> ids) =>
      orphanIds.addAll(ids.where((id) => !liveIds.contains(id)));

  collect(await isar.journalEntryIsars.where().profileIdProperty().findAll());
  collect(await isar.userConditionIsars.where().profileIdProperty().findAll());
  collect(await isar.userSymptomIsars.where().profileIdProperty().findAll());
  collect(await isar.sleepEntryIsars.where().profileIdProperty().findAll());
  collect(await isar.symptomEntryIsars.where().profileIdProperty().findAll());
  collect(await isar.vitalEntryIsars.where().profileIdProperty().findAll());
  collect(await isar.doseLogIsars.where().profileIdProperty().findAll());
  collect(await isar.medicationIsars.where().profileIdProperty().findAll());
  collect(await isar.mealEntryIsars.where().profileIdProperty().findAll());
  collect(await isar.flareIsars.where().profileIdProperty().findAll());
  collect(await isar.dailyCheckinIsars.where().profileIdProperty().findAll());
  collect(await isar.appointmentIsars.where().profileIdProperty().findAll());
  collect(await isar.activityEntryIsars.where().profileIdProperty().findAll());
  collect(await isar.fluidIntakeIsars.where().profileIdProperty().findAll());
  collect(
    await isar.eliminationEntryIsars.where().profileIdProperty().findAll(),
  );

  for (final id in orphanIds) {
    await deleteProfileData(isar, id);
  }
  return orphanIds.length;
}
