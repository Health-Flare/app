import 'package:flutter/material.dart';

import 'package:health_flare/features/reports/models/insight_data.dart';

/// Shows the average next-day symptom severity after poor sleep vs good sleep.
class SleepCorrelationCard extends StatelessWidget {
  const SleepCorrelationCard({super.key, required this.correlation});

  final SleepCorrelation correlation;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (!correlation.hasData) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Not enough rated sleep entries in this period. '
          'Rate your sleep quality when logging a sleep entry to build this view.',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      );
    }

    // Plain-language observation.
    final observation = _buildObservation(correlation);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SleepBar(
                label: 'After poor sleep',
                subtitle: 'Quality 1–2',
                value: correlation.poorSleepAvg,
                days: correlation.poorSleepDays,
                color: cs.error,
                maxValue: 10,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SleepBar(
                label: 'After good sleep',
                subtitle: 'Quality 4–5',
                value: correlation.goodSleepAvg,
                days: correlation.goodSleepDays,
                color: cs.primary,
                maxValue: 10,
              ),
            ),
          ],
        ),
        if (observation != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              observation,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
        const SizedBox(height: 4),
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

  String? _buildObservation(SleepCorrelation c) {
    final poor = c.poorSleepAvg;
    final good = c.goodSleepAvg;
    if (poor == null || good == null) return null;

    final diff = (poor - good).abs();
    if (diff < 0.5) {
      return 'Sleep quality does not appear to strongly predict next-day '
          'symptom severity in this period.';
    }
    if (poor > good) {
      return 'After poor sleep nights, next-day symptom severity averaged '
          '${poor.toStringAsFixed(1)}/10 — '
          '${diff.toStringAsFixed(1)} points higher than after good sleep '
          '(${good.toStringAsFixed(1)}/10).';
    }
    return 'Interestingly, next-day symptoms were similar after poor and good sleep '
        'in this period.';
  }
}

class _SleepBar extends StatelessWidget {
  const _SleepBar({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.days,
    required this.color,
    required this.maxValue,
  });

  final String label;
  final String subtitle;
  final double? value;
  final int? days;
  final Color color;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.labelMedium),
        Text(
          subtitle,
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        if (value != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value! / maxValue,
              minHeight: 16,
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 4),
          Text('${value!.toStringAsFixed(1)}/10 avg', style: tt.bodySmall),
          if (days != null)
            Text(
              '$days night${days == 1 ? '' : 's'}',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
        ] else
          Text(
            'No data',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
      ],
    );
  }
}
