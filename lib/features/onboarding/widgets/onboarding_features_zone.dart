import 'package:flutter/material.dart';

/// Step 2 — "What you can track".
///
/// Shows the app's main capabilities as icon-led chips. Each icon is a real
/// [Icon] widget, not an emoji character rendered as text — emoji glyphs can
/// come out blank on iOS when the app's text theme doesn't declare an emoji
/// font fallback, which is exactly what made the equivalent cards on the
/// old first-log prompt look broken. Using [Icon] avoids that class of bug
/// entirely, on any platform.
class OnboardingFeaturesZone extends StatelessWidget {
  const OnboardingFeaturesZone({super.key, required this.onNext});

  final VoidCallback onNext;

  static const _highlights = [
    (icon: Icons.healing_outlined, label: 'Symptoms'),
    (icon: Icons.monitor_heart_outlined, label: 'Vitals'),
    (icon: Icons.medication_outlined, label: 'Medications'),
    (icon: Icons.restaurant_outlined, label: 'Meals'),
    (icon: Icons.book_outlined, label: 'Journal'),
    (icon: Icons.local_hospital_outlined, label: 'Conditions'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT YOU CAN TRACK',
            style: tt.labelSmall?.copyWith(
              color: cs.primary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Log whatever matters, whenever it happens.',
            style: tt.headlineSmall?.copyWith(color: cs.onSurface),
          ),

          const SizedBox(height: 8),

          Text(
            'One quick note, a full entry with details, or anything in '
            'between — Health Flare bends to how much time and energy you '
            'have that day.',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _highlights
                .map(
                  (h) => Chip(
                    avatar: Icon(h.icon, size: 18, color: cs.primary),
                    label: Text(
                      h.label,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    backgroundColor: cs.surfaceContainerHighest,
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 36),

          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: onNext, child: const Text('Next')),
          ),
        ],
      ),
    );
  }
}
