import 'package:health_flare/features/quick_log/quick_log_parser.dart';
import 'package:health_flare/features/quick_log/quick_log_text.dart';
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
  flare,
  mood,
  cycle,
  hydration,
  bowel,
}

/// Offline, keyword-based classifier for freeform quick-log text.
///
/// Scores each category and picks the highest. Ties break in
/// [_tieBreak] order (the historical first-match order, with newer
/// types inserted where their signals are more specific). Generic verbs
/// such as "took" never win on their own.
///
/// Returns null when the text is too short or too ambiguous to classify,
/// except for unambiguous vital and fluid readings, which skip the
/// word-count gate.
abstract final class QuickLogClassifier {
  static const _minWords = 3;

  /// Minimum score that counts as a real signal. Below this the text
  /// falls through to Journal (or null, when it is too short).
  static const _threshold = 20;

  static const _tieBreak = [
    QuickLogEntryType.vital,
    QuickLogEntryType.sleep,
    QuickLogEntryType.medication,
    QuickLogEntryType.doctorVisit,
    QuickLogEntryType.hydration,
    QuickLogEntryType.meal,
    QuickLogEntryType.activity,
    QuickLogEntryType.flare,
    QuickLogEntryType.condition,
    QuickLogEntryType.bowel,
    QuickLogEntryType.symptom,
    QuickLogEntryType.mood,
    QuickLogEntryType.cycle,
    QuickLogEntryType.journal,
  ];

  static QuickLogEntryType? classify(
    String text, {
    List<Condition> conditionCatalog = const [],
    List<UserCondition> trackedConditions = const [],
    List<Symptom> symptomCatalog = const [],
    List<UserSymptom> trackedSymptoms = const [],
    List<String> loggedSymptomNames = const [],
    List<String> medicationNames = const [],
    bool cycleTrackingEnabled = false,
    bool bowelTrackingEnabled = false,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final scores = _score(
      trimmed,
      conditionCatalog: conditionCatalog,
      trackedConditions: trackedConditions,
      symptomCatalog: symptomCatalog,
      trackedSymptoms: trackedSymptoms,
      loggedSymptomNames: loggedSymptomNames,
      medicationNames: medicationNames,
      cycleTrackingEnabled: cycleTrackingEnabled,
      bowelTrackingEnabled: bowelTrackingEnabled,
    );

    QuickLogEntryType? best;
    var bestScore = _threshold - 1;
    for (final type in _tieBreak) {
      final score = scores[type] ?? 0;
      if (score > bestScore) {
        best = type;
        bestScore = score;
      }
    }

    final words = trimmed.split(RegExp(r'\s+')).length;
    final shortReading =
        best == QuickLogEntryType.vital || best == QuickLogEntryType.hydration;
    if (words < _minWords && !shortReading) return null;
    return best ?? QuickLogEntryType.journal;
  }

  static Map<QuickLogEntryType, int> _score(
    String text, {
    required List<Condition> conditionCatalog,
    required List<UserCondition> trackedConditions,
    required List<Symptom> symptomCatalog,
    required List<UserSymptom> trackedSymptoms,
    required List<String> loggedSymptomNames,
    required List<String> medicationNames,
    required bool cycleTrackingEnabled,
    required bool bowelTrackingEnabled,
  }) {
    final scores = {for (final type in QuickLogEntryType.values) type: 0};
    final lower = text.toLowerCase();

    if (QuickLogParser.parseVitals(text).isNotEmpty) {
      scores[QuickLogEntryType.vital] = 100;
    }

    scores[QuickLogEntryType.sleep] = _sleepScore(text);
    scores[QuickLogEntryType.medication] = _medicationScore(
      text,
      medicationNames,
    );
    scores[QuickLogEntryType.doctorVisit] = _doctorScore(text);
    scores[QuickLogEntryType.activity] = _activityScore(text);
    scores[QuickLogEntryType.condition] = _conditionScore(
      text,
      conditionCatalog,
      trackedConditions,
    );
    scores[QuickLogEntryType.symptom] = _symptomScore(
      text,
      symptomCatalog,
      trackedSymptoms,
      loggedSymptomNames,
    );
    scores[QuickLogEntryType.flare] = _flareScore(text);
    scores[QuickLogEntryType.meal] = _mealScore(
      text,
      lower,
      symptomScore: scores[QuickLogEntryType.symptom]!,
    );
    scores[QuickLogEntryType.hydration] = _hydrationScore(
      text,
      mealScore: scores[QuickLogEntryType.meal]!,
    );
    scores[QuickLogEntryType.mood] = _moodScore(
      text,
      symptomScore: scores[QuickLogEntryType.symptom]!,
      conditionScore: scores[QuickLogEntryType.condition]!,
    );
    if (cycleTrackingEnabled) {
      scores[QuickLogEntryType.cycle] = _cycleScore(text);
    }
    if (bowelTrackingEnabled) {
      scores[QuickLogEntryType.bowel] = _bowelScore(text);
    }

    // A bare "flare" is a symptom. Start/end language is a flare, and
    // should outrank the symptom hit on the same word.
    if ((scores[QuickLogEntryType.flare] ?? 0) >= _threshold) {
      scores[QuickLogEntryType.symptom] = 0;
    }

    return scores;
  }

  static int _sleepScore(String text) {
    if (QuickLogText.mentionsAny(text, const [
      'slept',
      'sleep',
      'nap',
      'napped',
      'insomnia',
      'overslept',
      'dozed',
      'snooze',
    ])) {
      return 50;
    }
    if (QuickLogText.mentionsAny(text, const ['woke up', 'woke', 'waking']) &&
        !QuickLogText.mentionsAny(text, const ['walk', 'walked', 'walking'])) {
      return 45;
    }
    return 0;
  }

  static int _medicationScore(String text, List<String> medicationNames) {
    if (QuickLogParser.isDoseChange(text) &&
        QuickLogParser.parseDoseStatus(text) == null &&
        !QuickLogText.mentionsAny(text, const ['took', 'taken'])) {
      return 0;
    }

    var score = 0;
    if (QuickLogText.mentionsAny(text, const ['took', 'taken'])) score = 8;
    if (QuickLogText.mentionsAny(text, const [
          'pill',
          'tablet',
          'capsule',
          'medication',
          'medicine',
          'prescribed',
        ]) ||
        RegExp(r'\d+\s*mg\b', caseSensitive: false).hasMatch(text)) {
      score = 76;
    }
    if (QuickLogText.mentionsAny(text, const [
      'paracetamol',
      'ibuprofen',
      'naproxen',
      'prednisolone',
      'methotrexate',
      'hydroxychloroquine',
    ])) {
      score = 80;
    }
    for (final name in medicationNames) {
      if (QuickLogParser.textMentionsName(text, name)) {
        score = 85;
        break;
      }
    }
    if (QuickLogParser.parseDoseStatus(text) != null && score < 55) {
      score = score < 8 ? 0 : 55;
    }
    return score;
  }

  static int _doctorScore(String text) {
    final physio =
        QuickLogText.mentions(text, 'physio') ||
        QuickLogText.mentions(text, 'physiotherapy');
    final physioIsExercise =
        physio &&
        QuickLogText.mentionsAny(text, const [
          'exercise',
          'stretch',
          'routine',
        ]);
    if (physioIsExercise) return 0;

    if (RegExp(r'\bdr\.?\b', caseSensitive: false).hasMatch(text) ||
        QuickLogText.mentionsAny(text, const [
          'doctor',
          'appointment',
          'clinic',
          'hospital',
          'consultant',
          'specialist',
          'rheumatology',
          'rheumatologist',
        ]) ||
        (physio && !physioIsExercise)) {
      return 50;
    }
    return 0;
  }

  static int _activityScore(String text) {
    final lower = text.toLowerCase();
    final ranOut = RegExp(r'\bran out\b').hasMatch(lower);
    final walked =
        QuickLogText.mentionsAny(text, const [
          'walked',
          'walking',
          'went for a walk',
        ]) ||
        RegExp(r'\b(?:a|the)\s+walk\b', caseSensitive: false).hasMatch(text) ||
        (QuickLogText.mentions(text, 'walk') &&
            QuickLogParser.parseActivity(text).durationMinutes != null);
    final movement = QuickLogText.mentionsAny(text, const [
      'yoga',
      'stretching',
      'stretch',
      'exercise',
      'exercised',
      'rest day',
      'rested',
      'housework',
      'cleaning',
      'gardening',
      'gentle',
      'activity',
      'minutes of',
      'jog',
      'jogged',
      'swim',
      'swimming',
      'cycled',
      'cycling',
      'bike',
      'pilates',
      'tai chi',
      'hoovered',
      'vacuumed',
      'laundry',
      'shopping',
    ]);
    final ran = !ranOut && QuickLogText.mentionsAny(text, const ['ran', 'run']);
    if (walked || movement || ran) return 46;

    final social =
        QuickLogText.mentionsAny(text, const ['met', 'visited']) &&
        QuickLogText.mentionsAny(text, const ['friend', 'family']);
    if (social) return 46;

    final work =
        QuickLogText.mentionsAny(text, const ['work', 'shift']) &&
        (QuickLogParser.parseActivity(text).durationMinutes != null ||
            QuickLogParser.parseActivity(text).effortLevel != null ||
            RegExp(
              r'\b(?:full day|on my feet|shift)\b',
              caseSensitive: false,
            ).hasMatch(text));
    if (work) return 46;

    if (QuickLogText.mentions(text, 'physio') &&
        QuickLogText.mentionsAny(text, const [
          'exercise',
          'stretch',
          'routine',
        ])) {
      return 50;
    }
    return 0;
  }

  static int _conditionScore(
    String text,
    List<Condition> catalog,
    List<UserCondition> tracked,
  ) {
    if (QuickLogParser.matchCondition(text, catalog, tracked) != null) {
      return 72;
    }
    if (QuickLogText.mentionsAny(text, const [
      'diagnosed',
      'diagnosis',
      'remission',
      'relapse',
      'relapsed',
    ])) {
      return 55;
    }
    return 0;
  }

  static int _symptomScore(
    String text,
    List<Symptom> catalog,
    List<UserSymptom> tracked,
    List<String> loggedNames,
  ) {
    const generic = [
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
    ];
    final affirmativeGeneric = generic.where(
      (word) => QuickLogText.mentionsAffirmative(text, word),
    );
    if (affirmativeGeneric.isNotEmpty) return 46;

    final matched = QuickLogParser.matchSymptom(
      text,
      catalog,
      tracked,
      loggedNames: loggedNames,
    );
    if (matched != null && !QuickLogText.isNegated(text, matched.name)) {
      return 74;
    }
    return 0;
  }

  static int _flareScore(String text) {
    // Above a catalogue condition (72) so "Lupus flare kicking off" is a
    // flare that can still link the condition, not a condition-only save.
    return QuickLogParser.parseFlareIntent(text) == FlareIntent.none ? 0 : 80;
  }

  static int _mealScore(
    String text,
    String lower, {
    required int symptomScore,
  }) {
    if (RegExp(
      r'\b(?:skipping|skipped)\s+(?:breakfast|lunch|dinner|supper)\b',
    ).hasMatch(lower)) {
      return 0;
    }

    final strong =
        QuickLogText.mentionsAny(text, const [
          'ate',
          'snack',
          'supper',
          'brunch',
          'grilled',
          'salad',
          'soup',
          'sandwich',
          'meal',
          'food',
        ]) ||
        RegExp(
          r'\beating\s+(?:a\s+|the\s+|some\s+|my\s+)?[a-z]{3,}',
        ).hasMatch(lower) ||
        RegExp(
          r'\bfor\s+(?:breakfast|lunch|dinner|supper|brunch)\b',
        ).hasMatch(lower);

    if (strong) return 52;

    final mentionsMealtime = QuickLogText.mentionsAny(text, const [
      'breakfast',
      'lunch',
      'dinner',
    ]);
    if (!mentionsMealtime) return 0;

    final afterMeal = RegExp(
      r'\bafter\s+(?:breakfast|lunch|dinner|eating)\b',
    ).hasMatch(lower);
    if (afterMeal && symptomScore >= _threshold) return 12;
    if (afterMeal) return 40;
    return 48;
  }

  static int _hydrationScore(String text, {required int mealScore}) {
    if (mealScore >= 52) return 0;
    if (QuickLogParser.parseFluid(text) == null) return 0;
    return 60;
  }

  static int _moodScore(
    String text, {
    required int symptomScore,
    required int conditionScore,
  }) {
    if (symptomScore >= 70 || conditionScore >= 70) return 0;
    if (QuickLogText.mentionsAny(text, const [
      'anxious',
      'stressed',
      'stress',
      'mood',
      'wellbeing',
      'calm',
      'relaxed',
    ])) {
      return 44;
    }
    if (QuickLogText.mentions(text, 'low') &&
        QuickLogText.mentionsAny(text, const ['feeling', 'felt', 'mood'])) {
      return 44;
    }
    return 0;
  }

  static int _cycleScore(String text) {
    return QuickLogParser.parseCyclePhase(text) == null ? 0 : 54;
  }

  static int _bowelScore(String text) {
    return QuickLogParser.parseElimination(text) == null ? 0 : 54;
  }
}
