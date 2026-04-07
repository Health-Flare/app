import 'dart:io';

import 'package:isar_community/isar.dart';

import 'isar_models/activity_entry_isar.dart';
import 'isar_models/app_settings.dart';
import 'isar_models/appointment_isar.dart';
import 'isar_models/condition_isar.dart';
import 'isar_models/daily_checkin_isar.dart';
import 'isar_models/dose_log_isar.dart';
import 'isar_models/flare_isar.dart';
import 'isar_models/journal_entry_isar.dart';
import 'isar_models/meal_entry_isar.dart';
import 'isar_models/medication_isar.dart';
import 'isar_models/profile_isar.dart';
import 'isar_models/sleep_entry_isar.dart';
import 'isar_models/symptom_entry_isar.dart';
import 'isar_models/symptom_isar.dart';
import 'isar_models/user_condition_isar.dart';
import 'isar_models/user_symptom_isar.dart';
import 'isar_models/vital_entry_isar.dart';

import 'csv_parser.dart';

/// Result of a dry-run or real import.
class ImportResult {
  final int journalImported;
  final int symptomImported;
  final int skippedDuplicates;
  final List<String> warnings;

  const ImportResult({
    required this.journalImported,
    required this.symptomImported,
    required this.skippedDuplicates,
    required this.warnings,
  });

  int get totalImported => journalImported + symptomImported;
}

/// Handles opening the database and writing CSV rows to Isar.
class Importer {
  /// Runs the full import pipeline.
  ///
  /// [dbPath]     — absolute path to `healthflare.isar`.
  /// [profileName] — name of the target profile (case-insensitive).
  /// [rows]       — pre-parsed CSV rows.
  /// [dryRun]     — when true, performs all checks but writes nothing.
  static Future<ImportResult> run({
    required String dbPath,
    required String profileName,
    required List<CsvRow> rows,
    bool dryRun = false,
  }) async {
    final dbFile = File(dbPath);
    if (!dbFile.existsSync()) {
      throw ArgumentError('Database not found: $dbPath');
    }

    final dir = dbFile.parent.path;
    final name = dbFile.uri.pathSegments.last.replaceAll('.isar', '');

    // Isar needs to initialise its native library on non-Flutter Dart.
    // Downloads and caches libisar.dylib on first run (CLI only — not app code).
    await Isar.initializeIsarCore(download: true);

    final isar = await Isar.open(
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
      directory: dir,
      name: name,
    );

    try {
      return await _import(
        isar: isar,
        profileName: profileName,
        rows: rows,
        dryRun: dryRun,
      );
    } finally {
      await isar.close();
    }
  }

  static Future<ImportResult> _import({
    required Isar isar,
    required String profileName,
    required List<CsvRow> rows,
    required bool dryRun,
  }) async {
    // Find profile (case-insensitive).
    final allProfiles = await isar.profileIsars.where().findAll();
    final profile = allProfiles.where(
      (p) => p.name.toLowerCase().trim() == profileName.toLowerCase().trim(),
    ).firstOrNull;

    if (profile == null) {
      final names = allProfiles.map((p) => '"${p.name}"').join(', ');
      throw ArgumentError(
        'Profile "$profileName" not found.\n'
        'Available profiles: ${names.isEmpty ? "(none)" : names}',
      );
    }

    final profileId = profile.id;

    // Build deduplication sets.
    final existingJournal = (await isar.journalEntryIsars.where().findAll())
        .where((e) => e.profileId == profileId)
        .map((e) => e.createdAt.millisecondsSinceEpoch)
        .toSet();

    final existingSymptom = (await isar.symptomEntryIsars.where().findAll())
        .where((e) => e.profileId == profileId)
        .map((e) => '${e.loggedAt.millisecondsSinceEpoch}_${e.name.toLowerCase()}')
        .toSet();

    final warnings = <String>[];
    final toJournal = <JournalEntryIsar>[];
    final toSymptom = <SymptomEntryIsar>[];
    int skipped = 0;

    for (final row in rows) {
      switch (row.type) {
        case CsvEntryType.journal:
          final ts = row.date.millisecondsSinceEpoch;
          if (existingJournal.contains(ts)) {
            skipped++;
            continue;
          }
          final snapshot = JournalSnapshotIsar()
            ..body = row.body ?? row.title ?? ''
            ..title = row.body != null ? row.title : null
            ..savedAt = row.date;
          toJournal.add(
            JournalEntryIsar()
              ..profileId = profileId
              ..createdAt = row.date
              ..snapshots = [snapshot]
              ..mood = null
              ..energyLevel = null,
          );

        case CsvEntryType.symptom:
          final key = '${row.date.millisecondsSinceEpoch}_${row.title!.toLowerCase()}';
          if (existingSymptom.contains(key)) {
            skipped++;
            continue;
          }
          // If two rows share the same timestamp + name, offset by row index.
          var loggedAt = row.date;
          while (existingSymptom.contains(
            '${loggedAt.millisecondsSinceEpoch}_${row.title!.toLowerCase()}',
          )) {
            loggedAt = loggedAt.add(const Duration(seconds: 1));
          }
          toSymptom.add(
            SymptomEntryIsar()
              ..profileId = profileId
              ..name = row.title!
              ..severity = row.severity ?? 5
              ..loggedAt = loggedAt
              ..createdAt = loggedAt,
          );
      }
    }

    if (!dryRun) {
      if (toJournal.isNotEmpty) {
        await isar.writeTxn(() => isar.journalEntryIsars.putAll(toJournal));
      }
      if (toSymptom.isNotEmpty) {
        await isar.writeTxn(() => isar.symptomEntryIsars.putAll(toSymptom));
      }
    }

    return ImportResult(
      journalImported: toJournal.length,
      symptomImported: toSymptom.length,
      skippedDuplicates: skipped,
      warnings: warnings,
    );
  }
}
