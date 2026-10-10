import 'package:isar_community/isar.dart';

import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/models/activity_entry_isar.dart';
import 'package:health_flare/data/models/appointment_isar.dart';
import 'package:health_flare/data/models/condition_isar.dart';
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
import 'package:health_flare/data/models/symptom_isar.dart';
import 'package:health_flare/data/models/user_condition_isar.dart';
import 'package:health_flare/data/models/user_symptom_isar.dart';
import 'package:health_flare/data/models/vital_entry_isar.dart';

/// Every collection in the app database. The live database, a backup being
/// imported and a staged restore are all opened with this list.
const List<CollectionSchema<dynamic>> appSchemas = [
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
  FluidIntakeIsarSchema,
  EliminationEntryIsarSchema,
];
