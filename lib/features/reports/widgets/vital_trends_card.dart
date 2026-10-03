import 'package:flutter/material.dart';

import 'package:health_flare/features/reports/models/insight_data.dart';
import 'package:health_flare/features/reports/widgets/trend_chart.dart';
import 'package:health_flare/models/vital_type.dart';

/// Vital trends on the insights screen: a picker over the vital types that
/// have readings, and a chart fitted to the selected type's values.
///
/// Renders nothing when [InsightData.vitalTrends] is empty.
class VitalTrendsCard extends StatefulWidget {
  const VitalTrendsCard({super.key, required this.data});

  final InsightData data;

  @override
  State<VitalTrendsCard> createState() => _VitalTrendsCardState();
}

class _VitalTrendsCardState extends State<VitalTrendsCard> {
  VitalType? _selected;

  @override
  Widget build(BuildContext context) {
    final trends = widget.data.vitalTrends;
    if (trends.isEmpty) return const SizedBox.shrink();

    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final trend = trends.firstWhere(
      (t) => t.type == _selected,
      orElse: () => trends.first,
    );
    final isBp = trend.secondaryPoints.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (trends.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DropdownButton<VitalType>(
              value: trend.type,
              isExpanded: true,
              isDense: true,
              underline: const SizedBox.shrink(),
              items: [
                for (final t in trends)
                  DropdownMenuItem(value: t.type, child: Text(t.type.label)),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _selected = v);
              },
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(trend.type.label, style: tt.titleSmall),
          ),
        if (isBp || widget.data.flarePeriods.isNotEmpty) ...[
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              if (isBp) ...[
                _SeriesLegend(color: cs.primary, label: 'Systolic'),
                _SeriesLegend(color: cs.tertiary, label: 'Diastolic'),
              ],
              if (widget.data.flarePeriods.isNotEmpty) const FlareLegendChip(),
            ],
          ),
          const SizedBox(height: 6),
        ],
        SizedBox(
          height: 180,
          child: TrendChart(
            points: trend.points,
            secondaryPoints: trend.secondaryPoints,
            windowStart: widget.data.start,
            windowEnd: widget.data.end,
            flarePeriods: widget.data.flarePeriods,
            fitToData: true,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${trend.type.label} in ${trend.unit}. '
          '${trend.points.length} '
          '${trend.points.length == 1 ? 'reading' : 'readings'}.',
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SeriesLegend extends StatelessWidget {
  const _SeriesLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 3, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
