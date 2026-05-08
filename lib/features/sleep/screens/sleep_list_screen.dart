import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/sleep/widgets/sleep_entry_card.dart';
import 'package:health_flare/models/sleep_entry.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// Reverse-chronological list of sleep entries for the active profile.
///
/// Header shows 7-day average duration and average quality.
class SleepListScreen extends ConsumerWidget {
  const SleepListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(activeSleepEntriesProvider);

    return Scaffold(
      appBar: const HFAppBar(title: Text('Sleep')),
      body: entries.isEmpty
          ? const _EmptyState()
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _SummaryHeader(entries: entries)),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => SleepEntryCard(
                      entry: entries[i],
                      onTap: () => context.push(
                        AppRoutes.sleepEdit(entries[i].id),
                        extra: entries[i],
                      ),
                    ),
                    childCount: entries.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7-day summary header
// ---------------------------------------------------------------------------

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.entries});

  final List<SleepEntry> entries;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final recent = entries.where((e) => e.wakeTime.isAfter(cutoff)).toList();

    if (recent.isEmpty) return const SizedBox.shrink();

    final avgMinutes =
        recent.map((e) => e.duration.inMinutes).reduce((a, b) => a + b) ~/
        recent.length;
    final avgH = avgMinutes ~/ 60;
    final avgM = avgMinutes.remainder(60);
    final avgDuration = avgM == 0 ? '${avgH}h' : '${avgH}h ${avgM}m';

    final rated = recent.where((e) => e.qualityRating != null).toList();
    final avgQuality = rated.isEmpty
        ? null
        : (rated.map((e) => e.qualityRating!).reduce((a, b) => a + b) /
                  rated.length)
              .toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _StatTile(label: '7-day avg', value: avgDuration),
          if (avgQuality != null) ...[
            const SizedBox(width: 24),
            _StatTile(label: 'Avg quality', value: '$avgQuality / 5'),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: tt.titleLarge?.copyWith(
            color: cs.onSecondaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: tt.labelSmall?.copyWith(color: cs.onSecondaryContainer),
        ),
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
            Icon(Icons.bedtime_outlined, size: 56, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No sleep logged yet',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to log last night\'s sleep',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
