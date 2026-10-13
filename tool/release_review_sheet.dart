// Release review contact sheet (#171). Stubs.

const reviewVariants = <String>[];

class ReviewShot {
  const ReviewShot(this.variant, this.step, this.name);
  final String variant;
  final int step;
  final String name;
  String get fileName => '';
}

ReviewShot? parseShot(String driverName) => null;

String contactSheet(
  Map<String, List<ReviewShot>> byDevice, {
  required String title,
}) => '';
