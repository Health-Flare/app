import 'package:flutter/material.dart';

/// One step of the post-setup guided mini-flow (see `PostSetupFlowScreen`),
/// shown once per profile after onboarding completes.
///
/// Explains why weather tracking is valuable for chronic illness
/// management and lets the user opt in or decline. All data remains
/// on device; the only network call is a weather fetch when the user
/// opens the quick-log sheet.
///
/// [onResult] is called with `true` if the user taps "Enable weather
/// tracking" and `false` if they tap "Not now". The caller is
/// responsible for persisting the preference and advancing the flow.
class WeatherTrackingOptInSheet extends StatelessWidget {
  const WeatherTrackingOptInSheet({super.key, required this.onResult});

  final void Function(bool enabled) onResult;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 52,
            height: 52,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              // Theme-adaptive tertiaryContainer, not AppColors.paleSky:
              // that constant is pinned light and looked like a stray
              // light-mode chip against an otherwise dark sheet.
              color: cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.cloud_outlined, size: 28, color: cs.primary),
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
            'can influence how people feel with chronic conditions, '
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

          // Secondary action: equal visual weight, no deferral framing
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => onResult(false),
              child: const Text('No thanks'),
            ),
          ),
        ],
      ),
    );
  }
}
