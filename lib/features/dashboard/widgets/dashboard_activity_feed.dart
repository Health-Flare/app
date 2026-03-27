import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/activity_item.dart';

/// Renders the dashboard activity feed — a reverse-chronological list of
/// the active profile's most recent health events across all logged types.
///
/// The provider ([dashboardActivityProvider]) has already capped the list
/// to ten items and sorted them newest-first.
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
        for (final item in items) _buildTile(context, item, cs),
      ],
    );
  }

  Widget _buildTile(BuildContext context, ActivityItem item, ColorScheme cs) {
    return switch (item) {
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
      SymptomActivityItem(:final entry) => ListTile(
        leading: Icon(Icons.healing_outlined, color: cs.primary),
        title: Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${_formatDate(item.timestamp)} · severity ${entry.severity}/10',
        ),
        onTap: () =>
            context.push(AppRoutes.symptomsEdit(entry.id), extra: entry),
      ),
      VitalActivityItem(:final entry) => ListTile(
        leading: Icon(Icons.monitor_heart_outlined, color: cs.primary),
        title: Text(entry.vitalType.label),
        subtitle: Text(
          '${_formatDate(item.timestamp)} · ${entry.displayValue}',
        ),
        onTap: () => context.push(AppRoutes.vitalsEdit(entry.id), extra: entry),
      ),
      DoseLogActivityItem(:final doseLog, :final medication) => ListTile(
        leading: Icon(Icons.medication_outlined, color: cs.primary),
        title: Text(
          medication?.name ?? 'Medication',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${_formatDate(item.timestamp)} · '
          '${doseLog.amount} ${doseLog.unit}',
        ),
      ),
      MealActivityItem(:final entry) => ListTile(
        leading: Icon(Icons.restaurant_outlined, color: cs.primary),
        title: Text(
          entry.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(_formatDate(item.timestamp)),
        trailing: entry.hasReaction
            ? Icon(
                Icons.warning_amber_rounded,
                color: cs.error,
                size: 18,
                semanticLabel: 'reaction indicator',
              )
            : null,
        onTap: () => context.push(AppRoutes.mealsDetail(entry.id)),
      ),
      FlareActivityItem(:final entry) => ListTile(
        leading: Icon(Icons.local_fire_department_outlined, color: cs.error),
        title: Text(
          entry.endedAt == null ? 'Active flare' : 'Flare',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(_formatDate(item.timestamp)),
        onTap: () => context.push(AppRoutes.flareDetail(entry.id)),
      ),
      CheckinActivityItem(:final entry) => ListTile(
        leading: Icon(Icons.check_circle_outline, color: cs.primary),
        title: const Text('Daily check-in'),
        subtitle: Text(
          '${_formatDate(item.timestamp)} · wellbeing ${entry.wellbeing}/10',
        ),
      ),
      AppointmentActivityItem(:final entry) => ListTile(
        leading: Icon(Icons.calendar_today_outlined, color: cs.primary),
        title: Text(entry.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(_formatDate(item.timestamp)),
        onTap: () => context.push(AppRoutes.appointmentDetail(entry.id)),
      ),
      ActivityLogActivityItem(:final entry) => ListTile(
        leading: Icon(Icons.directions_walk_outlined, color: cs.primary),
        title: Text(
          entry.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          entry.activityType != null
              ? '${_formatDate(item.timestamp)} · ${entry.activityType!.label}'
              : _formatDate(item.timestamp),
        ),
        onTap: () =>
            context.push(AppRoutes.activityEdit(entry.id), extra: entry),
      ),
    };
  }

  static String _formatDate(DateTime dt) =>
      DateFormat('EEE d MMM, h:mm a').format(dt);
}
