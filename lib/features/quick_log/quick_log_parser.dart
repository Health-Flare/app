import 'package:health_flare/models/medication.dart';
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

  /// First number immediately followed by [unitPattern].
  static double? _number(String lower, String unitPattern) {
    final match = RegExp(
      r'(\d{1,3}(?:\.\d+)?)\s*(?:' + unitPattern + r')',
    ).firstMatch(lower);
    if (match == null) return null;
    return double.parse(match.group(1)!);
  }
}
