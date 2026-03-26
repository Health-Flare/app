import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/models/sleep_entry.dart';

/// A single item in the dashboard activity feed.
///
/// Sealed so that exhaustive pattern-matching in widget switch expressions
/// covers all variants without a default branch.
sealed class ActivityItem {
  const ActivityItem({required this.timestamp});

  /// The point in time used for sorting (newest first).
  final DateTime timestamp;
}

/// A journal entry in the activity feed.
final class JournalActivityItem extends ActivityItem {
  const JournalActivityItem({required super.timestamp, required this.entry});

  final JournalEntry entry;
}

/// A sleep session in the activity feed.
final class SleepActivityItem extends ActivityItem {
  const SleepActivityItem({required super.timestamp, required this.entry});

  final SleepEntry entry;
}
