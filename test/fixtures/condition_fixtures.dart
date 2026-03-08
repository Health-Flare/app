import 'package:health_flare/data/models/condition_isar.dart';
import 'package:health_flare/data/models/symptom_isar.dart';
import 'package:health_flare/data/models/user_condition_isar.dart';
import 'package:health_flare/data/models/user_symptom_isar.dart';

/// Test fixtures for Condition and Symptom related data.
class ConditionFixtures {
  ConditionFixtures._();

  /// Sample global conditions (from seed data).
  static List<ConditionIsar> get globalConditions => [
        ConditionIsar()
          ..id = 1
          ..name = 'Arthritis'
          ..global = true,
        ConditionIsar()
          ..id = 2
          ..name = 'Crohn\'s disease'
          ..global = true,
        ConditionIsar()
          ..id = 3
          ..name = 'Fibromyalgia'
          ..global = true,
        ConditionIsar()
          ..id = 4
          ..name = 'Lupus'
          ..global = true,
        ConditionIsar()
          ..id = 5
          ..name = 'Multiple sclerosis'
          ..global = true,
      ];

  /// A custom (user-created) condition.
  static ConditionIsar get customCondition => ConditionIsar()
    ..id = 100
    ..name = 'Myalgic encephalomyelitis'
    ..global = false;

  /// Sample symptoms.
  static List<SymptomIsar> get commonSymptoms => [
        SymptomIsar()
          ..id = 1
          ..name = 'Fatigue',
        SymptomIsar()
          ..id = 2
          ..name = 'Joint pain',
        SymptomIsar()
          ..id = 3
          ..name = 'Headache',
        SymptomIsar()
          ..id = 4
          ..name = 'Nausea',
        SymptomIsar()
          ..id = 5
          ..name = 'Brain fog',
      ];

  /// User condition linking profile to condition.
  static UserConditionIsar userCondition({
    required int profileId,
    required int conditionId,
    required String conditionName,
  }) =>
      UserConditionIsar()
        ..profileId = profileId
        ..conditionId = conditionId
        ..conditionName = conditionName
        ..trackedSince = DateTime.now();

  /// User symptom linking profile to symptom.
  static UserSymptomIsar userSymptom({
    required int profileId,
    required int symptomId,
    required String symptomName,
  }) =>
      UserSymptomIsar()
        ..profileId = profileId
        ..symptomId = symptomId
        ..symptomName = symptomName
        ..trackedSince = DateTime.now();
}
