import 'package:flutter/material.dart';

import 'package:health_flare/models/weather_snapshot.dart';

/// Displays a weather condition icon and summary string (e.g. "Mainly clear, 18°C").
///
/// When [showDetails] is true, a second line shows barometric pressure and
/// humidity (e.g. "Pressure 1013 hPa · Humidity 62%"). Use it on views of a
/// single saved entry; keep it off for compact list/card contexts.
///
/// Returns an empty widget when [snapshot] is null so callers don't need
/// a null guard.
class WeatherChip extends StatelessWidget {
  const WeatherChip({
    super.key,
    required this.snapshot,
    this.showDetails = false,
  });

  final WeatherSnapshot? snapshot;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    if (snapshot == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant);
    final summary = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(snapshot!.icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(snapshot!.displayString, style: style),
      ],
    );
    if (!showDetails) return summary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        summary,
        const SizedBox(height: 2),
        // Indent to align with the summary text, past the 16px icon + 6px gap.
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(snapshot!.detailString, style: style),
        ),
      ],
    );
  }
}
