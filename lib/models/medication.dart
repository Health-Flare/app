import 'package:flutter/foundation.dart';

@immutable
class Medication {
  const Medication({
    required this.id,
    required this.profileId,
    required this.name,
    required this.medicationType,
    required this.doseAmount,
    required this.doseUnit,
    required this.frequency,
    this.frequencyLabel,
    required this.startDate,
    this.endDate,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int profileId;
  final String name;
  final String medicationType; // "medication" | "supplement"
  final double doseAmount;
  final String doseUnit;
  final String frequency;
  final String? frequencyLabel;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isActive => endDate == null || endDate!.isAfter(DateTime.now());
  bool get isSupplement => medicationType == 'supplement';

  String get doseDisplay {
    final amount = doseAmount == doseAmount.truncateToDouble()
        ? doseAmount.toStringAsFixed(0)
        : doseAmount.toString();
    return '$amount $doseUnit';
  }

  String get frequencyDisplay => switch (frequency) {
    'once_daily' => 'Once daily',
    'twice_daily' => 'Twice daily',
    'three_times_daily' => 'Three times daily',
    'as_needed' => 'As needed',
    'weekly' => 'Weekly',
    'custom' => frequencyLabel ?? 'Custom',
    _ => frequency,
  };

  Medication copyWith({
    String? name,
    String? medicationType,
    double? doseAmount,
    String? doseUnit,
    String? frequency,
    String? frequencyLabel,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    DateTime? updatedAt,
    bool clearEndDate = false,
    bool clearNotes = false,
    bool clearFrequencyLabel = false,
  }) {
    return Medication(
      id: id,
      profileId: profileId,
      name: name ?? this.name,
      medicationType: medicationType ?? this.medicationType,
      doseAmount: doseAmount ?? this.doseAmount,
      doseUnit: doseUnit ?? this.doseUnit,
      frequency: frequency ?? this.frequency,
      frequencyLabel: clearFrequencyLabel
          ? null
          : (frequencyLabel ?? this.frequencyLabel),
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Medication && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
