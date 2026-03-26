import 'package:isar_community/isar.dart';

import 'package:health_flare/models/appointment.dart';

part 'appointment_isar.g.dart';

@embedded
class AppointmentQuestionIsar {
  late String questionId;
  late String question;
  bool discussed = false;

  AppointmentQuestion toDomain() => AppointmentQuestion(
    questionId: questionId,
    question: question,
    discussed: discussed,
  );

  static AppointmentQuestionIsar fromDomain(AppointmentQuestion q) =>
      AppointmentQuestionIsar()
        ..questionId = q.questionId
        ..question = q.question
        ..discussed = q.discussed;
}

@embedded
class MedicationChangeIsar {
  late String changeId;
  late String description;
  int? linkedMedicationIsarId;

  MedicationChange toDomain() => MedicationChange(
    changeId: changeId,
    description: description,
    linkedMedicationIsarId: linkedMedicationIsarId,
  );

  static MedicationChangeIsar fromDomain(MedicationChange c) =>
      MedicationChangeIsar()
        ..changeId = c.changeId
        ..description = c.description
        ..linkedMedicationIsarId = c.linkedMedicationIsarId;
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

  // ── Conversion ────────────────────────────────────────────────────────────

  Appointment toDomain() => Appointment(
    id: id,
    profileId: profileId,
    title: title,
    providerName: providerName,
    scheduledAt: scheduledAt,
    status: status,
    outcomeNotes: outcomeNotes,
    questions: questions.map((q) => q.toDomain()).toList(),
    medicationChanges: medicationChanges.map((c) => c.toDomain()).toList(),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static AppointmentIsar fromDomain(Appointment a) => AppointmentIsar()
    ..id = a.id
    ..profileId = a.profileId
    ..title = a.title
    ..providerName = a.providerName
    ..scheduledAt = a.scheduledAt
    ..status = a.status
    ..outcomeNotes = a.outcomeNotes
    ..questions = a.questions.map(AppointmentQuestionIsar.fromDomain).toList()
    ..medicationChanges = a.medicationChanges
        .map(MedicationChangeIsar.fromDomain)
        .toList()
    ..createdAt = a.createdAt
    ..updatedAt = a.updatedAt;
}
