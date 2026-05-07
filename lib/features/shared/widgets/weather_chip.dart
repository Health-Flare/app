import 'package:flutter/material.dart';

import 'package:health_flare/models/weather_snapshot.dart';

/// Displays a weather condition icon and summary string (e.g. "Mainly clear, 18°C").
///
/// Returns an empty widget when [snapshot] is null so callers don't need
/// a null guard.
class WeatherChip extends StatelessWidget {
  const WeatherChip({super.key, required this.snapshot});

  final WeatherSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(snapshot!.icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          snapshot!.displayString,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
