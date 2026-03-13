import 'package:flutter/material.dart';

import 'package:health_flare/core/theme/app_colors.dart';

/// Modal sheet presented once per profile after onboarding completes.
///
/// Explains why weather tracking is valuable for chronic illness
/// management and lets the user opt in or decline. All data remains
/// on device; the only network call is a weather fetch when the user
/// opens the quick-log sheet.
///
/// [onResult] is called with `true` if the user taps "Enable weather
/// tracking" and `false` if they tap "Not now". The caller is
/// responsible for persisting the preference and popping the sheet.
class WeatherTrackingOptInSheet extends StatelessWidget {
  const WeatherTrackingOptInSheet({super.key, required this.onResult});

  final void Function(bool enabled) onResult;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 28),
                decoration: BoxDecoration(
                  color: cs.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Icon
            Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.paleSky,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.cloud_outlined,
                size: 28,
                color: cs.primary,
              ),
            ),

            // Title
            Text(
              'Track weather with every log',
              style: tt.headlineSmall?.copyWith(color: cs.onSurface),
            ),

            const SizedBox(height: 12),

            // Explanation
            Text(
              'Changes in temperature, humidity, and barometric pressure '
              'can influence how people feel with chronic conditions — '
              'yet most people never think to track it. Enabling this '
              'silently captures weather conditions at the moment of each '
              'entry, so patterns become visible over time.',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.55,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Weather data is stored only on this device and never shared.',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 32),

            // Primary action
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => onResult(true),
                child: const Text('Enable weather tracking'),
              ),
            ),

            const SizedBox(height: 12),

            // Secondary action — equal visual weight, no deferral framing
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => onResult(false),
                child: const Text('No thanks'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows [WeatherTrackingOptInSheet] as a non-dismissible modal bottom sheet
/// and persists the result via [onResult].
///
/// Returns after the user taps either button.
Future<void> showWeatherOptIn(
  BuildContext context, {
  required void Function(bool enabled) onResult,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (_) => WeatherTrackingOptInSheet(onResult: onResult),
  );
}
