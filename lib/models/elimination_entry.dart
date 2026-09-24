import 'package:flutter/foundation.dart';

/// One bowel or bladder event.
///
/// [kind] is `bowel` or `bladder`. [count] is 0 for an explicit "nothing"
/// (constipation) and otherwise how many events this record stands for when
/// the text said "twice" or "x3" and the saver expanded them into rows.
@immutable
class EliminationEntry {
  const EliminationEntry({
    required this.id,
    required this.profileId,
    required this.loggedAt,
    required this.kind,
    this.bristolType,
    this.count = 1,
    this.blood = false,
    this.urgency = false,
    this.notes,
    required this.createdAt,
  });

  final int id;
  final int profileId;
  final DateTime loggedAt;

  /// `bowel` or `bladder`.
  final String kind;

  /// Bristol stool type 1–7, when the text named one.
  final int? bristolType;
  final int count;
  final bool blood;
  final bool urgency;
  final String? notes;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is EliminationEntry && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
