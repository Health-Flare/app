import 'package:flutter/foundation.dart';

@immutable
class DoseLog {
  const DoseLog({
    required this.id,
    required this.profileId,
    required this.medicationIsarId,
    required this.loggedAt,
    required this.createdAt,
    required this.amount,
    required this.unit,
    required this.status,
    this.reason,
    this.effectiveness,
    this.notes,
    this.flareIsarId,
  });

  final int id;
  final int profileId;
  final int medicationIsarId;
  final DateTime loggedAt;
  final DateTime createdAt;
  final double amount;
  final String unit;
  final String status; // "taken" | "skipped" | "missed"
  final String? reason;
  final String? effectiveness;
  // "helped_a_lot" | "helped_a_little" | "no_effect" | "made_it_worse"
  final String? notes;
  final int? flareIsarId;

  String get statusDisplay => switch (status) {
    'taken' => 'Taken',
    'skipped' => 'Skipped',
    'missed' => 'Missed',
    _ => status,
  };

  String get effectivenessDisplay => switch (effectiveness) {
    'helped_a_lot' => 'Helped a lot',
    'helped_a_little' => 'Helped a little',
    'no_effect' => 'No effect',
    'made_it_worse' => 'Made it worse',
    _ => effectiveness ?? '',
  };

  String get amountDisplay {
    final a = amount == amount.truncateToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toString();
    return '$a $unit';
  }

  DoseLog copyWith({
    DateTime? loggedAt,
    double? amount,
    String? unit,
    String? status,
    String? reason,
    String? effectiveness,
    String? notes,
    bool clearReason = false,
    bool clearEffectiveness = false,
    bool clearNotes = false,
  }) {
    return DoseLog(
      id: id,
      profileId: profileId,
      medicationIsarId: medicationIsarId,
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      reason: clearReason ? null : (reason ?? this.reason),
      effectiveness: clearEffectiveness
          ? null
          : (effectiveness ?? this.effectiveness),
      notes: clearNotes ? null : (notes ?? this.notes),
      flareIsarId: flareIsarId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is DoseLog && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
