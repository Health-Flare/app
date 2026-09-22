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
  /// "BP 118/76, pulse 68bpm"), only the blood pressure is returned here —
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

    final weight = _number(lower, r'kg|lbs?\b');
    if (weight != null) {
      final pounds = RegExp(r'\d\s*lbs?\b').hasMatch(lower);
      return ParsedVital(
        vitalType: VitalType.weight,
        value: weight,
        unit: pounds ? 'lbs' : 'kg',
      );
    }

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
  /// keywords "pulse"/"heart rate"/"hr" immediately preceding the number —
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

  /// Extracts a sleep duration ("slept 7 hours", "6.5 hrs"), or null.
  static Duration? parseSleepDuration(String text) {
    final match = RegExp(
      r'(\d{1,2}(?:\.\d+)?)\s*(?:h\b|hrs?\b|hours?\b)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;
    final hours = double.parse(match.group(1)!);
    if (hours <= 0 || hours > 24) return null;
    return Duration(minutes: (hours * 60).round());
  }

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
  /// already started tracking — so a profile's own custom condition is
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
  /// form — the most common way symptoms actually get created, and one that
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
      if (best == null || s.name.trim().length > best.name.trim().length) {
        best = s;
      }
    }
    // Logged-only names have no catalogue id, so they're matched separately
    // rather than folded into the id-keyed map above (which would collide
    // across distinct names with no real id of their own).
    for (final name in loggedNames) {
      if (!textMentionsName(text, name)) continue;
      if (best == null || name.trim().length > best.name.trim().length) {
        best = Symptom(id: -1, name: name, global: false);
      }
    }
    return best;
  }

  /// Extracts a 1-10 symptom severity rating from free text, or null when
  /// nothing confident can be found — callers should fall back to a
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
      if (keywords.any(lower.contains)) return value;
    }
    return null;
  }

  /// True if [text] signals a *fresh* diagnosis ("diagnosed", "diagnosis",
  /// "found out") rather than just mentioning a condition the profile may
  /// already have had for years — used to decide whether "now" is a
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

  /// True if [text] mentions [name] — either as a whole-name substring, or
  /// (for a multi-word [name]) via its capital-letter acronym written out
  /// in full, e.g. "ME" for "Myalgic Encephalomyelitis". Names shorter than
  /// 3 characters never match, to avoid common short words false-positiving.
  /// The acronym check is case-sensitive against the original [text] (not
  /// lower-cased) so a lowercase "me" never triggers it.
  static bool textMentionsName(String text, String name) {
    final trimmedName = name.trim();
    if (trimmedName.length < 3) return false;
    if (text.toLowerCase().contains(trimmedName.toLowerCase())) return true;
    final acronym = _acronym(trimmedName);
    if (acronym.length < 2) return false;
    // RegExp.escape guards a name like "Lupus (SLE)" — its acronym's first
    // punctuation-adjacent letter is still plain text, but nothing here
    // stops a future name shape from landing an unescaped regex
    // metacharacter in \b<acronym>\b and crashing every classify() call.
    return RegExp(r'\b' + RegExp.escape(acronym) + r'\b').hasMatch(text);
  }

  /// Initials of each word in [name] (skipping words with no letters at
  /// all), or '' when fewer than two words contribute a letter — a
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
}
