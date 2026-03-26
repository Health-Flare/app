/// A logged sleep session for a [Profile].
///
/// [bedtime] and [wakeTime] are stored as full [DateTime] values so that
/// cross-midnight sessions are represented correctly. [duration] and [date]
/// are derived fields — never stored separately.
///
/// [isNap] is set automatically by the provider when a second entry is saved
/// for the same calendar date (determined by [wakeTime.date]).
class SleepEntry {
  const SleepEntry({
    required this.id,
    required this.profileId,
    required this.bedtime,
    required this.wakeTime,
    this.qualityRating,
    this.notes,
    this.isNap = false,
    required this.createdAt,
  });

  final int id;

  /// Foreign key to the owning profile's Isar id.
  final int profileId;

  /// When the user went to sleep.
  final DateTime bedtime;

  /// When the user woke up. Must be after [bedtime].
  final DateTime wakeTime;

  /// Subjective quality: 1 (Very poor) to 5 (Restful). Null if not rated.
  final int? qualityRating;

  final String? notes;

  /// True when this is the second (or later) sleep entry on [date].
  final bool isNap;

  /// When this record was created in the app.
  final DateTime createdAt;

  // ── Derived ───────────────────────────────────────────────────────────────

  /// Total sleep duration (wakeTime − bedtime). May be negative if the entry
  /// is invalid (wake before bed); callers should validate before saving.
  Duration get duration => wakeTime.difference(bedtime);

  /// Human-readable duration, e.g. "8h" or "7h 45m".
  String get formattedDuration {
    final d = duration;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  /// The calendar date of this entry — the day the user woke up.
  DateTime get date => DateTime(wakeTime.year, wakeTime.month, wakeTime.day);

  /// True when [wakeTime] is not after [bedtime] — an invalid configuration.
  bool get isInvalidTiming => !wakeTime.isAfter(bedtime);

  // ── Copy ─────────────────────────────────────────────────────────────────

  SleepEntry copyWith({
    int? id,
    int? profileId,
    DateTime? bedtime,
    DateTime? wakeTime,
    int? qualityRating,
    bool clearQuality = false,
    String? notes,
    bool clearNotes = false,
    bool? isNap,
    DateTime? createdAt,
  }) {
    return SleepEntry(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      bedtime: bedtime ?? this.bedtime,
      wakeTime: wakeTime ?? this.wakeTime,
      qualityRating: clearQuality
          ? null
          : (qualityRating ?? this.qualityRating),
      notes: clearNotes ? null : (notes ?? this.notes),
      isNap: isNap ?? this.isNap,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SleepEntry && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SleepEntry(id: $id, profileId: $profileId, '
      'bedtime: $bedtime, wakeTime: $wakeTime, isNap: $isNap)';
}
