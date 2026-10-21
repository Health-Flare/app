// What a backup holds, per profile, so "Add missing data" and "Replace
// everything" can say what they will do before doing it (#104).

import 'package:health_flare/data/database/import_service.dart';

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

/// Singular and plural nouns for each kind of record, as the confirmation
/// lists them.
const _nouns = <String, (String, String)>{
  ImportCategoryId.symptomEntries: ('symptom', 'symptoms'),
  ImportCategoryId.vitals: ('vital sign', 'vital signs'),
  ImportCategoryId.doseLogs: ('dose', 'doses'),
  ImportCategoryId.medications: ('medication', 'medications'),
  ImportCategoryId.meals: ('meal', 'meals'),
  ImportCategoryId.fluids: ('drink', 'drinks'),
  ImportCategoryId.elimination: (
    'bowel or bladder entry',
    'bowel or bladder entries',
  ),
  ImportCategoryId.sleep: ('sleep record', 'sleep records'),
  ImportCategoryId.activity: ('activity', 'activities'),
  ImportCategoryId.journal: ('journal entry', 'journal entries'),
  ImportCategoryId.checkins: ('check-in', 'check-ins'),
  ImportCategoryId.flares: ('flare', 'flares'),
  ImportCategoryId.appointments: ('appointment', 'appointments'),
  ImportCategoryId.trackedConditions: (
    'tracked condition',
    'tracked conditions',
  ),
  ImportCategoryId.trackedSymptoms: ('tracked symptom', 'tracked symptoms'),
};

String _count(int n, String id) {
  final (one, many) = _nouns[id] ?? (id, id);
  return '$n ${n == 1 ? one : many}';
}

/// "Sarah: 12 symptoms, 3 doses", "Leo: nothing new",
/// "Mia (new profile): 2 journal entries".
String backupAddLine(BackupProfileSummary p) {
  final name = p.isNew ? '${p.name} (new profile)' : p.name;
  if (p.newCounts.isEmpty) return p.isNew ? name : '$name: nothing new';
  final parts = [
    for (final MapEntry(:key, :value) in p.newCounts.entries)
      _count(value, key),
  ];
  return '$name: ${parts.join(', ')}';
}

/// "Sarah: 15 entries", "Leo: 1 entry".
String backupEntriesLine(BackupProfileSummary p) =>
    '${p.name}: ${p.entryCount} ${p.entryCount == 1 ? 'entry' : 'entries'}';
