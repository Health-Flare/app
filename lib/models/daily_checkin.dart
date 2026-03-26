import 'package:flutter/foundation.dart';

/// Immutable domain model for a single daily check-in.
///
/// One check-in per profile per calendar day. The wellbeing field (1–10) is
/// the only required value; stress, cycle phase and notes are optional.
@immutable
class DailyCheckin {
  const DailyCheckin({
    required this.id,
    required this.profileId,
    required this.checkinDate,
    required this.wellbeing,
    this.stressLevel,
    this.cyclePhase,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int profileId;

  /// Date-only anchor — only the year/month/day components are meaningful.
  final DateTime checkinDate;

  /// Overall wellbeing 1–10.
  final int wellbeing;

  /// "low" | "medium" | "high"
  final String? stressLevel;

  /// "period" | "follicular" | "ovulation" | "luteal" | "not_sure"
  final String? cyclePhase;

  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DailyCheckin copyWith({
    DateTime? checkinDate,
    int? wellbeing,
    String? stressLevel,
    String? cyclePhase,
    String? notes,
    DateTime? updatedAt,
    bool clearStress = false,
    bool clearCyclePhase = false,
    bool clearNotes = false,
  }) {
    return DailyCheckin(
      id: id,
      profileId: profileId,
      checkinDate: checkinDate ?? this.checkinDate,
      wellbeing: wellbeing ?? this.wellbeing,
      stressLevel: clearStress ? null : (stressLevel ?? this.stressLevel),
      cyclePhase: clearCyclePhase ? null : (cyclePhase ?? this.cyclePhase),
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is DailyCheckin && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DailyCheckin(id: $id, date: $checkinDate, wellbeing: $wellbeing)';
}
