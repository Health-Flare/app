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
  static ParsedVital? parseVital(String text) {
    final lower = text.toLowerCase();

    // Blood pressure: "128/84" or "128 over 84", with plausibility bounds so
    // dates ("12/06") and fractions don't read as pressures.
    final bp = RegExp(
      r'(\d{2,3})\s*(?:/|over\s+)\s*(\d{2,3})',
    ).firstMatch(lower);
    if (bp != null) {
      final systolic = double.parse(bp.group(1)!);
      final diastolic = double.parse(bp.group(2)!);
      if (systolic >= 60 &&
          systolic <= 260 &&
          diastolic >= 30 &&
          diastolic <= 160 &&
          systolic > diastolic) {
        return ParsedVital(
          vitalType: VitalType.bloodPressure,
          value: systolic,
          value2: diastolic,
          unit: VitalType.bloodPressure.defaultUnit,
        );
      }
    }

    final hr = _number(lower, r'bpm');
    if (hr != null) {
      return ParsedVital(
        vitalType: VitalType.heartRate,
        value: hr,
        unit: VitalType.heartRate.defaultUnit,
      );
    }

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

    return null;
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
