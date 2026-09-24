import 'package:health_flare/features/quick_log/quick_log_text.dart';
import 'package:health_flare/models/activity_entry.dart';
import 'package:health_flare/models/condition.dart';
import 'package:health_flare/models/medication.dart';
import 'package:health_flare/models/symptom.dart';
import 'package:health_flare/models/user_condition.dart';
import 'package:health_flare/models/user_symptom.dart';
import 'package:health_flare/models/vital_type.dart';

/// A vital measurement extracted from freeform quick-log text.
class ParsedVital {
  const ParsedVital({
    required this.vitalType,
    required this.value,
    this.value2,
    required this.unit,
  });

  final VitalType vitalType;
  final double value;

  /// Diastolic pressure when [vitalType] is [VitalType.bloodPressure].
  final double? value2;

  final String unit;
}

/// Offline extraction of structured values from quick-log text.
///
/// Complements [QuickLogClassifier]: the classifier decides *what kind* of
/// entry the text describes; this parser pulls out the values needed to save
/// it as a structured record. When parsing fails, callers fall back to a
/// journal entry so the user's text is never lost.
abstract final class QuickLogParser {
  /// Extracts a vital measurement, or null when no confident match is found.
  ///
  /// When the text contains both a blood-pressure and a pulse reading (e.g.
  /// "BP 118/76, pulse 68bpm"), only the blood pressure is returned here:
  /// use [parseVitals] to get both.
  static ParsedVital? parseVital(String text) {
    final lower = text.toLowerCase();

    final bp = parseBloodPressure(lower);
    if (bp != null) return _bloodPressureVital(bp);

    final hr = parseHeartRate(lower);
    if (hr != null) return _heartRateVital(hr);

    final temp = _number(lower, r'°\s*[cf]|degrees?|celsius|fahrenheit');
    if (temp != null) {
      // Explicit F marker, or a value no living body reaches in Celsius.
      final fahrenheit =
          RegExp(r'°\s*f|fahrenheit|degrees?\s*f\b').hasMatch(lower) ||
          temp >= 45;
      return ParsedVital(
        vitalType: VitalType.temperature,
        value: temp,
        unit: fahrenheit ? '°F' : '°C',
      );
    }

    final spo2 = _number(lower, r'%');
    if (spo2 != null && spo2 >= 50 && spo2 <= 100) {
      return ParsedVital(
        vitalType: VitalType.oxygenSaturation,
        value: spo2,
        unit: VitalType.oxygenSaturation.defaultUnit,
      );
    }

    final respiratoryRate = _number(
      lower,
      r'br/min|breaths?\s*(?:per\s*minute|/\s*min)',
    );
    if (respiratoryRate != null) {
      return ParsedVital(
        vitalType: VitalType.respiratoryRate,
        value: respiratoryRate,
        unit: VitalType.respiratoryRate.defaultUnit,
      );
    }

    final glucoseMmol = _number(lower, r'mmol(/l)?');
    if (glucoseMmol != null) {
      return ParsedVital(
        vitalType: VitalType.bloodGlucose,
        value: glucoseMmol,
        unit: 'mmol/L',
      );
    }
    final glucoseMgdl = _number(lower, r'mg/dl');
    if (glucoseMgdl != null) {
      return ParsedVital(
        vitalType: VitalType.bloodGlucose,
        value: glucoseMgdl,
        unit: 'mg/dL',
      );
    }

    final peakFlow = _parsePeakFlow(lower);
    if (peakFlow != null) return peakFlow;

    final steps = _parseSteps(lower);
    if (steps != null) return steps;

    final weight = _parseWeight(lower);
    if (weight != null) return weight;

    final heightImperial = _heightFeetInches(lower);
    if (heightImperial != null) return heightImperial;

    final heightCm = _number(lower, r'cm');
    if (heightCm != null && heightCm >= 30 && heightCm <= 250) {
      return ParsedVital(
        vitalType: VitalType.height,
        value: heightCm,
        unit: 'cm',
      );
    }

    return null;
  }

  /// Extracts every structured vital reading found in [text]. Unlike
  /// [parseVital], a combined blood-pressure + pulse reading (e.g.
  /// "BP 118/76, pulse 68bpm") returns both readings instead of silently
  /// discarding the pulse. Falls back to [parseVital]'s single-reading
  /// behaviour for every other vital type.
  static List<ParsedVital> parseVitals(String text) {
    final lower = text.toLowerCase();
    final bp = parseBloodPressure(lower);
    final hr = parseHeartRate(lower);
    if (bp == null && hr == null) {
      final single = parseVital(text);
      return single == null ? const [] : [single];
    }
    return [
      if (bp != null) _bloodPressureVital(bp),
      if (hr != null) _heartRateVital(hr),
    ];
  }

  /// Extracts a plausible blood-pressure reading as (systolic, diastolic),
  /// or null when no digit pair matches or the values fall outside
  /// plausible human ranges. [text] is matched case-insensitively.
  ///
  /// Shared with `QuickLogClassifier` so its suggestion chip and this
  /// parser's actual save behaviour never disagree about what counts as a
  /// blood-pressure reading (e.g. "3/4 of a sandwich" or a typed date like
  /// "9/17" must never match either).
  static (double systolic, double diastolic)? parseBloodPressure(String text) {
    final match = RegExp(
      r'(\d{2,3})\s*(?:/|over\s+)\s*(\d{2,3})',
    ).firstMatch(text.toLowerCase());
    if (match == null) return null;
    final systolic = double.parse(match.group(1)!);
    final diastolic = double.parse(match.group(2)!);
    if (systolic < 60 ||
        systolic > 260 ||
        diastolic < 30 ||
        diastolic > 160 ||
        systolic <= diastolic) {
      return null;
    }
    return (systolic, diastolic);
  }

  /// Extracts a plausible heart-rate/pulse reading in BPM, or null. [text]
  /// is matched case-insensitively.
  ///
  /// Recognises either an explicit "bpm"/"beats per minute" unit, or the
  /// keywords "pulse"/"heart rate"/"hr" immediately preceding the number:
  /// so "HR 72" and "Pulse 72" match without a unit, but a duration like
  /// "2 hr walk" (number before "hr") does not.
  static double? parseHeartRate(String text) {
    final lower = text.toLowerCase();
    final match =
        RegExp(
          r'(\d{2,3})\s*(?:bpm|beats?\s*per\s*minute)',
        ).firstMatch(lower) ??
        RegExp(
          r'(?:pulse|heart\s*rate|\bhr\b)\s*(?:was|is|of|:)?\s*(\d{2,3})\b',
        ).firstMatch(lower);
    if (match == null) return null;
    final value = double.parse(match.group(1)!);
    if (value < 30 || value > 250) return null;
    return value;
  }

  static ParsedVital _bloodPressureVital((double, double) bp) => ParsedVital(
    vitalType: VitalType.bloodPressure,
    value: bp.$1,
    value2: bp.$2,
    unit: VitalType.bloodPressure.defaultUnit,
  );

  static ParsedVital _heartRateVital(double hr) => ParsedVital(
    vitalType: VitalType.heartRate,
    value: hr,
    unit: VitalType.heartRate.defaultUnit,
  );

  /// Height written as feet+inches, e.g. "4'8"", "4'8", or "4 ft 8 in".
  static ParsedVital? _heightFeetInches(String lower) {
    final match = RegExp(
      r'''(\d{1,2})\s*(?:'|ft\b|feet\b)\s*(\d{1,2})\s*(?:"|in\b|inches?\b)?''',
    ).firstMatch(lower);
    if (match == null) return null;
    final feet = double.parse(match.group(1)!);
    final inches = double.parse(match.group(2)!);
    if (feet < 1 || feet > 8 || inches < 0 || inches > 11) return null;
    return ParsedVital(
      vitalType: VitalType.height,
      value: feet * 12 + inches,
      unit: 'in',
    );
  }

  /// Extracts a sleep duration ("slept 7 hours", "6.5 hrs", "20 minute nap"),
  /// or null. When both an hours phrase and a minutes phrase are present,
  /// the one that appears first in [text] wins.
  static Duration? parseSleepDuration(String text) {
    final lower = text.toLowerCase();
    final hour = RegExp(
      r'(\d{1,2}(?:\.\d+)?)\s*(?:h\b|hrs?\b|hours?\b)',
    ).firstMatch(lower);
    final minute = RegExp(
      r'(\d{1,3})\s*(?:mins?\b|minutes?\b)',
    ).firstMatch(lower);
    if (hour != null && (minute == null || hour.start <= minute.start)) {
      final hours = double.parse(hour.group(1)!);
      if (hours <= 0 || hours > 24) return null;
      return Duration(minutes: (hours * 60).round());
    }
    if (minute != null) {
      final mins = int.parse(minute.group(1)!);
      if (mins <= 0 || mins > 24 * 60) return null;
      return Duration(minutes: mins);
    }
    return null;
  }

  /// True when the text is a daytime rest rather than a night's sleep.
  static bool isNap(String text) => QuickLogText.mentionsAny(text, const [
    'nap',
    'napped',
    'dozed',
    'snooze',
  ]);

  /// Extracts a bedtime/wake-time range ("8pm to 4am", "20:00 to 4:00",
  /// "8pm-4am"), anchored to [referenceTime]'s calendar date, or null when
  /// no range is found.
  ///
  /// Wake time is placed on [referenceTime]'s date — Quick Log's timestamp
  /// is assumed to be close to when the entry was logged, i.e. shortly after
  /// waking, mirroring how [parseSleepDuration]'s callers treat the entry
  /// timestamp as wake time. Bedtime is placed on the same date unless its
  /// clock time isn't strictly before wake's clock time, in which case it
  /// rolls back one day (so "8pm to 4am" always crosses midnight, while a
  /// same-day nap like "1am to 3am" does not).
  ///
  /// Each side of the range must be an unambiguous clock time: 12-hour form
  /// requires an "am"/"pm" marker ("8pm", "8:30pm"), 24-hour form requires a
  /// colon and no marker ("20:00", "4:00") — the colon is what keeps this
  /// from colliding with a bare duration number like the "6" in "slept 6
  /// hours", so this and [parseSleepDuration] never both match the same
  /// text.
  static (DateTime bedtime, DateTime wakeTime)? parseSleepTimeRange(
    String text,
    DateTime referenceTime,
  ) {
    final match = RegExp(
      r'(\d{1,2}(?::\d{2})?\s*(?:am|pm)?\b)\s*(?:to|-|–|—)\s*'
      r'(\d{1,2}(?::\d{2})?\s*(?:am|pm)?\b)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;

    final bed = _parseClockTime(match.group(1)!);
    final wake = _parseClockTime(match.group(2)!);
    if (bed == null || wake == null) return null;

    final wakeDate = DateTime(
      referenceTime.year,
      referenceTime.month,
      referenceTime.day,
    );
    final wakeTime = wakeDate.add(Duration(hours: wake.$1, minutes: wake.$2));
    var bedtime = wakeDate.add(Duration(hours: bed.$1, minutes: bed.$2));
    if (!bedtime.isBefore(wakeTime)) {
      bedtime = bedtime.subtract(const Duration(days: 1));
    }
    return (bedtime, wakeTime);
  }

  /// Parses a single clock-time token as (hour, minute) in 24-hour form, or
  /// null when it matches neither the 12-hour ("8pm", "8:30pm") nor 24-hour
  /// ("20:00", "4:00") shape.
  static (int, int)? _parseClockTime(String token) {
    final trimmed = token.trim();

    final ampm = RegExp(
      r'^(\d{1,2})(?::(\d{2}))?\s*(am|pm)$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (ampm != null) {
      var hour = int.parse(ampm.group(1)!);
      final minute = ampm.group(2) != null ? int.parse(ampm.group(2)!) : 0;
      if (hour < 1 || hour > 12 || minute > 59) return null;
      final isPm = ampm.group(3)!.toLowerCase() == 'pm';
      hour %= 12;
      if (isPm) hour += 12;
      return (hour, minute);
    }

    final h24 = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
    if (h24 != null) {
      final hour = int.parse(h24.group(1)!);
      final minute = int.parse(h24.group(2)!);
      if (hour > 23 || minute > 59) return null;
      return (hour, minute);
    }

    return null;
  }

  /// Finds the medication whose name appears in [text], preferring the
  /// longest name so "methotrexate injection" beats "methotrexate".
  /// Returns null when no known medication is mentioned.
  static Medication? matchMedication(
    String text,
    List<Medication> medications,
  ) {
    final lower = text.toLowerCase();
    Medication? best;
    for (final med in medications) {
      final name = med.name.trim().toLowerCase();
      if (name.length < 3) continue;
      if (!lower.contains(name)) continue;
      if (best == null || name.length > best.name.trim().length) {
        best = med;
      }
    }
    return best;
  }

  /// Finds the condition whose name appears in [text], preferring the
  /// longest name. Matches against the global catalogue (custom conditions
  /// created by other profiles, [Condition.global] == false, are excluded)
  /// plus every condition [trackedConditions] says the active profile has
  /// already started tracking, so a profile's own custom condition is
  /// still recognised even though it isn't in the global set. Returns null
  /// when nothing matches.
  static Condition? matchCondition(
    String text,
    List<Condition> catalogConditions,
    List<UserCondition> trackedConditions,
  ) {
    final candidates = <int, Condition>{
      for (final c in catalogConditions)
        if (c.global) c.id: c,
      for (final tc in trackedConditions)
        tc.conditionId: Condition(
          id: tc.conditionId,
          name: tc.conditionName,
          global: false,
        ),
    };
    Condition? best;
    for (final c in candidates.values) {
      if (!textMentionsName(text, c.name)) continue;
      if (QuickLogText.isNegated(text, c.name)) continue;
      if (best == null || c.name.trim().length > best.name.trim().length) {
        best = c;
      }
    }
    return best;
  }

  /// Finds the symptom whose name appears in [text], preferring the longest
  /// name. Matches against the global catalogue, every symptom
  /// [trackedSymptoms] says the active profile is tracking (added via the
  /// Illnesses screen's "common symptoms" chips), and every name in
  /// [loggedNames] the profile has typed into the standalone symptom entry
  /// form: the most common way symptoms actually get created, and one that
  /// never touches the [UserSymptom] catalogue at all (it only records a
  /// free-text `SymptomEntry.name`; see `recentSymptomNamesProvider`). A
  /// symptom typed there is still recognised on every mention after its
  /// first, slower entry. Returns null when nothing matches.
  static Symptom? matchSymptom(
    String text,
    List<Symptom> catalogSymptoms,
    List<UserSymptom> trackedSymptoms, {
    List<String> loggedNames = const [],
  }) {
    final candidates = <int, Symptom>{
      for (final s in catalogSymptoms)
        if (s.global) s.id: s,
      for (final ts in trackedSymptoms)
        ts.symptomId: Symptom(
          id: ts.symptomId,
          name: ts.symptomName,
          global: false,
        ),
    };
    Symptom? best;
    for (final s in candidates.values) {
      if (!textMentionsName(text, s.name)) continue;
      if (QuickLogText.isNegated(text, s.name)) continue;
      if (best == null || s.name.trim().length > best.name.trim().length) {
        best = s;
      }
    }
    // Logged-only names have no catalogue id, so they're matched separately
    // rather than folded into the id-keyed map above (which would collide
    // across distinct names with no real id of their own).
    for (final name in loggedNames) {
      if (!textMentionsName(text, name)) continue;
      if (QuickLogText.isNegated(text, name)) continue;
      if (best == null || name.trim().length > best.name.trim().length) {
        best = Symptom(id: -1, name: name, global: false);
      }
    }
    return best;
  }

  /// Extracts a 1-10 symptom severity rating from free text, or null when
  /// nothing confident can be found: callers should fall back to a
  /// sensible neutral default rather than leaving the field unset.
  ///
  /// An explicit numeric scale ("7/10", "pain level 8", "severity: 6") wins
  /// over qualitative words ("mild", "severe", "excruciating"), which are
  /// mapped to representative points on the same 1-10 scale.
  static int? parseSeverity(String text) {
    final lower = text.toLowerCase();

    final scaleMatch =
        RegExp(r'(\d{1,2})\s*(?:/\s*10|out of 10)\b').firstMatch(lower) ??
        RegExp(
          r'(?:severity|pain)\s*(?:of|is|was|at|level)?\s*:?\s*(\d{1,2})\b',
        ).firstMatch(lower);
    if (scaleMatch != null) {
      final value = int.tryParse(scaleMatch.group(1)!);
      if (value != null && value >= 1 && value <= 10) return value;
    }

    const bands = [
      (
        [
          'unbearable',
          'excruciating',
          'agonizing',
          'agonising',
          'worst ever',
          'worst pain',
        ],
        9,
      ),
      (['severe', 'intense', 'terrible', 'awful', 'horrible'], 7),
      (['moderate'], 5),
      (['mild', 'slight', 'minor'], 3),
    ];
    for (final (keywords, value) in bands) {
      if (QuickLogText.mentionsAny(text, keywords)) return value;
    }
    return null;
  }

  /// True if [text] signals a *fresh* diagnosis ("diagnosed", "diagnosis",
  /// "found out") rather than just mentioning a condition the profile may
  /// already have had for years: used to decide whether "now" is a
  /// trustworthy stand-in for an unstated diagnosis date.
  static bool mentionsNewDiagnosis(String text) {
    final lower = text.toLowerCase();
    return RegExp(r'\bdiagnos(?:ed|is)\b').hasMatch(lower) ||
        lower.contains('found out');
  }

  /// Infers a [ConditionStatus] transition signalled by [text] ("in
  /// remission" → [ConditionStatus.inRecovery], "relapsed" →
  /// [ConditionStatus.active]), or null when the text carries no explicit
  /// status language.
  static ConditionStatus? parseConditionStatus(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('remission')) return ConditionStatus.inRecovery;
    if (RegExp(r'\brelaps').hasMatch(lower)) return ConditionStatus.active;
    return null;
  }

  /// True if [text] mentions [name] as a whole word (with a short plural
  /// suffix), or (for a multi-word [name]) via its capital-letter acronym
  /// written out in full, e.g. "ME" for "Myalgic Encephalomyelitis". Names
  /// shorter than 3 characters never match, to avoid common short words
  /// false-positiving. The acronym check is case-sensitive against the
  /// original [text] (not lower-cased) so a lowercase "me" never triggers it.
  static bool textMentionsName(String text, String name) {
    final trimmedName = name.trim();
    if (trimmedName.length < 3) return false;
    if (QuickLogText.mentions(text, trimmedName)) return true;
    final acronym = _acronym(trimmedName);
    if (acronym.length < 2) return false;
    // RegExp.escape guards a name like "Lupus (SLE)": its acronym's first
    // punctuation-adjacent letter is still plain text, but nothing here
    // stops a future name shape from landing an unescaped regex
    // metacharacter in \b<acronym>\b and crashing every classify() call.
    return RegExp(r'\b' + RegExp.escape(acronym) + r'\b').hasMatch(text);
  }

  /// Initials of each word in [name] (skipping words with no letters at
  /// all), or '' when fewer than two words contribute a letter: a
  /// one-word acronym would be indistinguishable from the name itself and
  /// is more likely to false-positive.
  ///
  /// Uses each word's first *letter* rather than its first character, so a
  /// parenthesised name like "Lupus (SLE)" contributes 'S' (from "SLE"),
  /// not '(' from "(SLE)".
  static String _acronym(String name) {
    final words = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final letters = [
      for (final w in words) RegExp('[A-Za-z]').firstMatch(w)?.group(0),
    ].whereType<String>();
    if (letters.length < 2) return '';
    return letters.map((l) => l.toUpperCase()).join();
  }

  /// First number immediately followed by [unitPattern].
  static double? _number(String lower, String unitPattern) {
    final match = RegExp(
      r'(\d{1,3}(?:\.\d+)?)\s*(?:' + unitPattern + r')',
    ).firstMatch(lower);
    if (match == null) return null;
    return double.parse(match.group(1)!);
  }

  static ParsedVital? _parseWeight(String lower) {
    if (_isWeightChange(lower)) return null;

    final stone = RegExp(
      r'(\d{1,2})\s*(?:st|stone)\b(?:\s*(\d{1,2})(?:\s*(?:lb|lbs|pounds?))?)?',
    ).firstMatch(lower);
    if (stone != null) {
      final stones = int.parse(stone.group(1)!);
      final pounds = stone.group(2) != null ? int.parse(stone.group(2)!) : 0;
      if (stones < 2 || stones > 40 || pounds < 0 || pounds > 13) return null;
      return ParsedVital(
        vitalType: VitalType.weight,
        value: (stones * 14 + pounds).toDouble(),
        unit: 'lbs',
      );
    }

    final weight = _number(lower, r'kg|lbs?\b|pounds?\b');
    if (weight == null) return null;
    final pounds = RegExp(r'\d\s*(?:lbs?|pounds?)\b').hasMatch(lower);
    return ParsedVital(
      vitalType: VitalType.weight,
      value: weight,
      unit: pounds ? 'lbs' : 'kg',
    );
  }

  /// A weight *change* ("lost 2kg", "gained 3 lbs", "put on 4kg") is not an
  /// absolute reading.
  static bool _isWeightChange(String lower) => RegExp(
    r'\b(?:lost|lose|gained|gain|put\s+on|down|up)\b(?:\s+\w+){0,3}\s+\d',
  ).hasMatch(lower);

  static ParsedVital? _parsePeakFlow(String lower) {
    final hasKeyword = RegExp(r'\b(?:peak\s*flow|pef|pefr)\b').hasMatch(lower);
    final hasUnit = RegExp(r'\bl\s*/\s*min\b').hasMatch(lower);
    if (!hasKeyword && !hasUnit) return null;
    final match = RegExp(r'(\d{2,3})').firstMatch(lower);
    if (match == null) return null;
    final value = double.parse(match.group(1)!);
    if (value < 50 || value > 900) return null;
    return ParsedVital(
      vitalType: VitalType.peakFlow,
      value: value,
      unit: 'L/min',
    );
  }

  static ParsedVital? _parseSteps(String lower) {
    final match = RegExp(
      r'(\d{1,3}(?:,\d{3})+|\d{1,6})\s*steps?\b',
    ).firstMatch(lower);
    if (match == null) return null;
    final value = double.parse(match.group(1)!.replaceAll(',', ''));
    if (value < 0 || value > 100000) return null;
    return ParsedVital(vitalType: VitalType.steps, value: value, unit: 'steps');
  }

  /// Dose status implied by the text, or null when it is an ordinary taken
  /// dose (or not a dose at all).
  ///
  /// `missed` / `forgot` / `didn't take` / `ran out` → `missed`.
  /// `skipped` / `skip` → `skipped`.
  static String? parseDoseStatus(String text) {
    final lower = text.toLowerCase();
    if (QuickLogText.mentionsAny(text, const ['missed', 'forgot']) ||
        RegExp(r"\b(?:did not|didn't)\s+take\b").hasMatch(lower) ||
        RegExp(r'\bran out\b').hasMatch(lower)) {
      return 'missed';
    }
    if (QuickLogText.mentionsAny(text, const ['skipped', 'skip'])) {
      return 'skipped';
    }
    return null;
  }

  /// True when the text is about changing a prescription, not logging a dose.
  static bool isDoseChange(String text) =>
      QuickLogText.mentionsAny(text, const [
        'upped',
        'increased',
        'reduced',
        'lowered',
        'stopped',
        'started',
        'switched',
      ]);

  static FlareIntent parseFlareIntent(String text) {
    final hasFlare =
        QuickLogText.mentions(text, 'flare') ||
        QuickLogText.mentions(text, 'flaring');
    if (!hasFlare) return FlareIntent.none;
    final ending =
        QuickLogText.mentionsAny(text, const [
          'ended',
          'settled',
          'settling',
        ]) ||
        RegExp(
          r"\b(?:coming out of|out of the flare|feels over|flare(?:'s)? over)\b",
          caseSensitive: false,
        ).hasMatch(text);
    final starting =
        QuickLogText.mentionsAny(text, const [
          'started',
          'starting',
          'began',
          'since',
        ]) ||
        RegExp(
          r'\b(?:going into|kicking off)\b',
          caseSensitive: false,
        ).hasMatch(text);
    if (ending && !starting) return FlareIntent.end;
    if (starting) return FlareIntent.start;
    return FlareIntent.none;
  }

  /// Activity type, duration and effort extracted from free text.
  /// Fields stay null when the text doesn't say.
  static ParsedActivity parseActivity(String text) {
    return ParsedActivity(
      type: _activityType(text),
      durationMinutes: _activityDuration(text),
      effortLevel: _effortLevel(text),
    );
  }

  static ActivityType? _activityType(String text) {
    if (QuickLogText.mentionsAny(text, const ['rest day', 'rested']) ||
        RegExp(
          r'\bstayed on the sofa\b',
          caseSensitive: false,
        ).hasMatch(text)) {
      return ActivityType.rest;
    }
    if (QuickLogText.mentionsAny(text, const [
          'walked',
          'walking',
          'went for a walk',
        ]) ||
        RegExp(r'\b(?:a|the)\s+walk\b', caseSensitive: false).hasMatch(text) ||
        (QuickLogText.mentions(text, 'walk') &&
            _activityDuration(text) != null)) {
      return ActivityType.walking;
    }
    if (QuickLogText.mentionsAny(text, const ['met', 'visited']) &&
        QuickLogText.mentionsAny(text, const ['friend', 'family'])) {
      return ActivityType.social;
    }
    if (QuickLogText.mentionsAny(text, const ['work', 'shift']) &&
        (RegExp(
              r'\b(?:full day|on my feet|shift)\b',
              caseSensitive: false,
            ).hasMatch(text) ||
            _activityDuration(text) != null)) {
      return ActivityType.work;
    }
    if (QuickLogText.mentionsAny(text, const [
      'housework',
      'cleaning',
      'gardening',
      'hoovered',
      'vacuumed',
      'laundry',
      'shopping',
      'cooked',
    ])) {
      return ActivityType.household;
    }
    if (QuickLogText.mentionsAny(text, const [
      'yoga',
      'stretching',
      'stretch',
      'pilates',
      'tai chi',
      'swim',
      'swimming',
      'cycled',
      'cycling',
      'bike',
      'ran',
      'run',
      'jog',
      'jogged',
      'exercise',
      'exercised',
      'gentle',
    ])) {
      return ActivityType.gentleExercise;
    }
    return null;
  }

  static int? _activityDuration(String text) {
    final lower = text.toLowerCase();
    if (RegExp(r'\bhalf an hour\b').hasMatch(lower)) return 30;
    if (RegExp(r'\ban hour\b').hasMatch(lower)) return 60;
    final duration = parseSleepDuration(text);
    if (duration == null) return null;
    return duration.inMinutes;
  }

  static int? _effortLevel(String text) {
    if (QuickLogText.mentionsAny(text, const [
      'exhausting',
      'exhausted',
      'wiped out',
    ])) {
      return 5;
    }
    if (QuickLogText.mentionsAny(text, const ['hard', 'tough']) ||
        RegExp(r'\bhard going\b', caseSensitive: false).hasMatch(text)) {
      return 4;
    }
    if (QuickLogText.mentionsAny(text, const ['moderate', 'ok'])) return 3;
    if (QuickLogText.mentionsAny(text, const ['easy', 'light'])) return 2;
    return null;
  }

  /// Reaction language on a meal, ignoring negated phrases ("no reaction").
  static bool hasMealReaction(String text) {
    const words = [
      'reaction',
      'reacted',
      'bloated',
      'bloating',
      'gassy',
      'cramp',
      'cramps',
      'hives',
      'rash',
      'itchy',
      'swelling',
      'diarrhoea',
      'diarrhea',
      'heartburn',
      'reflux',
    ];
    if (QuickLogText.mentionsAnyAffirmative(text, words)) return true;
    final lower = text.toLowerCase();
    if (RegExp(r'\bsick after\b').hasMatch(lower) &&
        !QuickLogText.isNegated(text, 'sick')) {
      return true;
    }
    if (RegExp(r'\bupset stomach\b').hasMatch(lower) &&
        !QuickLogText.isNegated(text, 'upset')) {
      return true;
    }
    return false;
  }

  /// Explicit wellbeing number only. Qualitative words are never guessed.
  static int? parseExplicitWellbeing(String text) {
    final lower = text.toLowerCase();
    final scale = RegExp(
      r'(\d{1,2})\s*(?:/\s*10|out of 10)\b',
    ).firstMatch(lower);
    final labelled = RegExp(
      r'\b(?:wellbeing|mood)\s*(?:about|is|was|of|at)?\s*:?\s*(\d{1,2})\b',
    ).firstMatch(lower);
    final match = scale ?? labelled;
    if (match == null) return null;
    final value = int.tryParse(match.group(1)!);
    if (value == null || value < 1 || value > 10) return null;
    return value;
  }

  /// "low" | "medium" | "high", or null when the text doesn't talk about stress.
  static String? parseStress(String text) {
    final lower = text.toLowerCase();
    if (RegExp(r'\blow stress\b').hasMatch(lower) ||
        QuickLogText.mentionsAny(text, const ['calm', 'relaxed'])) {
      return 'low';
    }
    if (RegExp(r'\b(?:bit|some|a little|mildly)\s+stress').hasMatch(lower)) {
      return 'medium';
    }
    if (RegExp(r'\bthrough the roof\b').hasMatch(lower) ||
        RegExp(r'\b(?:really|very|so)\s+stress').hasMatch(lower)) {
      return 'high';
    }
    if (QuickLogText.mentionsAny(text, const ['stressed', 'stress'])) {
      return 'high';
    }
    return null;
  }

  /// Cycle phase, or null. "period" needs a second signal unless it opens
  /// the sentence, so "a period of rest" does not match.
  static String? parseCyclePhase(String text) {
    if (QuickLogText.mentionsAny(text, const ['ovulation', 'ovulating'])) {
      return 'ovulation';
    }
    if (QuickLogText.mentions(text, 'luteal')) return 'luteal';
    if (QuickLogText.mentions(text, 'follicular')) return 'follicular';
    if (_mentionsPeriod(text)) return 'period';
    return null;
  }

  static bool _mentionsPeriod(String text) {
    final lower = text.toLowerCase();
    final period =
        QuickLogText.mentions(text, 'period') ||
        RegExp(r'\bmenstruat').hasMatch(lower);
    if (!period) return false;
    if (RegExp(r'^\s*period\b', caseSensitive: false).hasMatch(text)) {
      return true;
    }
    return QuickLogText.mentionsAny(text, const [
          'started',
          'flow',
          'cramp',
          'cramps',
          'heavy',
          'light',
          'spotting',
        ]) ||
        RegExp(r'\bday\s+\d+\b').hasMatch(lower);
  }

  /// Body locations, longest region first so "lower back" beats "back".
  /// Side words immediately before a region are kept ("left hip").
  static List<String> parseLocations(String text) {
    final lower = text.toLowerCase();
    final found = <String>[];
    final consumed = <RegExpMatch>[];
    for (final region in _bodyRegions) {
      for (final synonym in region.synonyms) {
        final match = RegExp(
          '\\b(?:(left|right|both)\\s+)?${RegExp.escape(synonym)}\\b',
        ).firstMatch(lower);
        if (match == null) continue;
        if (consumed.any(
          (earlier) => match.start < earlier.end && earlier.start < match.end,
        )) {
          continue;
        }
        consumed.add(match);
        final side = match.group(1);
        if (side == null || side == 'both') {
          found.add(region.label);
        } else {
          found.add('$side ${_singular(synonym)}');
        }
        break;
      }
    }
    return found;
  }

  static String _singular(String synonym) {
    if (synonym.endsWith('ies')) {
      return '${synonym.substring(0, synonym.length - 3)}y';
    }
    if (synonym.endsWith('s') && !synonym.endsWith('ss')) {
      return synonym.substring(0, synonym.length - 1);
    }
    return synonym;
  }

  static ParsedFluid? parseFluid(String text) {
    final lower = text.toLowerCase();
    final ml = RegExp(r'(\d+(?:\.\d+)?)\s*ml\b').firstMatch(lower);
    if (ml != null) {
      return ParsedFluid(
        volumeMl: double.parse(ml.group(1)!).round(),
        drinkType: _drinkType(lower),
      );
    }
    final litres = RegExp(
      r'(\d+(?:\.\d+)?)\s*(?:l\b|litres?\b|liters?\b)',
    ).firstMatch(lower);
    if (litres != null) {
      return ParsedFluid(
        volumeMl: (double.parse(litres.group(1)!) * 1000).round(),
        drinkType: _drinkType(lower),
      );
    }
    final wordLitres = RegExp(
      '\\b($_numberWordPattern)\\s+(?:litres?|liters?)\\b',
    ).firstMatch(lower);
    if (wordLitres != null) {
      final n = _numberWords[wordLitres.group(1)!]!;
      return ParsedFluid(volumeMl: n * 1000, drinkType: _drinkType(lower));
    }
    final vessel = RegExp(
      '\\b(?:(\\d+)|($_numberWordPattern))\\s+(glasses?|cups?|mugs?|bottles?)\\b',
    ).firstMatch(lower);
    if (vessel != null) {
      final n = vessel.group(1) != null
          ? int.parse(vessel.group(1)!)
          : _numberWords[vessel.group(2)!]!;
      final unit = vessel.group(3)!;
      final each = unit.startsWith('glass')
          ? 250
          : unit.startsWith('cup')
          ? 240
          : unit.startsWith('mug')
          ? 300
          : 500;
      return ParsedFluid(volumeMl: n * each, drinkType: _drinkType(lower));
    }
    return null;
  }

  static String? _drinkType(String lower) {
    const types = ['electrolyte', 'water', 'coffee', 'tea', 'juice', 'milk'];
    for (final type in types) {
      if (lower.contains(type)) return type;
    }
    return null;
  }

  static ParsedElimination? parseElimination(String text) {
    final bowel =
        QuickLogText.mentionsAny(text, const [
          'stool',
          'stools',
          'bowel',
          'diarrhoea',
          'diarrhea',
          'constipated',
          'constipation',
          'bristol',
          'poo',
        ]) ||
        RegExp(r'\bbm\b', caseSensitive: false).hasMatch(text) ||
        RegExp(r'\bbowel movement\b', caseSensitive: false).hasMatch(text);
    final bladder = QuickLogText.mentionsAny(text, const [
      'urinating',
      'peeing',
      'bladder',
      'wee',
    ]);
    if (!bowel && !bladder) return null;

    final lower = text.toLowerCase();
    final bristol = RegExp(
      r'\bbristol(?:\s+type)?\s*([1-7])\b',
    ).firstMatch(lower);
    return ParsedElimination(
      kind: bowel ? 'bowel' : 'bladder',
      bristolType: bristol == null ? null : int.parse(bristol.group(1)!),
      count: _eliminationCount(lower),
      blood: RegExp(r'\bblood\b').hasMatch(lower),
      urgency: QuickLogText.mentions(text, 'urgency'),
    );
  }

  static int _eliminationCount(String lower) {
    if (RegExp(r'\b(?:nothing|no movement)\b').hasMatch(lower)) return 0;
    if (RegExp(r'\btwice\b').hasMatch(lower)) return 2;
    if (RegExp(r'\bthrice\b').hasMatch(lower)) return 3;
    final times =
        RegExp(r'\bx\s*(\d+)\b').firstMatch(lower) ??
        RegExp(r'\b(\d+)\s+times\b').firstMatch(lower);
    if (times != null) return int.parse(times.group(1)!);
    return 1;
  }

  /// Part-of-day defaults shared with relative-time parsing.
  static const morningHour = 9;
  static const afternoonHour = 15;
  static const eveningHour = 18;

  /// Shifts [now] when [text] names a relative day or clock time.
  ///
  /// Returns null when nothing was recognised. [preserveLastNight] keeps
  /// the reference time for sleep entries: "last night" describes the
  /// sleep itself, and the wake time stays at [now].
  static DateTime? parseRelativeTimestamp(
    String text,
    DateTime now, {
    bool preserveLastNight = false,
  }) {
    final lower = text.toLowerCase();
    DateTime? day;
    var hour = now.hour;
    var minute = now.minute;
    var touched = false;
    var timeSet = false;

    void setDay(DateTime value) {
      day = DateTime(value.year, value.month, value.day);
      touched = true;
    }

    void setClock(int h, int m) {
      hour = h;
      minute = m;
      timeSet = true;
      touched = true;
    }

    if (!preserveLastNight && RegExp(r'\blast night\b').hasMatch(lower)) {
      setDay(now.subtract(const Duration(days: 1)));
      if (!timeSet) setClock(21, 0);
    }
    if (RegExp(r'\byesterday\b').hasMatch(lower)) {
      setDay(now.subtract(const Duration(days: 1)));
    }
    if (RegExp(r'\btomorrow\b').hasMatch(lower)) {
      setDay(now.add(const Duration(days: 1)));
    }
    if (RegExp(r'\btoday\b').hasMatch(lower)) {
      setDay(now);
    }
    if (RegExp(r'\bthis morning\b').hasMatch(lower)) {
      setDay(now);
      setClock(morningHour, 0);
    } else if (RegExp(r'\bthis afternoon\b').hasMatch(lower)) {
      setDay(now);
      setClock(afternoonHour, 0);
    } else if (RegExp(r'\bthis evening\b').hasMatch(lower)) {
      setDay(now);
      setClock(eveningHour, 0);
    } else if (RegExp(r'\btonight\b').hasMatch(lower)) {
      setDay(now);
      setClock(21, 0);
    }

    final ago = RegExp(r'\b(\d+)\s+days?\s+ago\b').firstMatch(lower);
    if (ago != null) {
      setDay(now.subtract(Duration(days: int.parse(ago.group(1)!))));
    }

    final weekday = RegExp(
      r'\b(next|last|on)\s+(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
    ).firstMatch(lower);
    if (weekday != null) {
      final kind = weekday.group(1)!;
      final target = _weekdays[weekday.group(2)!]!;
      var delta = (target - now.weekday) % 7;
      if (delta < 0) delta += 7;
      if (kind == 'next') {
        if (delta == 0) delta = 7;
      } else if (kind == 'last') {
        delta = delta == 0 ? -7 : delta - 7;
      }
      setDay(DateTime(now.year, now.month, now.day).add(Duration(days: delta)));
      if (!timeSet) setClock(morningHour, 0);
    }

    final at = RegExp(
      r'\bat\s+(\d{1,2}(?::\d{2})?\s*(?:am|pm)?)\b',
    ).firstMatch(lower);
    if (at != null) {
      final clock = _parseLooseClock(at.group(1)!);
      if (clock != null) setClock(clock.$1, clock.$2);
    }

    if (!touched) return null;
    final date = day ?? DateTime(now.year, now.month, now.day);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static (int, int)? _parseLooseClock(String token) {
    final strict = _parseClockTime(token);
    if (strict != null) return strict;
    final bare = RegExp(r'^(\d{1,2})$').firstMatch(token.trim());
    if (bare == null) return null;
    final hour = int.parse(bare.group(1)!);
    if (hour > 23) return null;
    return (hour, 0);
  }

  static const _weekdays = {
    'monday': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'friday': DateTime.friday,
    'saturday': DateTime.saturday,
    'sunday': DateTime.sunday,
  };

  static const _numberWords = {
    'a': 1,
    'an': 1,
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
    'ten': 10,
  };

  static String get _numberWordPattern => _numberWords.keys.join('|');

  static const _bodyRegions = [
    _BodyRegion('lower back', ['lower back', 'lumbar']),
    _BodyRegion('upper back', ['upper back']),
    _BodyRegion('hands', ['fingers', 'finger', 'hands', 'hand']),
    _BodyRegion('feet', ['ankles', 'ankle', 'feet', 'foot']),
    _BodyRegion('knees', ['knees', 'knee']),
    _BodyRegion('wrists', ['wrists', 'wrist']),
    _BodyRegion('hips', ['hips', 'hip']),
    _BodyRegion('shoulders', ['shoulders', 'shoulder']),
    _BodyRegion('elbows', ['elbows', 'elbow']),
    _BodyRegion('neck', ['neck']),
    _BodyRegion('head', ['forehead', 'temples', 'temple', 'head']),
    _BodyRegion('chest', ['chest']),
    _BodyRegion('abdomen', ['abdomen', 'stomach', 'belly']),
    _BodyRegion('back', ['back']),
    _BodyRegion('arms', ['arms', 'arm']),
    _BodyRegion('legs', ['legs', 'leg']),
    _BodyRegion('throat', ['throat']),
  ];

  /// Canonical body-region labels, for the symptom form picker.
  static List<String> get bodyLocationLabels =>
      _bodyRegions.map((region) => region.label).toList();
}

/// Whether flare language starts a flare, ends one, or is just a mention.
enum FlareIntent { start, end, none }

class ParsedActivity {
  const ParsedActivity({this.type, this.durationMinutes, this.effortLevel});

  final ActivityType? type;
  final int? durationMinutes;
  final int? effortLevel;
}

class ParsedFluid {
  const ParsedFluid({required this.volumeMl, this.drinkType});

  final int volumeMl;
  final String? drinkType;
}

class ParsedElimination {
  const ParsedElimination({
    required this.kind,
    required this.count,
    required this.blood,
    required this.urgency,
    this.bristolType,
  });

  /// `bowel` or `bladder`.
  final String kind;
  final int? bristolType;
  final int count;
  final bool blood;
  final bool urgency;
}

class _BodyRegion {
  const _BodyRegion(this.label, this.synonyms);

  final String label;
  final List<String> synonyms;
}
