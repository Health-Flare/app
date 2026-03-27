import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/features/reports/models/insight_data.dart';

/// Line chart for a single trend (symptom severity or wellbeing score).
///
/// [maxY] defaults to 10 (severity scale). Pass 10 for symptom severity and
/// wellbeing; the chart scales accordingly.
///
/// [flarePeriods] adds translucent orange bands behind the chart line.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.points,
    required this.windowStart,
    required this.windowEnd,
    this.flarePeriods = const [],
    this.maxY = 10.0,
    this.lineColor,
  });

  final List<TrendPoint> points;
  final DateTime windowStart;
  final DateTime windowEnd;
  final List<InsightFlarePeriod> flarePeriods;
  final double maxY;
  final Color? lineColor;

  static final _axisDateFmt = DateFormat('d MMM');

  double _dayOffset(DateTime dt) {
    return dt.difference(windowStart).inHours / 24.0;
  }

  double get _totalDays =>
      windowEnd.difference(windowStart).inDays.toDouble().clamp(1, 366);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = lineColor ?? cs.primary;

    final spots = points
        .map((p) => FlSpot(_dayOffset(p.date), p.value))
        .toList();

    final flareAnnotations = flarePeriods
        .map(
          (f) => VerticalRangeAnnotation(
            x1: _dayOffset(f.start),
            x2: _dayOffset(f.end),
            color: cs.error.withValues(alpha: 0.12),
          ),
        )
        .toList();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: _totalDays,
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY == 10 ? 2 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: cs.outlineVariant.withValues(alpha: 0.4),
            strokeWidth: 0.8,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: maxY == 10 ? 2 : 1,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
              ),
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: _totalDays > 14 ? (_totalDays / 4).roundToDouble() : 7,
              getTitlesWidget: (value, meta) {
                final dt = windowStart.add(
                  Duration(hours: (value * 24).round()),
                );
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    _axisDateFmt.format(dt),
                    style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
        ),
        rangeAnnotations: RangeAnnotations(
          verticalRangeAnnotations: flareAnnotations,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2.5,
            dotData: FlDotData(
              show: points.length <= 14,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 3,
                color: color,
                strokeWidth: 0,
                strokeColor: Colors.transparent,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.08),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) {
              final dt = windowStart.add(Duration(hours: (s.x * 24).round()));
              return LineTooltipItem(
                '${_axisDateFmt.format(dt)}\n${s.y.toStringAsFixed(1)}',
                TextStyle(color: cs.onInverseSurface, fontSize: 11),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// A legend chip showing a coloured dot + label.
///
/// Used to explain flare band shading on charts.
class FlareLegendChip extends StatelessWidget {
  const FlareLegendChip({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: cs.error.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Flare period',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
