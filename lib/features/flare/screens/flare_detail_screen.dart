import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/flare.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/vital_entry.dart';

/// Detail view for a single flare period.
///
/// [flareId] is read from the route path. The entry is passed via [extra] for
/// instant availability; the live provider value is preferred on reload.
class FlareDetailScreen extends ConsumerWidget {
  const FlareDetailScreen({super.key, required this.flareId});

  final int flareId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flare =
        ref.watch(flareListProvider.notifier).byId(flareId) ??
        (ModalRoute.of(context)?.settings.arguments as Flare?);

    if (flare == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Flare not found')),
      );
    }

    // Entries tagged to this flare (flareIsarId == flare.id).
    final symptoms =
        ref
            .watch(symptomEntryListProvider)
            .where((e) => e.flareIsarId == flareId)
            .toList()
          ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

    final vitals =
        ref
            .watch(vitalEntryListProvider)
            .where((e) => e.flareIsarId == flareId)
            .toList()
          ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

    final meals =
        ref
            .watch(mealEntryListProvider)
            .where((e) => e.flareIsarId == flareId)
            .toList()
          ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

    final totalEntries = symptoms.length + vitals.length + meals.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(flare.isActive ? 'Active flare' : 'Flare detail'),
        actions: [
          IconButton(
            onPressed: () =>
                context.push(AppRoutes.flareEdit(flare.id), extra: flare),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit flare',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _FlareHeader(flare: flare)),

          // End flare button (only for active flares)
          if (flare.isActive)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _confirmEnd(context, ref, flare),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('End flare'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ),

          // Delete button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextButton.icon(
                onPressed: () => _confirmDelete(context, ref, flare),
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                label: Text(
                  'Delete flare record',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ),

          // Entries section header
          if (totalEntries > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entries during this flare',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _entrySummary(
                        symptoms.length,
                        vitals.length,
                        meals.length,
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Symptoms
          if (symptoms.isNotEmpty) ...[
            _SectionHeader(label: 'Symptoms (${symptoms.length})'),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _SymptomTile(entry: symptoms[i]),
                childCount: symptoms.length,
              ),
            ),
          ],

          // Vitals
          if (vitals.isNotEmpty) ...[
            _SectionHeader(label: 'Vitals (${vitals.length})'),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _VitalTile(entry: vitals[i]),
                childCount: vitals.length,
              ),
            ),
          ],

          // Meals
          if (meals.isNotEmpty) ...[
            _SectionHeader(label: 'Meals (${meals.length})'),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _MealTile(entry: meals[i]),
                childCount: meals.length,
              ),
            ),
          ],

          if (totalEntries == 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Text(
                  'No entries tagged to this flare yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  String _entrySummary(int symptoms, int vitals, int meals) {
    final parts = <String>[];
    if (symptoms > 0) parts.add('$symptoms symptom${symptoms == 1 ? '' : 's'}');
    if (vitals > 0) parts.add('$vitals vital${vitals == 1 ? '' : 's'}');
    if (meals > 0) parts.add('$meals meal${meals == 1 ? '' : 's'}');
    return parts.join(', ');
  }

  Future<void> _confirmEnd(
    BuildContext context,
    WidgetRef ref,
    Flare flare,
  ) async {
    final endTime = await _showEndFlareDialog(context, flare);
    if (endTime == null || !context.mounted) return;

    await ref
        .read(flareListProvider.notifier)
        .update(
          flare.copyWith(
            endedAt: endTime.endedAt,
            peakSeverity: endTime.peakSeverity,
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<_EndFlareResult?> _showEndFlareDialog(
    BuildContext context,
    Flare flare,
  ) async {
    DateTime endedAt = DateTime.now();
    int? peakSeverity;

    return showDialog<_EndFlareResult>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final fmt = DateFormat('d MMM yyyy, HH:mm');
          return AlertDialog(
            title: const Text('End flare'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End time'),
                  subtitle: Text(fmt.format(endedAt)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: endedAt,
                      firstDate: flare.startedAt,
                      lastDate: DateTime.now(),
                    );
                    if (date == null || !ctx.mounted) return;
                    final time = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(endedAt),
                    );
                    if (time == null) return;
                    setDialogState(() {
                      endedAt = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Peak severity (optional)',
                  style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: List.generate(10, (i) {
                    final v = i + 1;
                    return ChoiceChip(
                      label: Text('$v'),
                      selected: peakSeverity == v,
                      onSelected: (_) => setDialogState(
                        () => peakSeverity = peakSeverity == v ? null : v,
                      ),
                    );
                  }),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  ctx,
                  _EndFlareResult(endedAt: endedAt, peakSeverity: peakSeverity),
                ),
                child: const Text('End flare'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Flare flare,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete flare record?'),
        content: const Text(
          'The flare record will be removed. Entries logged during this '
          'period keep their data — only the flare association is cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(flareListProvider.notifier).remove(flare.id);
    if (!context.mounted) return;
    context.go(AppRoutes.flareHistory);
  }
}

// ---------------------------------------------------------------------------
// Internal result type for end-flare dialog
// ---------------------------------------------------------------------------

class _EndFlareResult {
  const _EndFlareResult({required this.endedAt, this.peakSeverity});
  final DateTime endedAt;
  final int? peakSeverity;
}

// ---------------------------------------------------------------------------
// Header card
// ---------------------------------------------------------------------------

class _FlareHeader extends StatelessWidget {
  const _FlareHeader({required this.flare});

  final Flare flare;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('d MMM yyyy, HH:mm');
    final durationDays = flare.duration.inDays + 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status chip
          if (flare.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 16,
                    color: cs.onErrorContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    flare.dayLabel,
                    style: tt.labelMedium?.copyWith(color: cs.onErrorContainer),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Start / end
          _InfoRow(
            icon: Icons.play_circle_outline,
            label: 'Started',
            value: fmt.format(flare.startedAt),
          ),
          if (flare.endedAt != null) ...[
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.stop_circle_outlined,
              label: 'Ended',
              value: fmt.format(flare.endedAt!),
            ),
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.timelapse_rounded,
              label: 'Duration',
              value: '$durationDays day${durationDays == 1 ? '' : 's'}',
            ),
          ],

          // Severities
          if (flare.initialSeverity != null) ...[
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.trending_up_rounded,
              label: 'Initial severity',
              value: '${flare.initialSeverity}/10',
            ),
          ],
          if (flare.peakSeverity != null) ...[
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.bar_chart_rounded,
              label: 'Peak severity',
              value: '${flare.peakSeverity}/10',
            ),
          ],

          // Notes
          if (flare.notes != null && flare.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Notes', style: tt.titleSmall),
            const SizedBox(height: 4),
            Text(flare.notes!, style: tt.bodyMedium),
          ],

          const SizedBox(height: 16),
          const Divider(),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        Expanded(
          child: Text(
            value,
            style: tt.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(label, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Entry tiles
// ---------------------------------------------------------------------------

class _SymptomTile extends StatelessWidget {
  const _SymptomTile({required this.entry});
  final SymptomEntry entry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM, HH:mm');
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: cs.primaryContainer,
        child: Text(
          '${entry.severity}',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: cs.onPrimaryContainer),
        ),
      ),
      title: Text(entry.name),
      subtitle: Text(fmt.format(entry.loggedAt)),
      dense: true,
    );
  }
}

class _VitalTile extends StatelessWidget {
  const _VitalTile({required this.entry});
  final VitalEntry entry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM, HH:mm');
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: cs.secondaryContainer,
        child: Icon(
          Icons.monitor_heart_outlined,
          size: 18,
          color: cs.onSecondaryContainer,
        ),
      ),
      title: Text(entry.vitalType.label),
      subtitle: Text('${entry.displayValue} · ${fmt.format(entry.loggedAt)}'),
      dense: true,
    );
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({required this.entry});
  final MealEntry entry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM, HH:mm');
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: cs.tertiaryContainer,
        child: Icon(Icons.restaurant, size: 18, color: cs.onTertiaryContainer),
      ),
      title: Text(
        entry.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(fmt.format(entry.loggedAt)),
      trailing: entry.hasReaction
          ? Icon(Icons.warning_amber_rounded, size: 16, color: cs.error)
          : null,
      dense: true,
    );
  }
}
