import 'package:isar_community/isar.dart';

import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/models/condition_isar.dart';
import 'package:health_flare/data/models/symptom_isar.dart';
import 'package:health_flare/data/seed_data.dart';

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
///
/// How to add a future migration:
///   1. Increment [_targetVersion].
///   2. Add an `if (currentVersion < N)` block inside [run].
///   3. Update [AppSettings.schemaVersion] at the end of each block.
///   4. Each block should be idempotent — it only writes what has changed.
///
/// Isar automatically handles structural changes (adding/removing fields and
/// collections). [MigrationRunner] is for data migrations: transforming
/// existing values, backfilling new fields, or splitting/merging records.
class MigrationRunner {
  MigrationRunner._();

  static const int _targetVersion = 11;

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
    // Guard: skip if already seeded (idempotent — safe to re-run).
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
