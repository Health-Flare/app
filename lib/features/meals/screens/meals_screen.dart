import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// Main screen showing the meal log for the active profile.
class MealsScreen extends ConsumerWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileDataProvider);
    final entries = ref.watch(activeProfileMealEntriesProvider);

    return Scaffold(
      appBar: HFAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Meals'),
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
              itemBuilder: (context, i) => _MealTile(entry: entries[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.mealsNew),
        tooltip: 'Log meal',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Meal tile
// ---------------------------------------------------------------------------

class _MealTile extends StatelessWidget {
  const _MealTile({required this.entry});

  final MealEntry entry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM yyyy, HH:mm');

    return ListTile(
      key: Key('meal_tile_${entry.id}'),
      leading: entry.photoPath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(entry.photoPath!),
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => CircleAvatar(
                  backgroundColor: cs.secondaryContainer,
                  child: Icon(
                    Icons.restaurant,
                    color: cs.onSecondaryContainer,
                    size: 20,
                  ),
                ),
              ),
            )
          : CircleAvatar(
              backgroundColor: cs.secondaryContainer,
              child: Icon(
                Icons.restaurant,
                color: cs.onSecondaryContainer,
                size: 20,
              ),
            ),
      title: Text(
        entry.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(fmt.format(entry.loggedAt)),
      trailing: entry.hasReaction
          ? Tooltip(
              message: 'Reaction flagged',
              child: Icon(
                Icons.warning_amber_rounded,
                color: cs.error,
                semanticLabel: 'reaction indicator',
              ),
            )
          : null,
      onTap: () => context.push(AppRoutes.mealsDetail(entry.id), extra: entry),
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
              Icons.restaurant_outlined,
              size: 56,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No meals logged yet',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to log your first meal',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
