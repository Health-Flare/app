import 'package:isar_community/isar.dart';

import 'package:health_flare/models/medication.dart';

part 'medication_isar.g.dart';

@collection
class MedicationIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  late String name;

  late String medicationType; // "medication" | "supplement"

  late double doseAmount;

  late String doseUnit; // mg | mL | IU | mcg | g | etc.

  late String frequency;
  // "once_daily"|"twice_daily"|"three_times_daily"|"as_needed"|"weekly"|"custom"

  String? frequencyLabel; // human label for "custom" frequency

  @Index()
  late DateTime startDate;

  DateTime? endDate; // null = still active

  String? notes;

  late DateTime createdAt;

  DateTime? updatedAt;

  Medication toDomain() => Medication(
    id: id,
    profileId: profileId,
    name: name,
    medicationType: medicationType,
    doseAmount: doseAmount,
    doseUnit: doseUnit,
    frequency: frequency,
    frequencyLabel: frequencyLabel,
    startDate: startDate,
    endDate: endDate,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static MedicationIsar fromDomain(Medication m) => MedicationIsar()
    ..id = m.id
    ..profileId = m.profileId
    ..name = m.name
    ..medicationType = m.medicationType
    ..doseAmount = m.doseAmount
    ..doseUnit = m.doseUnit
    ..frequency = m.frequency
    ..frequencyLabel = m.frequencyLabel
    ..startDate = m.startDate
    ..endDate = m.endDate
    ..notes = m.notes
    ..createdAt = m.createdAt
    ..updatedAt = m.updatedAt;
}
