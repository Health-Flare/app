import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/weather_snapshot.dart';

/// Detail view for a single meal entry.
///
/// [mealId] is read from the route path parameter.  The entry itself is
/// passed via [extra] so the UI is available instantly without waiting for
/// the provider to reload.
class MealDetailScreen extends ConsumerWidget {
  const MealDetailScreen({super.key, required this.mealId});

  final int mealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prefer the live entry from the provider (reflects edits), falling back
    // to the route extra if the provider hasn't loaded yet.
    final entry =
        ref.watch(mealEntryListProvider.notifier).byId(mealId) ??
        (ModalRoute.of(context)?.settings.arguments as MealEntry?);

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Meal entry not found')),
      );
    }

    // Symptom entries within ±6 hours of this meal — shown when reaction is flagged.
    final nearbySymptoms = entry.hasReaction
        ? ref.watch(activeProfileSymptomEntriesProvider).where((s) {
            final diff = s.loggedAt.difference(entry.loggedAt).abs();
            return diff.inHours < 6;
          }).toList()
        : <SymptomEntry>[];

    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal detail'),
        actions: [
          IconButton(
            onPressed: () =>
                context.push(AppRoutes.mealsEdit(entry.id), extra: entry),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit entry',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Photo header
          if (entry.photoPath != null)
            SliverToBoxAdapter(
              child: Image.file(
                File(entry.photoPath!),
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    const SizedBox.shrink(),
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    entry.description,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),

                  // Timestamp
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        fmt.format(entry.loggedAt),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  // Reaction flag
                  if (entry.hasReaction) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: cs.onErrorContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Reaction flagged',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: cs.onErrorContainer),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Weather snapshot
                  if (entry.weatherSnapshot != null) ...[
                    const SizedBox(height: 12),
                    _WeatherRow(snapshot: entry.weatherSnapshot!),
                  ],

                  // Notes
                  if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.notes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Nearby symptoms section
          if (nearbySymptoms.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Potential associations',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Symptoms logged within 6 hours of this meal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _SymptomAssociationTile(
                  symptom: nearbySymptoms[i],
                  mealLoggedAt: entry.loggedAt,
                ),
                childCount: nearbySymptoms.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weather row
// ---------------------------------------------------------------------------

class _WeatherRow extends StatelessWidget {
  const _WeatherRow({required this.snapshot});

  final WeatherSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(snapshot.icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          snapshot.displayString,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Nearby symptom tile
// ---------------------------------------------------------------------------

class _SymptomAssociationTile extends StatelessWidget {
  const _SymptomAssociationTile({
    required this.symptom,
    required this.mealLoggedAt,
  });

  final SymptomEntry symptom;
  final DateTime mealLoggedAt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final diff = symptom.loggedAt.difference(mealLoggedAt);
    final diffAbs = diff.abs();
    final label = diffAbs.inMinutes < 60
        ? '${diffAbs.inMinutes}m ${diff.isNegative ? "before" : "after"}'
        : '${diffAbs.inHours}h ${diff.isNegative ? "before" : "after"}';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: cs.tertiaryContainer,
        child: Icon(
          Icons.sentiment_neutral_outlined,
          size: 20,
          color: cs.onTertiaryContainer,
        ),
      ),
      title: Text(symptom.name),
      subtitle: Text('$label · severity ${symptom.severity}'),
    );
  }
}
