/// Display-only unit conversion for vital readings on insight charts.
///
/// Stored readings are never rewritten; this only changes what is plotted.
abstract final class VitalUnits {
  /// Converts [value] from unit [from] to unit [to].
  ///
  /// Returns [value] unchanged when the units match or the pair is unknown.
  static double convert(
    double value, {
    required String from,
    required String to,
  }) {
    // TODO(#83): not implemented yet.
    return value;
  }
}
