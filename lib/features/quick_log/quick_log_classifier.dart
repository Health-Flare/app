/// Entry types the quick-log classifier can suggest.
enum QuickLogEntryType {
  meal,
  symptom,
  vital,
  medication,
  doctorVisit,
  activity,
  journal,
}

/// Offline, keyword-based classifier for freeform quick-log text.
///
/// Returns the best-guess [QuickLogEntryType], or null when the text is
/// too short or too ambiguous to classify confidently.
///
/// Priority order (first match wins):
///   Vital > Medication > Doctor > Meal > Symptom > Journal (fallback)
abstract final class QuickLogClassifier {
  /// Minimum word count before classification is attempted.
  static const _minWords = 3;

  /// Classify [text] and return a suggested [QuickLogEntryType].
  ///
  /// Returns null when the text has fewer than [_minWords] words.
  static QuickLogEntryType? classify(String text) {
    final trimmed = text.trim();
    final wordCount = trimmed.isEmpty
        ? 0
        : trimmed.split(RegExp(r'\s+')).length;
    if (wordCount < _minWords) return null;

    final lower = trimmed.toLowerCase();

    if (_matchesVital(lower)) return QuickLogEntryType.vital;
    if (_matchesMedication(lower)) return QuickLogEntryType.medication;
    if (_matchesDoctor(lower)) return QuickLogEntryType.doctorVisit;
    if (_matchesMeal(lower)) return QuickLogEntryType.meal;
    if (_matchesActivity(lower)) return QuickLogEntryType.activity;
    if (_matchesSymptom(lower)) return QuickLogEntryType.symptom;
    return QuickLogEntryType.journal;
  }

  // ── Pattern matchers ─────────────────────────────────────────────────────

  static bool _matchesVital(String lower) {
    // Blood-pressure: digits/digits (e.g. "120/80") or "N over N"
    if (RegExp(r'\d+/\d+').hasMatch(lower)) return true;
    if (RegExp(r'\d+\s+over\s+\d+').hasMatch(lower)) return true;
    // Number + recognised unit
    return RegExp(
      r'\d+(\.\d+)?\s*(bpm|mmhg|°c|°f|degrees?|%|kg|lbs?|lb|mmol|mg/dl)',
      caseSensitive: false,
    ).hasMatch(lower);
  }

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
