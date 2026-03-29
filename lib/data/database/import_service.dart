import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:health_flare/data/models/activity_entry_isar.dart';
import 'package:health_flare/data/models/appointment_isar.dart';
import 'package:health_flare/data/models/condition_isar.dart';
import 'package:health_flare/data/models/daily_checkin_isar.dart';
import 'package:health_flare/data/models/dose_log_isar.dart';
import 'package:health_flare/data/models/flare_isar.dart';
import 'package:health_flare/data/models/journal_entry_isar.dart';
import 'package:health_flare/data/models/meal_entry_isar.dart';
import 'package:health_flare/data/models/medication_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/data/models/sleep_entry_isar.dart';
import 'package:health_flare/data/models/symptom_entry_isar.dart';
import 'package:health_flare/data/models/symptom_isar.dart';
import 'package:health_flare/data/models/user_condition_isar.dart';
import 'package:health_flare/data/models/user_symptom_isar.dart';
import 'package:health_flare/data/models/vital_entry_isar.dart';
import 'package:health_flare/data/database/app_settings.dart';

/// A single importable data category shown in the selective-import UI.
class ImportCategoryInfo {
  const ImportCategoryInfo({
    required this.id,
    required this.label,
    required this.count,
    this.selected = true,
  });

  /// Stable identifier used to filter which categories to import.
  final String id;

  /// Human-readable label shown in the category picker.
  final String label;

  /// Number of records from the backup that do not already exist in the
  /// main database (new records only — existing ones are skipped).
  final int count;

  /// Whether the user has selected this category for import.
  final bool selected;

  ImportCategoryInfo copyWith({bool? selected}) => ImportCategoryInfo(
    id: id,
    label: label,
    count: count,
    selected: selected ?? this.selected,
  );
}

/// Category identifiers — stable strings used by [ImportService].
abstract final class ImportCategoryId {
  static const profiles = 'profiles';
  static const trackedConditions = 'trackedConditions';
  static const trackedSymptoms = 'trackedSymptoms';
  static const journal = 'journal';
  static const sleep = 'sleep';
  static const vitals = 'vitals';
  static const meals = 'meals';
  static const flares = 'flares';
  static const checkins = 'checkins';
  static const appointments = 'appointments';
  static const activity = 'activity';
  static const medications = 'medications';
  static const doseLogs = 'doseLogs';
  static const symptomEntries = 'symptomEntries';
}

/// Merges data from an Isar backup file into the live database.
///
/// All import modes (merge-all and selective) use this service.
/// The "overwrite" mode is handled separately by [BackupService] via staged
/// restore (requires app restart).
///
/// ## Deduplication
/// Records are identified by a per-collection fingerprint (profile-scoped
/// timestamp or content hash) rather than their Isar auto-increment ID, so
/// restoring from an older backup won't create duplicates.
///
/// ## FK remapping
/// The backup's Isar auto-increment IDs differ from the main database's IDs
/// for the same logical records. This service builds ID-mapping tables as it
/// imports each collection and uses them when writing FK fields on dependent
/// collections.
class ImportService {
  ImportService._();

  static const _importDbName = 'import_preview';

  // ── Isar lifecycle ────────────────────────────────────────────────────────

  static Future<Isar> _openBackup(String backupFilePath) async {
    final tmp = await getTemporaryDirectory();
    final importPath = '${tmp.path}/$_importDbName.isar';
    // Always start from a fresh copy so we never corrupt the user's backup.
    await File(backupFilePath).copy(importPath);
    return Isar.open(
      [
        ProfileIsarSchema,
        JournalEntryIsarSchema,
        AppSettingsSchema,
        ConditionIsarSchema,
        UserConditionIsarSchema,
        SymptomIsarSchema,
        UserSymptomIsarSchema,
        SleepEntryIsarSchema,
        SymptomEntryIsarSchema,
        VitalEntryIsarSchema,
        MedicationIsarSchema,
        DoseLogIsarSchema,
        MealEntryIsarSchema,
        FlareIsarSchema,
        DailyCheckinIsarSchema,
        AppointmentIsarSchema,
        ActivityEntryIsarSchema,
      ],
      directory: tmp.path,
      name: _importDbName,
    );
  }

  static Future<void> _closeBackup(Isar backup) async {
    await backup.close();
    final tmp = await getTemporaryDirectory();
    final importPath = '${tmp.path}/$_importDbName.isar';
    final f = File(importPath);
    if (f.existsSync()) await f.delete();
    final lock = File('$importPath.lock');
    if (lock.existsSync()) await lock.delete();
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Opens [backupPath] and returns categories with counts of records that
  /// would be added (not already in [main]).
  ///
  /// Only categories with at least one new record are returned.
  static Future<List<ImportCategoryInfo>> preview(
    String backupPath,
    Isar main,
  ) async {
    final backup = await _openBackup(backupPath);
    try {
      final ctx = _Ctx(main: main, backup: backup);
      await ctx.buildProfileMap();

      final categories = <ImportCategoryInfo>[];

      Future<void> add(
        String id,
        String label,
        Future<int> Function() count,
      ) async {
        final n = await count();
        if (n > 0) {
          categories.add(ImportCategoryInfo(id: id, label: label, count: n));
        }
      }

      await add(ImportCategoryId.profiles, 'Profiles', ctx.countNewProfiles);
      await add(
        ImportCategoryId.trackedConditions,
        'Tracked conditions',
        ctx.countNewUserConditions,
      );
      await add(
        ImportCategoryId.trackedSymptoms,
        'Tracked symptoms',
        ctx.countNewUserSymptoms,
      );
      await add(
        ImportCategoryId.journal,
        'Journal entries',
        ctx.countNewJournal,
      );
      await add(ImportCategoryId.sleep, 'Sleep records', ctx.countNewSleep);
      await add(ImportCategoryId.vitals, 'Vital signs', ctx.countNewVitals);
      await add(ImportCategoryId.meals, 'Meal entries', ctx.countNewMeals);
      await add(ImportCategoryId.flares, 'Flare episodes', ctx.countNewFlares);
      await add(
        ImportCategoryId.checkins,
        'Daily check-ins',
        ctx.countNewCheckins,
      );
      await add(
        ImportCategoryId.appointments,
        'Appointments',
        ctx.countNewAppointments,
      );
      await add(
        ImportCategoryId.activity,
        'Activity entries',
        ctx.countNewActivity,
      );
      await add(
        ImportCategoryId.medications,
        'Medications',
        ctx.countNewMedications,
      );
      await add(ImportCategoryId.doseLogs, 'Dose logs', ctx.countNewDoseLogs);
      await add(
        ImportCategoryId.symptomEntries,
        'Symptom entries',
        ctx.countNewSymptomEntries,
      );

      return categories;
    } finally {
      await _closeBackup(backup);
    }
  }

  /// Imports all data from [backupPath] into [main], skipping duplicates.
  ///
  /// Returns the total number of records added.
  static Future<int> mergeAll(String backupPath, Isar main) async {
    final backup = await _openBackup(backupPath);
    try {
      return await _Ctx(main: main, backup: backup).importAll(null);
    } finally {
      await _closeBackup(backup);
    }
  }

  /// Imports only the [selectedCategories] from [backupPath] into [main].
  ///
  /// Returns the total number of records added.
  static Future<int> mergeSelected(
    String backupPath,
    Isar main,
    Set<String> selectedCategories,
  ) async {
    final backup = await _openBackup(backupPath);
    try {
      return await _Ctx(
        main: main,
        backup: backup,
      ).importAll(selectedCategories);
    } finally {
      await _closeBackup(backup);
    }
  }
}

// ── Internal context ──────────────────────────────────────────────────────

class _Ctx {
  _Ctx({required this.main, required this.backup});

  final Isar main;
  final Isar backup;

  /// backup profileId → main profileId
  final Map<int, int> profileMap = {};

  /// backup flareId → main flareId
  final Map<int, int> flareMap = {};

  /// backup medicationId → main medicationId
  final Map<int, int> medicationMap = {};

  /// backup userSymptomId → main userSymptomId
  final Map<int, int> userSymptomMap = {};

  /// backup userConditionId → main userConditionId
  final Map<int, int> userConditionMap = {};

  // ── Profile map ─────────────────────────────────────────────────────────

  Future<void> buildProfileMap() async {
    final backupProfiles = await backup.profileIsars.where().findAll();
    final mainProfiles = await main.profileIsars.where().findAll();
    final mainByName = {
      for (final p in mainProfiles) p.name.toLowerCase().trim(): p.id,
    };
    for (final bp in backupProfiles) {
      final key = bp.name.toLowerCase().trim();
      if (mainByName.containsKey(key)) {
        profileMap[bp.id] = mainByName[key]!;
      }
    }
  }

  // ── Count helpers ────────────────────────────────────────────────────────

  Future<int> countNewProfiles() async {
    final backupProfiles = await backup.profileIsars.where().findAll();
    final mainNames = (await main.profileIsars.where().findAll())
        .map((p) => p.name.toLowerCase().trim())
        .toSet();
    return backupProfiles
        .where((p) => !mainNames.contains(p.name.toLowerCase().trim()))
        .length;
  }

  Future<int> countNewUserConditions() async {
    final backupItems = await backup.userConditionIsars.where().findAll();
    final mainSet = (await main.userConditionIsars.where().findAll())
        .map((u) => '${u.profileId}_${u.conditionId}')
        .toSet();
    return backupItems.where((u) {
      final pid = profileMap[u.profileId];
      if (pid == null) return false;
      return !mainSet.contains('${pid}_${u.conditionId}');
    }).length;
  }

  Future<int> countNewUserSymptoms() async {
    final backupItems = await backup.userSymptomIsars.where().findAll();
    final mainSet = (await main.userSymptomIsars.where().findAll())
        .map((u) => '${u.profileId}_${u.symptomId}')
        .toSet();
    return backupItems.where((u) {
      final pid = profileMap[u.profileId];
      if (pid == null) return false;
      return !mainSet.contains('${pid}_${u.symptomId}');
    }).length;
  }

  Future<int> countNewJournal() async {
    final backupItems = await backup.journalEntryIsars.where().findAll();
    final mainSet = (await main.journalEntryIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.createdAt.millisecondsSinceEpoch}')
        .toSet();
    return backupItems.where((e) {
      final pid = profileMap[e.profileId];
      if (pid == null) return false;
      return !mainSet.contains('${pid}_${e.createdAt.millisecondsSinceEpoch}');
    }).length;
  }

  Future<int> countNewSleep() async {
    final backupItems = await backup.sleepEntryIsars.where().findAll();
    final mainSet = (await main.sleepEntryIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.bedtime.millisecondsSinceEpoch}')
        .toSet();
    return backupItems.where((e) {
      final pid = profileMap[e.profileId];
      if (pid == null) return false;
      return !mainSet.contains('${pid}_${e.bedtime.millisecondsSinceEpoch}');
    }).length;
  }

  Future<int> countNewVitals() async {
    final backupItems = await backup.vitalEntryIsars.where().findAll();
    final mainSet = (await main.vitalEntryIsars.where().findAll())
        .map(
          (e) =>
              '${e.profileId}_${e.loggedAt.millisecondsSinceEpoch}_${e.vitalType}',
        )
        .toSet();
    return backupItems.where((e) {
      final pid = profileMap[e.profileId];
      if (pid == null) return false;
      return !mainSet.contains(
        '${pid}_${e.loggedAt.millisecondsSinceEpoch}_${e.vitalType}',
      );
    }).length;
  }

  Future<int> countNewMeals() async {
    final backupItems = await backup.mealEntryIsars.where().findAll();
    final mainSet = (await main.mealEntryIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.loggedAt.millisecondsSinceEpoch}')
        .toSet();
    return backupItems.where((e) {
      final pid = profileMap[e.profileId];
      if (pid == null) return false;
      return !mainSet.contains('${pid}_${e.loggedAt.millisecondsSinceEpoch}');
    }).length;
  }

  Future<int> countNewFlares() async {
    final backupItems = await backup.flareIsars.where().findAll();
    final mainSet = (await main.flareIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.startedAt.millisecondsSinceEpoch}')
        .toSet();
    return backupItems.where((e) {
      final pid = profileMap[e.profileId];
      if (pid == null) return false;
      return !mainSet.contains('${pid}_${e.startedAt.millisecondsSinceEpoch}');
    }).length;
  }

  Future<int> countNewCheckins() async {
    final backupItems = await backup.dailyCheckinIsars.where().findAll();
    final mainSet = (await main.dailyCheckinIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.checkinDate.millisecondsSinceEpoch}')
        .toSet();
    return backupItems.where((e) {
      final pid = profileMap[e.profileId];
      if (pid == null) return false;
      return !mainSet.contains(
        '${pid}_${e.checkinDate.millisecondsSinceEpoch}',
      );
    }).length;
  }

  Future<int> countNewAppointments() async {
    final backupItems = await backup.appointmentIsars.where().findAll();
    final mainSet = (await main.appointmentIsars.where().findAll())
        .map(
          (e) =>
              '${e.profileId}_${e.scheduledAt.millisecondsSinceEpoch}_${e.title}',
        )
        .toSet();
    return backupItems.where((e) {
      final pid = profileMap[e.profileId];
      if (pid == null) return false;
      return !mainSet.contains(
        '${pid}_${e.scheduledAt.millisecondsSinceEpoch}_${e.title}',
      );
    }).length;
  }

  Future<int> countNewActivity() async {
    final backupItems = await backup.activityEntryIsars.where().findAll();
    final mainSet = (await main.activityEntryIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.loggedAt.millisecondsSinceEpoch}')
        .toSet();
    return backupItems.where((e) {
      final pid = profileMap[e.profileId];
      if (pid == null) return false;
      return !mainSet.contains('${pid}_${e.loggedAt.millisecondsSinceEpoch}');
    }).length;
  }

  Future<int> countNewMedications() async {
    final backupItems = await backup.medicationIsars.where().findAll();
    final mainSet = (await main.medicationIsars.where().findAll())
        .map((m) => '${m.profileId}_${m.name.toLowerCase().trim()}')
        .toSet();
    return backupItems.where((m) {
      final pid = profileMap[m.profileId];
      if (pid == null) return false;
      return !mainSet.contains('${pid}_${m.name.toLowerCase().trim()}');
    }).length;
  }

  Future<int> countNewDoseLogs() async {
    final backupItems = await backup.doseLogIsars.where().findAll();
    final mainSet = (await main.doseLogIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.loggedAt.millisecondsSinceEpoch}')
        .toSet();
    return backupItems.where((e) {
      final pid = profileMap[e.profileId];
      if (pid == null) return false;
      return !mainSet.contains('${pid}_${e.loggedAt.millisecondsSinceEpoch}');
    }).length;
  }

  Future<int> countNewSymptomEntries() async {
    final backupItems = await backup.symptomEntryIsars.where().findAll();
    final mainSet = (await main.symptomEntryIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.loggedAt.millisecondsSinceEpoch}')
        .toSet();
    return backupItems.where((e) {
      final pid = profileMap[e.profileId];
      if (pid == null) return false;
      return !mainSet.contains('${pid}_${e.loggedAt.millisecondsSinceEpoch}');
    }).length;
  }

  // ── Import ───────────────────────────────────────────────────────────────

  /// Runs the full import pipeline. [filter] is the set of category IDs to
  /// include; null means import everything.
  Future<int> importAll(Set<String>? filter) async {
    await buildProfileMap();
    int total = 0;

    bool include(String id) => filter == null || filter.contains(id);

    // Order matters: referenced collections before referencing ones.
    if (include(ImportCategoryId.profiles)) {
      total += await _importProfiles();
    }
    if (include(ImportCategoryId.trackedConditions)) {
      total += await _importUserConditions();
    }
    if (include(ImportCategoryId.trackedSymptoms)) {
      total += await _importUserSymptoms();
    }
    if (include(ImportCategoryId.flares)) {
      total += await _importFlares();
    }
    if (include(ImportCategoryId.medications)) {
      total += await _importMedications();
    }
    if (include(ImportCategoryId.journal)) {
      total += await _importJournal();
    }
    if (include(ImportCategoryId.sleep)) {
      total += await _importSleep();
    }
    if (include(ImportCategoryId.vitals)) {
      total += await _importVitals();
    }
    if (include(ImportCategoryId.meals)) {
      total += await _importMeals();
    }
    if (include(ImportCategoryId.checkins)) {
      total += await _importCheckins();
    }
    if (include(ImportCategoryId.appointments)) {
      total += await _importAppointments();
    }
    if (include(ImportCategoryId.activity)) {
      total += await _importActivity();
    }
    if (include(ImportCategoryId.doseLogs)) {
      total += await _importDoseLogs();
    }
    if (include(ImportCategoryId.symptomEntries)) {
      total += await _importSymptomEntries();
    }

    return total;
  }

  Future<int> _importProfiles() async {
    final backupProfiles = await backup.profileIsars.where().findAll();
    final mainProfiles = await main.profileIsars.where().findAll();
    final mainByName = {
      for (final p in mainProfiles) p.name.toLowerCase().trim(): p.id,
    };

    int added = 0;
    for (final bp in backupProfiles) {
      final key = bp.name.toLowerCase().trim();
      if (mainByName.containsKey(key)) continue; // already mapped
      final newProfile = ProfileIsar()
        ..name = bp.name
        ..dateOfBirth = bp.dateOfBirth
        ..avatarPath = bp.avatarPath
        ..firstLogShown = bp.firstLogShown
        ..weatherTrackingEnabled = bp.weatherTrackingEnabled
        ..weatherOptInShown = bp.weatherOptInShown
        ..colorSeed = bp.colorSeed
        ..cycleTrackingEnabled = bp.cycleTrackingEnabled;
      await main.writeTxn(() async {
        final newId = await main.profileIsars.put(newProfile);
        profileMap[bp.id] = newId;
      });
      added++;
    }
    return added;
  }

  Future<int> _importUserConditions() async {
    final backupItems = await backup.userConditionIsars.where().findAll();
    final mainSet = (await main.userConditionIsars.where().findAll())
        .map((u) => '${u.profileId}_${u.conditionId}')
        .toSet();

    final toInsert = <UserConditionIsar>[];
    final backupIdToIndex = <int, int>{};

    for (final bu in backupItems) {
      final pid = profileMap[bu.profileId];
      if (pid == null) continue;
      if (mainSet.contains('${pid}_${bu.conditionId}')) {
        final existing = await main.userConditionIsars
            .filter()
            .profileIdEqualTo(pid)
            .and()
            .conditionIdEqualTo(bu.conditionId)
            .findFirst();
        if (existing != null) userConditionMap[bu.id] = existing.id;
        continue;
      }
      backupIdToIndex[bu.id] = toInsert.length;
      toInsert.add(
        UserConditionIsar()
          ..profileId = pid
          ..conditionId = bu.conditionId
          ..conditionName = bu.conditionName
          ..trackedSince = bu.trackedSince
          ..diagnosedAt = bu.diagnosedAt
          ..notes = bu.notes,
      );
    }

    if (toInsert.isNotEmpty) {
      await main.writeTxn(() async {
        final ids = await main.userConditionIsars.putAll(toInsert);
        for (final entry in backupIdToIndex.entries) {
          userConditionMap[entry.key] = ids[entry.value];
        }
      });
    }
    return toInsert.length;
  }

  Future<int> _importUserSymptoms() async {
    final backupItems = await backup.userSymptomIsars.where().findAll();
    final mainSet = (await main.userSymptomIsars.where().findAll())
        .map((u) => '${u.profileId}_${u.symptomId}')
        .toSet();

    final toInsert = <UserSymptomIsar>[];
    final backupIdToIndex = <int, int>{};

    for (final bu in backupItems) {
      final pid = profileMap[bu.profileId];
      if (pid == null) continue;
      if (mainSet.contains('${pid}_${bu.symptomId}')) {
        final existing = await main.userSymptomIsars
            .filter()
            .profileIdEqualTo(pid)
            .and()
            .symptomIdEqualTo(bu.symptomId)
            .findFirst();
        if (existing != null) userSymptomMap[bu.id] = existing.id;
        continue;
      }
      backupIdToIndex[bu.id] = toInsert.length;
      toInsert.add(
        UserSymptomIsar()
          ..profileId = pid
          ..symptomId = bu.symptomId
          ..symptomName = bu.symptomName
          ..trackedSince = bu.trackedSince,
      );
    }

    if (toInsert.isNotEmpty) {
      await main.writeTxn(() async {
        final ids = await main.userSymptomIsars.putAll(toInsert);
        for (final entry in backupIdToIndex.entries) {
          userSymptomMap[entry.key] = ids[entry.value];
        }
      });
    }
    return toInsert.length;
  }

  Future<int> _importFlares() async {
    final backupItems = await backup.flareIsars.where().findAll();
    final mainSet = (await main.flareIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.startedAt.millisecondsSinceEpoch}')
        .toSet();

    final toInsert = <FlareIsar>[];
    final backupIdToIndex = <int, int>{};

    for (final bf in backupItems) {
      final pid = profileMap[bf.profileId];
      if (pid == null) continue;
      if (mainSet.contains('${pid}_${bf.startedAt.millisecondsSinceEpoch}')) {
        final existing = await main.flareIsars
            .filter()
            .profileIdEqualTo(pid)
            .and()
            .startedAtEqualTo(bf.startedAt)
            .findFirst();
        if (existing != null) flareMap[bf.id] = existing.id;
        continue;
      }
      backupIdToIndex[bf.id] = toInsert.length;
      toInsert.add(
        FlareIsar()
          ..profileId = pid
          ..startedAt = bf.startedAt
          ..endedAt = bf.endedAt
          ..initialSeverity = bf.initialSeverity
          ..peakSeverity = bf.peakSeverity
          ..notes = bf.notes
          ..createdAt = bf.createdAt,
      );
    }

    if (toInsert.isNotEmpty) {
      await main.writeTxn(() async {
        final ids = await main.flareIsars.putAll(toInsert);
        for (final entry in backupIdToIndex.entries) {
          flareMap[entry.key] = ids[entry.value];
        }
      });
    }
    return toInsert.length;
  }

  Future<int> _importMedications() async {
    final backupItems = await backup.medicationIsars.where().findAll();
    final mainSet = (await main.medicationIsars.where().findAll())
        .map((m) => '${m.profileId}_${m.name.toLowerCase().trim()}')
        .toSet();

    final toInsert = <MedicationIsar>[];
    final backupIdToIndex = <int, int>{};

    for (final bm in backupItems) {
      final pid = profileMap[bm.profileId];
      if (pid == null) continue;
      if (mainSet.contains('${pid}_${bm.name.toLowerCase().trim()}')) {
        final existing = await main.medicationIsars
            .filter()
            .profileIdEqualTo(pid)
            .and()
            .nameEqualTo(bm.name, caseSensitive: false)
            .findFirst();
        if (existing != null) medicationMap[bm.id] = existing.id;
        continue;
      }
      backupIdToIndex[bm.id] = toInsert.length;
      toInsert.add(
        MedicationIsar()
          ..profileId = pid
          ..name = bm.name
          ..medicationType = bm.medicationType
          ..doseAmount = bm.doseAmount
          ..doseUnit = bm.doseUnit
          ..frequency = bm.frequency
          ..frequencyLabel = bm.frequencyLabel
          ..startDate = bm.startDate
          ..endDate = bm.endDate
          ..notes = bm.notes
          ..createdAt = bm.createdAt
          ..updatedAt = bm.updatedAt,
      );
    }

    if (toInsert.isNotEmpty) {
      await main.writeTxn(() async {
        final ids = await main.medicationIsars.putAll(toInsert);
        for (final entry in backupIdToIndex.entries) {
          medicationMap[entry.key] = ids[entry.value];
        }
      });
    }
    return toInsert.length;
  }

  Future<int> _importJournal() async {
    final backupItems = await backup.journalEntryIsars.where().findAll();
    final mainSet = (await main.journalEntryIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.createdAt.millisecondsSinceEpoch}')
        .toSet();

    final toInsert = <JournalEntryIsar>[];
    for (final be in backupItems) {
      final pid = profileMap[be.profileId];
      if (pid == null) continue;
      if (mainSet.contains('${pid}_${be.createdAt.millisecondsSinceEpoch}')) {
        continue;
      }
      toInsert.add(
        JournalEntryIsar()
          ..profileId = pid
          ..createdAt = be.createdAt
          ..snapshots = be.snapshots,
      );
    }

    if (toInsert.isNotEmpty) {
      await main.writeTxn(() async => main.journalEntryIsars.putAll(toInsert));
    }
    return toInsert.length;
  }

  Future<int> _importSleep() async {
    final backupItems = await backup.sleepEntryIsars.where().findAll();
    final mainSet = (await main.sleepEntryIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.bedtime.millisecondsSinceEpoch}')
        .toSet();

    final toInsert = <SleepEntryIsar>[];
    for (final be in backupItems) {
      final pid = profileMap[be.profileId];
      if (pid == null) continue;
      if (mainSet.contains('${pid}_${be.bedtime.millisecondsSinceEpoch}')) {
        continue;
      }
      toInsert.add(
        SleepEntryIsar()
          ..profileId = pid
          ..bedtime = be.bedtime
          ..wakeTime = be.wakeTime
          ..qualityRating = be.qualityRating
          ..notes = be.notes
          ..isNap = be.isNap
          ..createdAt = be.createdAt,
      );
    }

    if (toInsert.isNotEmpty) {
      await main.writeTxn(() async => main.sleepEntryIsars.putAll(toInsert));
    }
    return toInsert.length;
  }

  Future<int> _importVitals() async {
    final backupItems = await backup.vitalEntryIsars.where().findAll();
    final mainSet = (await main.vitalEntryIsars.where().findAll())
        .map(
          (e) =>
              '${e.profileId}_${e.loggedAt.millisecondsSinceEpoch}_${e.vitalType}',
        )
        .toSet();

    final toInsert = <VitalEntryIsar>[];
    for (final be in backupItems) {
      final pid = profileMap[be.profileId];
      if (pid == null) continue;
      final fp = '${pid}_${be.loggedAt.millisecondsSinceEpoch}_${be.vitalType}';
      if (mainSet.contains(fp)) continue;
      toInsert.add(
        VitalEntryIsar()
          ..profileId = pid
          ..vitalType = be.vitalType
          ..value = be.value
          ..value2 = be.value2
          ..unit = be.unit
          ..notes = be.notes
          ..loggedAt = be.loggedAt
          ..createdAt = be.createdAt
          ..flareIsarId = be.flareIsarId != null
              ? flareMap[be.flareIsarId]
              : null,
      );
    }

    if (toInsert.isNotEmpty) {
      await main.writeTxn(() async => main.vitalEntryIsars.putAll(toInsert));
    }
    return toInsert.length;
  }

  Future<int> _importMeals() async {
    final backupItems = await backup.mealEntryIsars.where().findAll();
    final mainSet = (await main.mealEntryIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.loggedAt.millisecondsSinceEpoch}')
        .toSet();

    final toInsert = <MealEntryIsar>[];
    for (final be in backupItems) {
      final pid = profileMap[be.profileId];
      if (pid == null) continue;
      if (mainSet.contains('${pid}_${be.loggedAt.millisecondsSinceEpoch}')) {
        continue;
      }
      toInsert.add(
        MealEntryIsar()
          ..profileId = pid
          ..description = be.description
          ..hasReaction = be.hasReaction
          ..notes = be.notes
          ..loggedAt = be.loggedAt
          ..createdAt = be.createdAt
          ..flareIsarId = be.flareIsarId != null
              ? flareMap[be.flareIsarId]
              : null,
      );
    }

    if (toInsert.isNotEmpty) {
      await main.writeTxn(() async => main.mealEntryIsars.putAll(toInsert));
    }
    return toInsert.length;
  }

  Future<int> _importCheckins() async {
    final backupItems = await backup.dailyCheckinIsars.where().findAll();
    final mainSet = (await main.dailyCheckinIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.checkinDate.millisecondsSinceEpoch}')
        .toSet();

    final toInsert = <DailyCheckinIsar>[];
    for (final be in backupItems) {
      final pid = profileMap[be.profileId];
      if (pid == null) continue;
      if (mainSet.contains('${pid}_${be.checkinDate.millisecondsSinceEpoch}')) {
        continue;
      }
      toInsert.add(
        DailyCheckinIsar()
          ..profileId = pid
          ..checkinDate = be.checkinDate
          ..wellbeing = be.wellbeing
          ..stressLevel = be.stressLevel
          ..cyclePhase = be.cyclePhase
          ..notes = be.notes
          ..createdAt = be.createdAt
          ..updatedAt = be.updatedAt,
      );
    }

    if (toInsert.isNotEmpty) {
      await main.writeTxn(() async => main.dailyCheckinIsars.putAll(toInsert));
    }
    return toInsert.length;
  }

  Future<int> _importAppointments() async {
    final backupItems = await backup.appointmentIsars.where().findAll();
    final mainSet = (await main.appointmentIsars.where().findAll())
        .map(
          (e) =>
              '${e.profileId}_${e.scheduledAt.millisecondsSinceEpoch}_${e.title}',
        )
        .toSet();

    final toInsert = <AppointmentIsar>[];
    for (final be in backupItems) {
      final pid = profileMap[be.profileId];
      if (pid == null) continue;
      final fp = '${pid}_${be.scheduledAt.millisecondsSinceEpoch}_${be.title}';
      if (mainSet.contains(fp)) continue;

      // Remap linkedMedicationIsarId inside medication changes.
      final remappedChanges = be.medicationChanges.map((mc) {
        return MedicationChangeIsar()
          ..changeId = mc.changeId
          ..description = mc.description
          ..linkedMedicationIsarId = mc.linkedMedicationIsarId != null
              ? medicationMap[mc.linkedMedicationIsarId]
              : null;
      }).toList();

      toInsert.add(
        AppointmentIsar()
          ..profileId = pid
          ..title = be.title
          ..providerName = be.providerName
          ..scheduledAt = be.scheduledAt
          ..status = be.status
          ..questions = be.questions
          ..medicationChanges = remappedChanges
          ..createdAt = be.createdAt,
      );
    }

    if (toInsert.isNotEmpty) {
      await main.writeTxn(() async => main.appointmentIsars.putAll(toInsert));
    }
    return toInsert.length;
  }

  Future<int> _importActivity() async {
    final backupItems = await backup.activityEntryIsars.where().findAll();
    final mainSet = (await main.activityEntryIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.loggedAt.millisecondsSinceEpoch}')
        .toSet();

    final toInsert = <ActivityEntryIsar>[];
    for (final be in backupItems) {
      final pid = profileMap[be.profileId];
      if (pid == null) continue;
      if (mainSet.contains('${pid}_${be.loggedAt.millisecondsSinceEpoch}')) {
        continue;
      }
      toInsert.add(
        ActivityEntryIsar()
          ..profileId = pid
          ..description = be.description
          ..activityType = be.activityType
          ..effortLevel = be.effortLevel
          ..durationMinutes = be.durationMinutes
          ..loggedAt = be.loggedAt
          ..createdAt = be.createdAt
          ..flareIsarId = be.flareIsarId != null
              ? flareMap[be.flareIsarId]
              : null,
      );
    }

    if (toInsert.isNotEmpty) {
      await main.writeTxn(() async => main.activityEntryIsars.putAll(toInsert));
    }
    return toInsert.length;
  }

  Future<int> _importDoseLogs() async {
    final backupItems = await backup.doseLogIsars.where().findAll();
    final mainSet = (await main.doseLogIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.loggedAt.millisecondsSinceEpoch}')
        .toSet();

    final toInsert = <DoseLogIsar>[];
    for (final bd in backupItems) {
      final pid = profileMap[bd.profileId];
      if (pid == null) continue;
      if (mainSet.contains('${pid}_${bd.loggedAt.millisecondsSinceEpoch}')) {
        continue;
      }

      // Resolve medication FK — skip dose log if medication was not imported.
      final mainMedId = medicationMap[bd.medicationIsarId];
      if (mainMedId == null) continue;

      toInsert.add(
        DoseLogIsar()
          ..profileId = pid
          ..medicationIsarId = mainMedId
          ..loggedAt = bd.loggedAt
          ..createdAt = bd.createdAt
          ..amount = bd.amount
          ..unit = bd.unit
          ..status = bd.status
          ..reason = bd.reason
          ..effectiveness = bd.effectiveness
          ..notes = bd.notes
          ..flareIsarId = bd.flareIsarId != null
              ? flareMap[bd.flareIsarId]
              : null,
      );
    }

    if (toInsert.isNotEmpty) {
      await main.writeTxn(() async => main.doseLogIsars.putAll(toInsert));
    }
    return toInsert.length;
  }

  Future<int> _importSymptomEntries() async {
    final backupItems = await backup.symptomEntryIsars.where().findAll();
    final mainSet = (await main.symptomEntryIsars.where().findAll())
        .map((e) => '${e.profileId}_${e.loggedAt.millisecondsSinceEpoch}')
        .toSet();

    final toInsert = <SymptomEntryIsar>[];
    for (final be in backupItems) {
      final pid = profileMap[be.profileId];
      if (pid == null) continue;
      if (mainSet.contains('${pid}_${be.loggedAt.millisecondsSinceEpoch}')) {
        continue;
      }
      toInsert.add(
        SymptomEntryIsar()
          ..profileId = pid
          ..name = be.name
          ..severity = be.severity
          ..notes = be.notes
          ..loggedAt = be.loggedAt
          ..createdAt = be.createdAt
          ..userSymptomIsarId = be.userSymptomIsarId != null
              ? userSymptomMap[be.userSymptomIsarId]
              : null
          ..userConditionIsarId = be.userConditionIsarId != null
              ? userConditionMap[be.userConditionIsarId]
              : null
          ..flareIsarId = be.flareIsarId != null
              ? flareMap[be.flareIsarId]
              : null,
      );
    }

    if (toInsert.isNotEmpty) {
      await main.writeTxn(() async => main.symptomEntryIsars.putAll(toInsert));
    }
    return toInsert.length;
  }
}
