// What a backup holds, per profile, so "Add missing data" and "Replace
// everything" can say what they will do before doing it (#104).

/// One profile in a backup.
class BackupProfileSummary {
  const BackupProfileSummary({
    required this.name,
    this.isNew = false,
    this.newCounts = const {},
    this.entryCount = 0,
  });

  final String name;

  /// No profile of this name is in the app: merging adds it.
  final bool isNew;

  /// Records "Add missing data" would add for this profile, by
  /// `ImportCategoryId`. Only categories with at least one.
  final Map<String, int> newCounts;

  /// Every entry this profile has in the backup, for "Replace everything".
  final int entryCount;

  bool get hasNothingNew => !isNew && newCounts.isEmpty;
}

class BackupSummary {
  const BackupSummary({this.profiles = const [], this.layoutIsNew = false});

  /// In the backup's order.
  final List<BackupProfileSummary> profiles;

  /// The backup's bottom bar would be taken (#144).
  final bool layoutIsNew;

  bool get hasNothingNew =>
      !layoutIsNew && profiles.every((p) => p.hasNothingNew);
}

/// "Sarah: 12 symptoms, 3 doses", "Leo: nothing new".
String backupAddLine(BackupProfileSummary p) => '';

/// "Sarah: 15 entries".
String backupEntriesLine(BackupProfileSummary p) => '';
