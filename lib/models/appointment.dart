import 'package:flutter/foundation.dart';

/// A question prepared before (or discussed during) an appointment.
@immutable
class AppointmentQuestion {
  const AppointmentQuestion({
    required this.questionId,
    required this.question,
    this.discussed = false,
  });

  final String questionId;
  final String question;
  final bool discussed;

  AppointmentQuestion copyWith({String? question, bool? discussed}) =>
      AppointmentQuestion(
        questionId: questionId,
        question: question ?? this.question,
        discussed: discussed ?? this.discussed,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppointmentQuestion && other.questionId == questionId);

  @override
  int get hashCode => questionId.hashCode;
}

/// A medication change noted during or after an appointment.
@immutable
class MedicationChange {
  const MedicationChange({
    required this.changeId,
    required this.description,
    this.linkedMedicationIsarId,
  });

  final String changeId;
  final String description;

  /// Set when the user chooses to add this to their medication list.
  final int? linkedMedicationIsarId;

  MedicationChange copyWith({
    String? description,
    int? linkedMedicationIsarId,
  }) => MedicationChange(
    changeId: changeId,
    description: description ?? this.description,
    linkedMedicationIsarId:
        linkedMedicationIsarId ?? this.linkedMedicationIsarId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationChange && other.changeId == changeId);

  @override
  int get hashCode => changeId.hashCode;
}

/// Appointment status values.
abstract final class AppointmentStatus {
  static const upcoming = 'upcoming';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
  static const missed = 'missed';
}

/// Immutable domain model for a medical appointment.
@immutable
class Appointment {
  const Appointment({
    required this.id,
    required this.profileId,
    required this.title,
    this.providerName,
    required this.scheduledAt,
    required this.status,
    this.outcomeNotes,
    this.questions = const [],
    this.medicationChanges = const [],
    required this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int profileId;
  final String title;
  final String? providerName;
  final DateTime scheduledAt;

  /// One of [AppointmentStatus] constants.
  final String status;

  final String? outcomeNotes;
  final List<AppointmentQuestion> questions;
  final List<MedicationChange> medicationChanges;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isUpcoming => status == AppointmentStatus.upcoming;
  bool get isCompleted => status == AppointmentStatus.completed;

  Appointment copyWith({
    String? title,
    String? providerName,
    DateTime? scheduledAt,
    String? status,
    String? outcomeNotes,
    List<AppointmentQuestion>? questions,
    List<MedicationChange>? medicationChanges,
    DateTime? updatedAt,
    bool clearProviderName = false,
    bool clearOutcomeNotes = false,
  }) => Appointment(
    id: id,
    profileId: profileId,
    title: title ?? this.title,
    providerName: clearProviderName
        ? null
        : (providerName ?? this.providerName),
    scheduledAt: scheduledAt ?? this.scheduledAt,
    status: status ?? this.status,
    outcomeNotes: clearOutcomeNotes
        ? null
        : (outcomeNotes ?? this.outcomeNotes),
    questions: questions ?? this.questions,
    medicationChanges: medicationChanges ?? this.medicationChanges,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Appointment && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Appointment(id: $id, title: $title, status: $status)';
}
