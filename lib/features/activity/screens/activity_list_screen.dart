import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/activity_entry_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/activity_entry.dart';

/// Main screen showing the activity log for the active profile.
class ActivityListScreen extends ConsumerWidget {
  const ActivityListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileDataProvider);
    final entries = ref.watch(activeProfileActivityEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Activity'),
            if (activeProfile != null)
              Text(
                activeProfile.name,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
      body: entries.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: entries.length,
              itemBuilder: (context, i) => _ActivityTile(entry: entries[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.activityNew),
        tooltip: 'Log activity',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Activity tile
// ---------------------------------------------------------------------------

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.entry});

  final ActivityEntry entry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM yyyy, HH:mm');

    return ListTile(
      key: Key('activity_tile_${entry.id}'),
      leading: CircleAvatar(
        backgroundColor: cs.secondaryContainer,
        child: Icon(
          _iconForType(entry.activityType),
          color: cs.onSecondaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        entry.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(_subtitle(entry, fmt)),
      trailing: entry.effortLevel != null
          ? _EffortBadge(level: entry.effortLevel!)
          : null,
      onTap: () => context.push(AppRoutes.activityEdit(entry.id), extra: entry),
    );
  }

  String _subtitle(ActivityEntry entry, DateFormat fmt) {
    final parts = <String>[fmt.format(entry.loggedAt)];
    if (entry.activityType != null) {
      parts.add(entry.activityType!.label);
    }
    if (entry.durationMinutes != null) {
      parts.add('${entry.durationMinutes} min');
    }
    if (entry.weatherSnapshot != null) {
      parts.add(entry.weatherSnapshot!.displayString);
    }
    return parts.join(' · ');
  }

  IconData _iconForType(ActivityType? type) {
    return switch (type) {
      ActivityType.walking => Icons.directions_walk,
      ActivityType.gentleExercise => Icons.self_improvement,
      ActivityType.household => Icons.home_outlined,
      ActivityType.work => Icons.computer_outlined,
      ActivityType.social => Icons.people_outlined,
      ActivityType.medical => Icons.local_hospital_outlined,
      ActivityType.rest => Icons.hotel_outlined,
      ActivityType.other => Icons.fitness_center_outlined,
      null => Icons.fitness_center_outlined,
    };
  }
}

// ---------------------------------------------------------------------------
// Effort badge
// ---------------------------------------------------------------------------

class _EffortBadge extends StatelessWidget {
  const _EffortBadge({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: effortLabels[level] ?? 'Effort $level',
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$level',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: cs.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_walk_outlined,
              size: 56,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No activities logged yet',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to log your first activity',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
