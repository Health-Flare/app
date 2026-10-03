/// Display-only unit conversion for vital readings.
///
/// Stored readings are never rewritten; this only changes what is shown.
abstract final class VitalUnits {
  // mg/dL per mmol/L for glucose (molar mass 180.16 g/mol). Glucose only.
  static const double _glucoseFactor = 18.016;
  static const double _lbsPerKg = 2.2046226218;
  static const double _cmPerIn = 2.54;

  /// Converts [value] from unit [from] to unit [to].
  ///
  /// Returns [value] unchanged when the units match or the pair is unknown.
  static double convert(
    double value, {
    required String from,
    required String to,
  }) {
    if (from == to) return value;
    return switch ((from, to)) {
      ('°C', '°F') => value * 9 / 5 + 32,
      ('°F', '°C') => (value - 32) * 5 / 9,
      ('kg', 'lbs') => value * _lbsPerKg,
      ('lbs', 'kg') => value / _lbsPerKg,
      ('mmol/L', 'mg/dL') => value * _glucoseFactor,
      ('mg/dL', 'mmol/L') => value / _glucoseFactor,
      ('cm', 'in') => value / _cmPerIn,
      ('in', 'cm') => value * _cmPerIn,
      _ => value,
    };
  }
}
