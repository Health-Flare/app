import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/activity_item.dart';

/// Renders the dashboard activity feed — a reverse-chronological list of
/// the active profile's most recent journal entries and sleep sessions.
///
/// The provider ([dashboardActivityProvider]) has already capped the list
/// to five items and sorted them newest-first.
class DashboardActivityFeed extends StatelessWidget {
  const DashboardActivityFeed({super.key, required this.items});

  final List<ActivityItem> items;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'Recent activity',
            style: tt.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
        for (final item in items)
          switch (item) {
            JournalActivityItem(:final entry) => ListTile(
              leading: Icon(Icons.book_outlined, color: cs.primary),
              title: Text(
                entry.displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(_formatDate(item.timestamp)),
              onTap: () => context.go(AppRoutes.journalDetail(entry.id)),
            ),
            SleepActivityItem(:final entry) => ListTile(
              leading: Icon(Icons.bedtime_outlined, color: cs.primary),
              title: Text(entry.formattedDuration),
              subtitle: Text(_formatDate(item.timestamp)),
              onTap: () => context.go(AppRoutes.sleepEdit(entry.id)),
            ),
          },
      ],
    );
  }

  static String _formatDate(DateTime dt) {
    return DateFormat('EEE d MMM, h:mm a').format(dt);
  }
}
