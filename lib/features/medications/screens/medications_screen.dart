import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/dose_log_provider.dart';
import 'package:health_flare/core/providers/medication_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/medication.dart';

/// Main medications screen — lists active medications and supplements,
/// with a collapsed section for discontinued entries.
class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileDataProvider);
    final activeMeds = ref.watch(activeProfileActiveMedicationsProvider);
    final discontinuedMeds = ref.watch(
      activeProfileDiscontinuedMedicationsProvider,
    );
    final activeSupps = ref.watch(activeProfileActiveSupplementsProvider);
    final discontinuedSupps = ref.watch(
      activeProfileDiscontinuedSupplementsProvider,
    );

    final hasAny =
        activeMeds.isNotEmpty ||
        discontinuedMeds.isNotEmpty ||
        activeSupps.isNotEmpty ||
        discontinuedSupps.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Medications'),
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
      body: hasAny
          ? _MedicationList(
              activeMeds: activeMeds,
              discontinuedMeds: discontinuedMeds,
              activeSupps: activeSupps,
              discontinuedSupps: discontinuedSupps,
            )
          : const _EmptyState(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_medications',
        onPressed: () => context.push(AppRoutes.medicationsNew),
        tooltip: 'Add medication',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List body
// ---------------------------------------------------------------------------

class _MedicationList extends ConsumerWidget {
  const _MedicationList({
    required this.activeMeds,
    required this.discontinuedMeds,
    required this.activeSupps,
    required this.discontinuedSupps,
  });

  final List<Medication> activeMeds;
  final List<Medication> discontinuedMeds;
  final List<Medication> activeSupps;
  final List<Medication> discontinuedSupps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        // ── Active medications ─────────────────────────────────────────────
        if (activeMeds.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Medications',
                style: tt.titleSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _MedicationTile(med: activeMeds[i]),
              childCount: activeMeds.length,
            ),
          ),
        ],

        // ── Active supplements ─────────────────────────────────────────────
        if (activeSupps.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Supplements',
                style: tt.titleSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _MedicationTile(med: activeSupps[i]),
              childCount: activeSupps.length,
            ),
          ),
        ],

        // ── Discontinued ───────────────────────────────────────────────────
        if (discontinuedMeds.isNotEmpty || discontinuedSupps.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _DiscontinuedSection(
              meds: [...discontinuedMeds, ...discontinuedSupps],
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 88)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Medication tile
// ---------------------------------------------------------------------------

class _MedicationTile extends ConsumerWidget {
  const _MedicationTile({required this.med});

  final Medication med;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final doseLogs = ref.watch(medicationDoseLogsProvider(med.id));

    String? lastDoseLabel;
    if (doseLogs.isNotEmpty) {
      final latest = doseLogs.first.loggedAt;
      final diff = DateTime.now().difference(latest);
      if (diff.inDays == 0) {
        lastDoseLabel = 'Last dose today';
      } else if (diff.inDays == 1) {
        lastDoseLabel = 'Last dose yesterday';
      } else {
        lastDoseLabel = 'Last dose ${diff.inDays}d ago';
      }
    }

    return ListTile(
      key: Key('med_tile_${med.id}'),
      leading: CircleAvatar(
        backgroundColor: med.isSupplement
            ? cs.tertiaryContainer
            : cs.primaryContainer,
        child: Icon(
          med.isSupplement
              ? Icons.health_and_safety_outlined
              : Icons.medication_outlined,
          size: 20,
          color: med.isSupplement
              ? cs.onTertiaryContainer
              : cs.onPrimaryContainer,
        ),
      ),
      title: Text(med.name),
      subtitle: Text(
        '${med.doseDisplay} · ${med.frequencyDisplay}'
        '${lastDoseLabel != null ? '\n$lastDoseLabel' : ''}',
      ),
      isThreeLine: lastDoseLabel != null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          context.push(AppRoutes.medicationsDetail(med.id), extra: med),
    );
  }
}

// ---------------------------------------------------------------------------
// Discontinued collapsible section
// ---------------------------------------------------------------------------

class _DiscontinuedSection extends StatefulWidget {
  const _DiscontinuedSection({required this.meds});

  final List<Medication> meds;

  @override
  State<_DiscontinuedSection> createState() => _DiscontinuedSectionState();
}

class _DiscontinuedSectionState extends State<_DiscontinuedSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Text(
                  'Discontinued (${widget.meds.length})',
                  style: tt.titleSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...widget.meds.map((m) => _MedicationTile(med: m)),
      ],
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
              Icons.medication_outlined,
              size: 56,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No medications yet',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a medication or supplement',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
