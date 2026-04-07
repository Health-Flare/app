import 'package:isar_community/isar.dart';

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

}
