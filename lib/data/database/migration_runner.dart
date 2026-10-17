import 'package:isar_community/isar.dart';

import 'package:health_flare/core/files/photo_store.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/profile_deletion.dart';
import 'package:health_flare/data/database/profile_ids.dart';
import 'package:health_flare/data/models/activity_entry_isar.dart';
import 'package:health_flare/data/models/condition_isar.dart';
import 'package:health_flare/data/models/dose_log_isar.dart';
import 'package:health_flare/data/models/flare_isar.dart';
import 'package:health_flare/data/models/meal_entry_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/data/models/symptom_entry_isar.dart';
import 'package:health_flare/data/models/symptom_isar.dart';
import 'package:health_flare/data/models/vital_entry_isar.dart';
import 'package:health_flare/data/seed_data.dart';
import 'package:health_flare/models/flare_membership.dart';

/// Runs any pending data migrations after the Isar database is opened.
///
/// Schema v1 = initial Isar schema (profiles, journal entries, settings).
/// Schema v2 = condition + symptom catalogue seeded from [SeedData].
/// Schema v3 = added weatherTrackingEnabled + weatherOptInShown to ProfileIsar.
/// Schema v4 = registered SleepEntryIsar collection.
/// Schema v5 = added colorSeed to ProfileIsar.
/// Schema v6 = registered SymptomEntryIsar + VitalEntryIsar collections.
/// Schema v7 = registered MedicationIsar + DoseLogIsar collections.
/// Schema v8 = registered MealEntryIsar collection.
/// Schema v9 = registered FlareIsar collection; added flareIsarId to MealEntryIsar.
/// Schema v10 = registered DailyCheckinIsar; added cycleTrackingEnabled to ProfileIsar.
/// Schema v11 = registered AppointmentIsar collection.
/// Schema v12 = registered ActivityEntryIsar collection.
/// Schema v13 = added status + statusHistory (ConditionStatusEventIsar) to UserConditionIsar.
/// Schema v14 = added weatherSnapshot embedded field to SymptomEntryIsar, MealEntryIsar, ActivityEntryIsar, DailyCheckinIsar.
/// Schema v15 = added weather embedded field to JournalEntryIsar.
/// Schema v16 = nullable DailyCheckin.wellbeing; SymptomEntry.locations;
///              Profile.bowelTrackingEnabled; FluidIntakeIsar and
///              EliminationEntryIsar collections.
/// Schema v17 = Profile.temperatureUnit (nullable, display preference).
/// Schema v18 = no schema change; removes health data left behind by
///              profile deletes before this version (see profile_deletion.dart).
/// Schema v19 = AppSettings.lastProfileId, seeded from the highest profile
///              id in use so deleted profiles' ids are never reused (#117).
/// Schema v20 = AppSettings What's new state (#139): lastSeenWhatsNewVersion,
///              updateHighlightsOff, whatsNewCardVersion,
///              whatsNewCardShownCount. No data change: every new field reads
///              as its "nothing yet" value on existing rows.
/// Schema v21 = AppSettings.bottomBarIds and bottomBarLayoutVersion, and
///              ProfileIsar.disabledFeatureIds (#137). No data change: null
///              bar = default, null version = 1.9.1's bar, empty = all on.
/// Schema v22 = AppSettings.guidePutOffOn and guideResumeStep (#145). No data
///              change: both read as null, nothing yet.
/// Schema v23 = flareDetached on symptom, vital, meal, dose and activity
///              entries (#173): which flare an entry is part of is worked out
///              from its time. Clears stored flare links that only repeat
///              that rule; any other link stays, as a pin.
/// Schema v24 = no schema change (#105): photo paths become names in
///              `<documents>/photos`. Older photos still there are copied in;
///              missing or non-image ones are dropped.
///
/// How to add a future migration:
///   1. Increment [_targetVersion].
///   2. Add an `if (currentVersion < N)` block inside [run].
///   3. Update [AppSettings.schemaVersion] at the end of each block.
///   4. Each block should be idempotent: it only writes what has changed.
///
/// Isar automatically handles structural changes (adding/removing fields and
/// collections). [MigrationRunner] is for data migrations: transforming
/// existing values, backfilling new fields, or splitting/merging records.
class MigrationRunner {
  MigrationRunner._();

  static const int _targetVersion = 24;

  /// The schema version a full upgrade reaches.
  static int get targetVersion => _targetVersion;

  /// Whether existing data is waiting for a data migration: the database
  /// has been initialised before (schema version above 0) and is behind the
  /// current version. A fresh install returns false: it has nothing to lose.
  ///
  /// Used by [PreMigrationSnapshot] to decide whether to take a snapshot.
  static Future<bool> needsMigration(Isar isar) async {
    final settings = await isar.appSettings.get(1);
    final currentVersion = settings?.schemaVersion ?? 0;
    return currentVersion > 0 && currentVersion < _targetVersion;
  }

  /// Run all pending migrations and update [AppSettings.schemaVersion].
  ///
  /// Called by [IsarService.open] before returning the [Isar] instance.
  static Future<void> run(Isar isar) async {
    final settings = await isar.appSettings.get(1);
    final currentVersion = settings?.schemaVersion ?? 0;

    if (currentVersion >= _targetVersion) return;

    // ── v0 → v1: initialise AppSettings singleton ─────────────────────────
    // v0 = pre-Isar (in-memory only). No existing data to migrate.
    // This block creates the AppSettings document for the first time.
    if (currentVersion < 1) {
      await isar.writeTxn(() async {
        final s = AppSettings()
          ..id = 1
          ..schemaVersion = 1;
        await isar.appSettings.put(s);
      });
    }

    // ── v1 → v2: seed condition + symptom catalogue ────────────────────────
    // Seeds the global catalogue from compile-time [SeedData] constants.
    // Guard: skip if already seeded (idempotent: safe to re-run).
    if (currentVersion < 2) {
      final existingCount = await isar.conditionIsars.count();
      if (existingCount == 0) {
        await _seedCatalogue(isar);
      }

      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 2;
        await isar.appSettings.put(s);
      });
    }

    // ── v2 → v3: weather fields on ProfileIsar ────────────────────────────
    // Isar automatically applies defaults (false) to the two new boolean
    // fields on existing rows. No data transformation needed.
    if (currentVersion < 3) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 3;
        await isar.appSettings.put(s);
      });
    }

    // ── v3 → v4: SleepEntryIsar collection registered ─────────────────────
    // Isar automatically creates the new collection on first open.
    // No data transformation needed.
    if (currentVersion < 4) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 4;
        await isar.appSettings.put(s);
      });
    }

    // ── v4 → v5: colorSeed added to ProfileIsar ───────────────────────────
    // Isar automatically defaults the new nullable field to null for existing
    // rows. New profiles get a color auto-assigned on creation by the provider.
    // No data transformation needed.
    if (currentVersion < 5) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 5;
        await isar.appSettings.put(s);
      });
    }

    // ── v5 → v6: SymptomEntryIsar + VitalEntryIsar collections registered ─
    // Isar automatically creates the new collections on first open.
    // No data transformation needed.
    if (currentVersion < 6) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 6;
        await isar.appSettings.put(s);
      });
    }

    // ── v6 → v7: MedicationIsar + DoseLogIsar collections registered ──────
    // Isar automatically creates the new collections on first open.
    // No data transformation needed.
    if (currentVersion < 7) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 7;
        await isar.appSettings.put(s);
      });
    }

    // ── v7 → v8: MealEntryIsar collection registered ──────────────────────
    // Isar automatically creates the new collection on first open.
    // No data transformation needed.
    if (currentVersion < 8) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 8;
        await isar.appSettings.put(s);
      });
    }

    // ── v8 → v9: FlareIsar registered; flareIsarId added to MealEntryIsar ──
    // Isar automatically creates the new collection and the nullable
    // flareIsarId column (defaults to null) on first open.
    // No data transformation needed.
    if (currentVersion < 9) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 9;
        await isar.appSettings.put(s);
      });
    }

    // ── v9 → v10: DailyCheckinIsar registered; cycleTrackingEnabled added ──
    // ProfileIsar gains cycleTrackingEnabled (bool, default false).
    // Isar handles the new nullable-equivalent column automatically.
    // No data transformation needed.
    if (currentVersion < 10) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 10;
        await isar.appSettings.put(s);
      });
    }

    // ── v10 → v11: AppointmentIsar registered ─────────────────────────────
    // New collection with embedded AppointmentQuestionIsar + MedicationChangeIsar.
    // Isar creates the collection automatically.
    // No data transformation needed.
    if (currentVersion < 11) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 11;
        await isar.appSettings.put(s);
      });
    }

    // ── v11 → v12: ActivityEntryIsar registered ───────────────────────────
    // New collection for physical activity and exertion logging.
    // Isar creates the collection automatically.
    // No data transformation needed.
    if (currentVersion < 12) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 12;
        await isar.appSettings.put(s);
      });
    }

    // ── v12 → v13: status + statusHistory added to UserConditionIsar ─────
    // Existing rows get status = 'active' and statusHistory = [] automatically
    // via Isar's default field handling. No data transformation needed.
    if (currentVersion < 13) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 13;
        await isar.appSettings.put(s);
      });
    }

    // ── v13 → v14: weatherSnapshot added to SymptomEntryIsar, MealEntryIsar,
    //               ActivityEntryIsar, DailyCheckinIsar ───────────────────────
    // Isar handles the new nullable embedded field automatically (null default).
    // No data transformation needed.
    if (currentVersion < 14) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 14;
        await isar.appSettings.put(s);
      });
    }

    // ── v14 → v15: weather added to JournalEntryIsar ──────────────────────
    // Isar handles the new nullable embedded field automatically (null default).
    // No data transformation needed.
    if (currentVersion < 15) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 15;
        await isar.appSettings.put(s);
      });
    }

    // ── v15 → v16: quick-log domains ──────────────────────────────────────
    // DailyCheckin.wellbeing becomes nullable (existing scores stay).
    // SymptomEntryIsar gains locations (default empty).
    // ProfileIsar gains bowelTrackingEnabled (default false).
    // FluidIntakeIsar and EliminationEntryIsar collections are registered.
    // Isar applies the structural changes. No value rewrite is required.
    if (currentVersion < 16) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 16;
        await isar.appSettings.put(s);
      });
    }

    // ── v16 → v17: ProfileIsar gains temperatureUnit ──────────────────────
    // Nullable; null means "As logged", so existing profiles keep showing
    // readings exactly as before. Vital rows are not touched.
    if (currentVersion < 17) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 17;
        await isar.appSettings.put(s);
      });
    }

    // ── v17 → v18: clear data left behind by old profile deletes ──────────
    // Before v18, deleting a profile removed only its journal entries. Rows in
    // every other collection stayed, invisible but included in backups.
    if (currentVersion < 18) {
      await isar.writeTxn(() async {
        await deleteOrphanedProfileData(isar);
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 18;
        await isar.appSettings.put(s);
      });
    }

    // ── v18 → v19: never reuse a profile id ───────────────────────────────
    // Seed the high-water mark from every id in use, including ids only
    // entries still point at, so the next new profile can't pick them up.
    if (currentVersion < 19) {
      await isar.writeTxn(() async {
        final highest = await highestProfileIdInUse(isar);
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        if (highest > s.lastProfileId) s.lastProfileId = highest;
        s.schemaVersion = 19;
        await isar.appSettings.put(s);
      });
    }

    // ── v19 → v20: What's new state on AppSettings (#139) ─────────────────
    // Fields only. The first launch on this version works out where What's
    // new starts (settleLaunch), because only then is the app version known.
    if (currentVersion < 20) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 20;
        await isar.appSettings.put(s);
      });
    }

    // ── v20 → v21: bottom bar and features in use (#137) ──────────────────
    // Fields only. A missing bar reads as "default", a missing version as
    // 1.9.1's bar, and a missing feature list as everything on, so an
    // update is told what changed (BarLayoutStore.settle) with no backfill.
    if (currentVersion < 21) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 21;
        await isar.appSettings.put(s);
      });
    }

    if (currentVersion < 22) {
      await isar.writeTxn(() async {
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 22;
        await isar.appSettings.put(s);
      });
    }

    // ── v22 → v23: which flare an entry is part of is worked out (#173) ──
    // Entries gained flareDetached (reads false). A stored flare link now
    // pins the entry to that flare, so clear the ones that only repeat
    // what the rule gives: those entries then follow their flare's dates.
    if (currentVersion < 23) {
      await isar.writeTxn(() async {
        await _clearRedundantFlareLinks(isar);
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 23;
        await isar.appSettings.put(s);
      });
    }

    // ── v23 → v24: photos into the app's own folder (#105) ───────────────
    // Photos were stored as the picker's temp or cache path. Copy each one
    // that's still there and is an image into <documents>/photos under our
    // own name; drop the rest (already cleared by the OS, or not an image).
    // Files are copied before the transaction, which must not await I/O
    // that can fail halfway; a crash in between leaves extra files for the
    // next sweep and the rows untouched for the next try.
    if (currentVersion < 24) {
      final avatars = <int, String?>{
        for (final p in await isar.profileIsars.where().findAll())
          if (p.avatarPath != null && !PhotoStore.isManaged(p.avatarPath))
            p.id: await PhotoStore.adopt(p.avatarPath),
      };
      final photos = <int, String?>{
        for (final m in await isar.mealEntryIsars.where().findAll())
          if (m.photoPath != null && !PhotoStore.isManaged(m.photoPath))
            m.id: await PhotoStore.adopt(m.photoPath),
      };
      await isar.writeTxn(() async {
        for (final MapEntry(:key, :value) in avatars.entries) {
          final p = await isar.profileIsars.get(key);
          if (p != null) await isar.profileIsars.put(p..avatarPath = value);
        }
        for (final MapEntry(:key, :value) in photos.entries) {
          final m = await isar.mealEntryIsars.get(key);
          if (m != null) await isar.mealEntryIsars.put(m..photoPath = value);
        }
        final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        s.schemaVersion = 24;
        await isar.appSettings.put(s);
      });
    }
  }

  static Future<void> _clearRedundantFlareLinks(Isar isar) async {
    final flares = [
      for (final f in await isar.flareIsars.where().findAll()) f.toDomain(),
    ];
    bool redundant(int? link, int profileId, DateTime at) =>
        link != null &&
        flareFor(at: at, profileId: profileId, flares: flares) == link;

    final symptoms = [
      for (final r in await isar.symptomEntryIsars.where().findAll())
        if (redundant(r.flareIsarId, r.profileId, r.loggedAt))
          r..flareIsarId = null,
    ];
    await isar.symptomEntryIsars.putAll(symptoms);
    final vitals = [
      for (final r in await isar.vitalEntryIsars.where().findAll())
        if (redundant(r.flareIsarId, r.profileId, r.loggedAt))
          r..flareIsarId = null,
    ];
    await isar.vitalEntryIsars.putAll(vitals);
    final meals = [
      for (final r in await isar.mealEntryIsars.where().findAll())
        if (redundant(r.flareIsarId, r.profileId, r.loggedAt))
          r..flareIsarId = null,
    ];
    await isar.mealEntryIsars.putAll(meals);
    final doses = [
      for (final r in await isar.doseLogIsars.where().findAll())
        if (redundant(r.flareIsarId, r.profileId, r.loggedAt))
          r..flareIsarId = null,
    ];
    await isar.doseLogIsars.putAll(doses);
    final activities = [
      for (final r in await isar.activityEntryIsars.where().findAll())
        if (redundant(r.flareIsarId, r.profileId, r.loggedAt))
          r..flareIsarId = null,
    ];
    await isar.activityEntryIsars.putAll(activities);
  }

  /// Inserts all conditions and symptoms from [SeedData] in a single
  /// transaction. Called once on first install (or after a data wipe).
  static Future<void> _seedCatalogue(Isar isar) async {
    await isar.writeTxn(() async {
      // Conditions (1 131 entries)
      final conditions = SeedData.conditions.map((name) {
        return ConditionIsar()
          ..name = name
          ..global = true;
      }).toList();
      await isar.conditionIsars.putAll(conditions);

      // Symptoms (243 entries)
      final symptoms = SeedData.symptoms.map((name) {
        return SymptomIsar()
          ..name = name
          ..global = true;
      }).toList();
      await isar.symptomIsars.putAll(symptoms);
    });
  }
}
