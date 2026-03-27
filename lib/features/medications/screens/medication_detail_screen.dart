import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/dose_log_provider.dart';
import 'package:health_flare/core/providers/medication_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/dose_log.dart';
import 'package:health_flare/models/medication.dart';

/// Detail screen for a medication — shows metadata, effectiveness summary,
/// and full dose history.
class MedicationDetailScreen extends ConsumerWidget {
  const MedicationDetailScreen({super.key, required this.medicationId});

  final int medicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final med = ref
        .watch(medicationListProvider)
        .cast<Medication?>()
        .firstWhere((m) => m?.id == medicationId, orElse: () => null);

    if (med == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Medication not found')),
      );
    }

    final logs = ref.watch(medicationDoseLogsProvider(medicationId));

    return Scaffold(
      appBar: AppBar(
        title: Text(med.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit medication',
            onPressed: () =>
                context.push(AppRoutes.medicationsEdit(med.id), extra: med),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _MedicationHeader(med: med, logs: logs),
          ),
          if (logs.isEmpty)
            const SliverToBoxAdapter(child: _DoseEmptyState())
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  'Dose history',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _DoseLogTile(log: logs[i], med: med),
                childCount: logs.length,
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Log a dose'),
            onPressed: () =>
                context.push(AppRoutes.medicationsDoseNew(med.id), extra: med),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Medication header card
// ---------------------------------------------------------------------------

class _MedicationHeader extends StatelessWidget {
  const _MedicationHeader({required this.med, required this.logs});

  final Medication med;
  final List<DoseLog> logs;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dateFmt = DateFormat('d MMM yyyy');

    // Effectiveness summary
    final ratedLogs = logs.where((l) => l.effectiveness != null).toList();
    final helpedCount = ratedLogs
        .where(
          (l) =>
              l.effectiveness == 'helped_a_lot' ||
              l.effectiveness == 'helped_a_little',
        )
        .length;
    final effectivenessSummary = ratedLogs.isNotEmpty
        ? 'Helped in $helpedCount of ${ratedLogs.length} rated doses'
        : null;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(med.name, style: tt.titleLarge)),
                if (!med.isActive)
                  Chip(
                    label: const Text('Discontinued'),
                    backgroundColor: cs.errorContainer,
                    labelStyle: TextStyle(color: cs.onErrorContainer),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.scale_outlined, label: med.doseDisplay),
            _InfoRow(icon: Icons.repeat_outlined, label: med.frequencyDisplay),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Started ${dateFmt.format(med.startDate)}',
            ),
            if (med.endDate != null)
              _InfoRow(
                icon: Icons.event_busy_outlined,
                label: 'Ended ${dateFmt.format(med.endDate!)}',
              ),
            if (med.notes != null && med.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                med.notes!,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
            if (effectivenessSummary != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.insights_outlined, size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      effectivenessSummary,
                      style: tt.labelMedium?.copyWith(color: cs.primary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dose log tile
// ---------------------------------------------------------------------------

class _DoseLogTile extends StatelessWidget {
  const _DoseLogTile({required this.log, required this.med});

  final DoseLog log;
  final Medication med;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('d MMM yyyy, HH:mm');

    Color statusColor;
    switch (log.status) {
      case 'taken':
        statusColor = cs.primary;
      case 'skipped':
        statusColor = cs.tertiary;
      case 'missed':
        statusColor = cs.error;
      default:
        statusColor = cs.onSurface;
    }

    return ListTile(
      key: Key('dose_tile_${log.id}'),
      leading: CircleAvatar(
        backgroundColor: statusColor.withAlpha(30),
        child: Icon(
          log.status == 'taken'
              ? Icons.check_circle_outline
              : Icons.cancel_outlined,
          size: 20,
          color: statusColor,
        ),
      ),
      title: Row(
        children: [
          Text(log.amountDisplay),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(30),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              log.statusDisplay,
              style: tt.labelSmall?.copyWith(color: statusColor),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fmt.format(log.loggedAt)),
          if (log.effectiveness != null)
            Text(
              log.effectivenessDisplay,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          if (log.reason != null)
            Text(
              'Reason: ${log.reason}',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
        ],
      ),
      isThreeLine: log.effectiveness != null || log.reason != null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(
        AppRoutes.medicationsDoseEdit(med.id, log.id),
        extra: {'med': med, 'log': log},
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state for dose history
// ---------------------------------------------------------------------------

class _DoseEmptyState extends StatelessWidget {
  const _DoseEmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_outlined, size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'No doses logged yet',
            style: tt.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "Log a dose" to record the first entry',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
