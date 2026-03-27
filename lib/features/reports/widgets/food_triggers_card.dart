import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/features/reports/models/insight_data.dart';

/// Card listing reaction-flagged meals alongside symptoms logged within 6 h.
class FoodTriggersCard extends StatelessWidget {
  const FoodTriggersCard({super.key, required this.triggers});

  final List<FoodTrigger> triggers;

  @override
  Widget build(BuildContext context) {
    if (triggers.isEmpty) {
      return const _EmptyState(
        message:
            'No reaction-flagged meals in this period. '
            'Flag a meal with a reaction when logging food to build this view.',
      );
    }

    return Column(
      children: triggers.map((t) => _TriggerTile(trigger: t)).toList(),
    );
  }
}

class _TriggerTile extends StatelessWidget {
  const _TriggerTile({required this.trigger});

  final FoodTrigger trigger;

  static final _fmt = DateFormat('d MMM, HH:mm');

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_rounded, size: 16, color: cs.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    trigger.meal.description,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Text(
              _fmt.format(trigger.meal.loggedAt),
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            if (trigger.symptoms.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Symptoms within 6 h:',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: trigger.symptoms
                    .map(
                      (s) => Chip(
                        label: Text(
                          '${s.name} (${s.severity}/10)',
                          style: tt.labelSmall,
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        backgroundColor: cs.errorContainer,
                        labelStyle: TextStyle(color: cs.onErrorContainer),
                      ),
                    )
                    .toList(),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'No symptoms logged within 6 h after this meal.',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }
}
