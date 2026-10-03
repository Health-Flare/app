import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/features/reports/models/insight_data.dart';

/// Line chart for a trend: symptom severity, wellbeing, or a vital.
///
/// [maxY] defaults to 10 (severity scale). Set [fitToData] for vitals so the
/// y-axis fits the readings instead.
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
    this.secondaryPoints = const [],
    this.fitToData = false,
  });

  final List<TrendPoint> points;
  final DateTime windowStart;
  final DateTime windowEnd;
  final List<InsightFlarePeriod> flarePeriods;
  final double maxY;
  final Color? lineColor;

  /// Optional second series (diastolic blood pressure), drawn as its own line.
  final List<TrendPoint> secondaryPoints;

  /// When true, the y-axis is fitted to the readings instead of 0..[maxY].
  /// Used for vitals, whose values are not on the 1–10 severity scale.
  final bool fitToData;

  static final _axisDateFmt = DateFormat('d MMM');
  static final _tooltipDateTimeFmt = DateFormat('d MMM, HH:mm');

  double _dayOffset(DateTime dt) {
    return dt.difference(windowStart).inHours / 24.0;
  }

  double get _totalDays =>
      windowEnd.difference(windowStart).inDays.toDouble().clamp(1, 366);

  /// Y-axis bounds and grid interval.
  ///
  /// Severity charts keep 0..[maxY]. Fitted charts pad the data range by 10%
  /// (min 0.5 units) and snap to a round interval so labels stay readable.
  ({double minY, double maxY, double interval}) _yAxis() {
    if (!fitToData) {
      return (minY: 0, maxY: maxY, interval: maxY == 10 ? 2 : 1);
    }
    final values = [
      ...points.map((p) => p.value),
      ...secondaryPoints.map((p) => p.value),
    ];
    if (values.isEmpty) return (minY: 0, maxY: maxY, interval: 2);
    var lo = values.reduce(math.min);
    var hi = values.reduce(math.max);
    final pad = math.max((hi - lo) * 0.1, 0.5);
    lo -= pad;
    hi += pad;
    final interval = _niceInterval((hi - lo) / 4);
    return (
      minY: (lo / interval).floorToDouble() * interval,
      maxY: (hi / interval).ceilToDouble() * interval,
      interval: interval,
    );
  }

  static double _niceInterval(double raw) {
    final exp = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final f = raw / exp;
    final nice = f <= 1
        ? 1
        : f <= 2
        ? 2
        : f <= 5
        ? 5
        : 10;
    return nice * exp;
  }

  static String _axisLabel(double value, double interval) =>
      interval < 1 ? value.toStringAsFixed(1) : value.round().toString();

  LineChartBarData _bar(
    List<TrendPoint> series,
    Color color, {
    bool dashed = false,
  }) {
    return LineChartBarData(
      spots: series.map((p) => FlSpot(_dayOffset(p.date), p.value)).toList(),
      // Curves overshoot between sparse readings, which reads as a value that
      // was never logged. Vitals use straight segments.
      isCurved: !fitToData,
      color: color,
      barWidth: 2.5,
      dashArray: dashed ? [6, 4] : null,
      dotData: FlDotData(
        show: fitToData || series.length <= 14,
        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
          radius: 3,
          color: color,
          strokeWidth: 0,
          strokeColor: Colors.transparent,
        ),
      ),
      belowBarData: BarAreaData(
        show: !fitToData,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = lineColor ?? cs.primary;
    final y = _yAxis();

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
        minY: y.minY,
        maxY: y.maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: y.interval,
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
              reservedSize: fitToData ? 36 : 28,
              interval: y.interval,
              getTitlesWidget: (value, meta) => Text(
                _axisLabel(value, y.interval),
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
          _bar(points, color),
          if (secondaryPoints.isNotEmpty)
            _bar(secondaryPoints, cs.tertiary, dashed: true),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) {
              final dt = windowStart.add(Duration(hours: (s.x * 24).round()));
              final fmt = fitToData ? _tooltipDateTimeFmt : _axisDateFmt;
              return LineTooltipItem(
                '${fmt.format(dt)}\n${s.y.toStringAsFixed(1)}',
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
