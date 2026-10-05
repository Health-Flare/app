/// How much a symptom got in the way: a five-step scale in our own words.
///
/// Separating intensity (how bad) from interference (how much it got in the
/// way) comes from Dr Cat Hicks's Informed Patient method, which uses PROMIS
/// research as its benchmark for symptom measurement. These labels are ours.
/// They are not PROMIS items and produce no PROMIS score.
/// Sources: `lib/core/citations/symptom_sources.dart`.
abstract final class Interference {
  /// Labels for values 1 to 5, in order.
  static const List<String> labels = [
    'Not at all',
    'A little',
    'Somewhat',
    'Quite a bit',
    'Very much',
  ];

  /// The label for a stored value, or null when not recorded or out of range.
  static String? label(int? value) {
    if (value == null || value < 1 || value > labels.length) return null;
    return labels[value - 1];
  }
}
