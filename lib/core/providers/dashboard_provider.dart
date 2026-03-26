import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/models/activity_item.dart';

// ---------------------------------------------------------------------------
// Dashboard activity feed
// ---------------------------------------------------------------------------

/// The five most-recent health events for the active profile,
/// sorted newest-first.
///
/// Merges journal entries (keyed by [JournalEntry.createdAt]) and sleep
/// sessions (keyed by [SleepEntry.wakeTime]), then sorts descending and
/// returns only the first five results.
final dashboardActivityProvider = Provider<List<ActivityItem>>((ref) {
  final journalEntries = ref.watch(activeProfileJournalProvider);
  final sleepEntries = ref.watch(activeSleepEntriesProvider);

  final items = <ActivityItem>[
    ...journalEntries.map(
      (e) => JournalActivityItem(timestamp: e.createdAt, entry: e),
    ),
    ...sleepEntries.map(
      (e) => SleepActivityItem(timestamp: e.wakeTime, entry: e),
    ),
  ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return items.take(5).toList();
});

/// True when [dashboardActivityProvider] contains at least one item.
final dashboardHasActivityProvider = Provider<bool>((ref) {
  return ref.watch(dashboardActivityProvider).isNotEmpty;
});
