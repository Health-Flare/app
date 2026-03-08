import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/models/condition_isar.dart';
import 'package:health_flare/data/models/journal_entry_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/data/models/symptom_isar.dart';
import 'package:health_flare/data/models/user_condition_isar.dart';
import 'package:health_flare/data/models/user_symptom_isar.dart';

/// Provides an isolated, in-memory Isar database for testing.
///
/// Each test gets a fresh database instance to prevent state leakage.
class TestDatabase {
  TestDatabase._();

  static int _instanceCounter = 0;
  static final List<Isar> _openInstances = [];
  static bool _isarInitialized = false;

  /// Initializes Isar core library for testing.
  ///
  /// Downloads the native library if not present. This must be called
  /// before any Isar.open() calls. Safe to call multiple times.
  static Future<void> initializeIsar() async {
    if (_isarInitialized) return;
    await Isar.initializeIsarCore(download: true);
    _isarInitialized = true;
  }

  /// Opens a fresh, unique Isar database for testing.
  ///
  /// Creates a temporary directory for each instance to avoid conflicts.
  /// Use [closeAll] in tearDown to clean up.
  static Future<Isar> open() async {
    await initializeIsar();

    _instanceCounter++;
    final name = 'test_db_$_instanceCounter';

    // Create a unique temp directory for this test instance
    final tempDir = Directory.systemTemp.createTempSync('healthflare_test_');

    final isar = await Isar.open(
      [
        ProfileIsarSchema,
        JournalEntryIsarSchema,
        AppSettingsSchema,
        ConditionIsarSchema,
        UserConditionIsarSchema,
        SymptomIsarSchema,
        UserSymptomIsarSchema,
      ],
      directory: tempDir.path,
      name: name,
    );

    _openInstances.add(isar);
    return isar;
  }

  /// Clears all data from the given Isar instance.
  static Future<void> clear(Isar isar) async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }

  /// Closes a specific Isar instance.
  static Future<void> close(Isar isar) async {
    await isar.close();
    _openInstances.remove(isar);
  }

  /// Closes all open test database instances.
  ///
  /// Call this in tearDownAll to clean up.
  static Future<void> closeAll() async {
    for (final isar in _openInstances.toList()) {
      await isar.close();
    }
    _openInstances.clear();
  }
}

/// Test fixture extensions for Isar to simplify test setup.
extension IsarTestExtensions on Isar {
  /// Seeds the database with test profiles.
  Future<void> seedProfiles(List<ProfileIsar> profiles) async {
    await writeTxn(() async {
      await profileIsars.putAll(profiles);
    });
  }

  /// Seeds the database with test journal entries.
  Future<void> seedJournalEntries(List<JournalEntryIsar> entries) async {
    await writeTxn(() async {
      await journalEntryIsars.putAll(entries);
    });
  }

  /// Seeds the database with test conditions.
  Future<void> seedConditions(List<ConditionIsar> conditions) async {
    await writeTxn(() async {
      await conditionIsars.putAll(conditions);
    });
  }

  /// Seeds the database with test symptoms.
  Future<void> seedSymptoms(List<SymptomIsar> symptoms) async {
    await writeTxn(() async {
      await symptomIsars.putAll(symptoms);
    });
  }

  /// Sets the active profile ID in app settings.
  Future<void> setActiveProfile(int profileId) async {
    await writeTxn(() async {
      final settings = await appSettings.get(1) ?? AppSettings();
      settings.activeProfileId = profileId;
      await appSettings.put(settings);
    });
  }
}
