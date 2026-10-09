import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current time. Override in tests to pin "now" so rules that depend
/// on it (an appointment being upcoming, needing an outcome) are
/// deterministic.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
