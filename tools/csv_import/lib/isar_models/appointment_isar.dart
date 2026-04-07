import 'package:isar_community/isar.dart';

part 'appointment_isar.g.dart';

@embedded
class AppointmentQuestionIsar {
  late String questionId;
  late String question;
  bool discussed = false;

}

@embedded
class MedicationChangeIsar {
  late String changeId;
  late String description;
  int? linkedMedicationIsarId;

}

@collection
class AppointmentIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  late String title;

  String? providerName;

  @Index()
  late DateTime scheduledAt;

  late String status;

  String? outcomeNotes;

  List<AppointmentQuestionIsar> questions = [];

  List<MedicationChangeIsar> medicationChanges = [];

  late DateTime createdAt;

  DateTime? updatedAt;

}
