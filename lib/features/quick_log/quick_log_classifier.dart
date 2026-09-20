import 'package:health_flare/features/quick_log/quick_log_parser.dart';
import 'package:health_flare/models/condition.dart';
import 'package:health_flare/models/symptom.dart';
import 'package:health_flare/models/user_condition.dart';
import 'package:health_flare/models/user_symptom.dart';

/// Entry types the quick-log classifier can suggest.
enum QuickLogEntryType {
  meal,
  symptom,
  vital,
  medication,
  doctorVisit,
  activity,
  sleep,
  condition,
  journal,
}

/// Offline, keyword-based classifier for freeform quick-log text.
///
/// Returns the best-guess [QuickLogEntryType], or null when the text is
/// too short or too ambiguous to classify confidently.
///
/// Priority order (first match wins):
///   Vital > Sleep > Medication > Doctor > Meal > Activity > Condition >
///   Symptom > Journal (fallback)
abstract final class QuickLogClassifier {
  /// Minimum word count before classification is attempted.
  static const _minWords = 3;

  /// Classify [text] and return a suggested [QuickLogEntryType].
  ///
  /// Returns null when the text has fewer than [_minWords] words, unless it
  /// confidently matches a vital reading (e.g. "74kg", "144cm", "4'8"") —
  /// those numeric+unit patterns are unambiguous enough to skip the
  /// word-count gate that guards the fuzzier keyword matches below.
  ///
  /// [conditionCatalog]/[trackedConditions] and [symptomCatalog]/
  /// [trackedSymptoms] let Condition and Symptom classification recognise a
  /// known or previously-tracked name even when it isn't in the generic
  /// keyword lists below — mirroring how [QuickLogParser.matchMedication]
  /// checks the profile's real medications at save time. [loggedSymptomNames]
  /// covers the much more common case of a symptom typed into the standalone
  /// symptom entry form, which never creates a [UserSymptom] record at all
  /// (see `recentSymptomNamesProvider`) — without it, a symptom logged that
  /// way is never recognised again. All of these default to empty so callers
  /// that only care about generic keyword classification (e.g. existing unit
  /// tests) don't need to pass them.
  static QuickLogEntryType? classify(
    String text, {
    List<Condition> conditionCatalog = const [],
    List<UserCondition> trackedConditions = const [],
    List<Symptom> symptomCatalog = const [],
    List<UserSymptom> trackedSymptoms = const [],
    List<String> loggedSymptomNames = const [],
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final lower = trimmed.toLowerCase();
    if (_matchesVital(lower)) return QuickLogEntryType.vital;

    final wordCount = trimmed.split(RegExp(r'\s+')).length;
    if (wordCount < _minWords) return null;

    if (_matchesSleep(lower)) return QuickLogEntryType.sleep;
    if (_matchesMedication(lower)) return QuickLogEntryType.medication;
    if (_matchesDoctor(lower)) return QuickLogEntryType.doctorVisit;
    if (_matchesMeal(lower)) return QuickLogEntryType.meal;
    if (_matchesActivity(lower)) return QuickLogEntryType.activity;
    if (_matchesConditionKeyword(lower) ||
        QuickLogParser.matchCondition(
              trimmed,
              conditionCatalog,
              trackedConditions,
            ) !=
            null) {
      return QuickLogEntryType.condition;
    }
    if (_matchesSymptom(lower) ||
        QuickLogParser.matchSymptom(
              trimmed,
              symptomCatalog,
              trackedSymptoms,
              loggedNames: loggedSymptomNames,
            ) !=
            null) {
      return QuickLogEntryType.symptom;
    }
    return QuickLogEntryType.journal;
  }

  // ── Pattern matchers ─────────────────────────────────────────────────────

  static bool _matchesVital(String lower) {
    // Blood pressure and heart rate/pulse share bounds-checked parsing with
    // QuickLogParser, so an unbounded fraction ("3/4 of a sandwich") or a
    // typed date ("9/17") never lights up a chip the save step would then
    // reject, and "HR 72"/"Pulse 72" (no "bpm" unit) still get one.
    if (QuickLogParser.parseBloodPressure(lower) != null) return true;
    if (QuickLogParser.parseHeartRate(lower) != null) return true;
    // Height as feet'inches (e.g. "4'8"" or "4'8")
    if (RegExp(r'''\d{1,2}\s*'\s*\d{1,2}\s*"?''').hasMatch(lower)) {
      return true;
    }
    // Number + recognised unit (including height in cm and respiratory rate
    // in br/min — without this branch, "Respiratory rate 16 br/min" falls
    // through to the word-count-gated keyword checks below and gets
    // misclassified as Meal, since "rate" contains the substring "ate").
    return RegExp(
      r'\d+(\.\d+)?\s*'
      r'(mmhg|°c|°f|degrees?|%|kg|lbs?|lb|mmol|mg/dl|cm|'
      r'br/min|breaths?\s*(?:per\s*minute|/\s*min))',
      caseSensitive: false,
    ).hasMatch(lower);
  }

  // Checked before medication so "took a nap" is not read as a dose ('took'),
  // and before meal so "slept badly after dinner" stays a sleep entry.
  static bool _matchesSleep(String lower) => _any(lower, [
    'slept',
    'sleep',
    'nap ',
    'napped',
    'a nap',
    'insomnia',
    'woke up',
    'woke ',
    'waking',
    'overslept',
  ]);

  static bool _matchesMedication(String lower) => _any(lower, [
    'took',
    'taken',
    ' mg',
    'pill',
    'tablet',
    'capsule',
    'medication',
    'medicine',
    'prescribed',
    'paracetamol',
    'ibuprofen',
    'naproxen',
    'prednisolone',
    'methotrexate',
    'hydroxychloroquine',
  ]);

  static bool _matchesDoctor(String lower) =>
      lower.contains('dr.') ||
      lower.contains('dr ') ||
      _any(lower, [
        'doctor',
        'appointment',
        'clinic',
        'hospital',
        'physio',
        'consultant',
        'specialist',
        'rheumatol',
        'saw dr',
      ]);

  static bool _matchesMeal(String lower) => _any(lower, [
    'ate',
    'drank',
    'drink',
    'breakfast',
    'lunch',
    'dinner',
    'snack',
    'eating',
    'supper',
    'brunch',
    'meal',
    'food',
    'grilled',
    'salad',
    'soup',
    'sandwich',
  ]);

  // Generic condition/diagnosis-status language — independent of whether the
  // named condition itself is in the catalogue or already tracked, mirroring
  // how _matchesSymptom's generic word list works alongside catalogue-aware
  // matching.
  static bool _matchesConditionKeyword(String lower) =>
      _any(lower, ['diagnosed', 'diagnosis', 'remission', 'relapse']);

  static bool _matchesSymptom(String lower) => _any(lower, [
    'pain',
    'ache',
    'hurt',
    'sore',
    'tired',
    'fatigue',
    'nausea',
    'nauseated',
    'nauseous',
    'dizzy',
    'swollen',
    'swelling',
    'stiff',
    'stiffness',
    'flare',
    'itchy',
    'rash',
    'fever',
    'headache',
    'migraine',
    'cramping',
    'cramp',
  ]);

  static bool _matchesActivity(String lower) => _any(lower, [
    'walked',
    'walking',
    'went for a walk',
    'yoga',
    'stretching',
    'exercise',
    'exercised',
    'rest day',
    'rested',
    'housework',
    'cleaning',
    'gardening',
    'physio',
    'physiotherapy',
    'gentle',
    'activity',
    'minutes of',
    'min walk',
    'min run',
  ]);

  static bool _any(String text, List<String> keywords) =>
      keywords.any(text.contains);
}
