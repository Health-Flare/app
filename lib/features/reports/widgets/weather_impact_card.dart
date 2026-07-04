import 'package:flutter/material.dart';

import 'package:health_flare/features/reports/models/insight_data.dart';

/// Shows average symptom severity grouped by weather condition.
class WeatherImpactCard extends StatelessWidget {
  const WeatherImpactCard({super.key, required this.conditions});

  final List<WeatherConditionSeverity> conditions;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (conditions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Not enough symptom logs with weather data in this period. '
          'Weather is captured automatically when logging symptoms if '
          'weather tracking is enabled.',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      );
    }

    final totalSamples = conditions.fold(0, (sum, c) => sum + c.sampleCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...conditions.map((c) => _ConditionRow(condition: c)),
        const SizedBox(height: 8),
        Text(
          'Based on $totalSamples symptom logs with weather data.',
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          'Presented as an observation, not a diagnosis.',
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _ConditionRow extends StatelessWidget {
  const _ConditionRow({required this.condition});

  final WeatherConditionSeverity condition;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              condition.condition,
              style: tt.bodySmall?.copyWith(color: cs.onSurface),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: condition.avgSeverity / 10,
                minHeight: 12,
                color: cs.primary,
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '${condition.avgSeverity.toStringAsFixed(1)}/10',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
