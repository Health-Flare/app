import 'package:flutter/material.dart';

import 'package:health_flare/features/shared/widgets/step_progress_dots.dart';

/// Consistent chrome for one page of a guided, multi-step flow: an optional
/// Back control, the shared [StepProgressDots] indicator, and an optional
/// Skip control.
///
/// Used by both the onboarding flow and the post-setup weather/first-log
/// mini-flow so a one-time guided experience never feels like a different
/// screen bolted onto the side of the app. Any future guided flow should
/// reuse this widget rather than building its own header.
class GuidedStepHeader extends StatelessWidget {
  const GuidedStepHeader({
    super.key,
    required this.total,
    required this.currentIndex,
    required this.stepTitle,
    this.onBack,
    this.onSkip,
  });

  final int total;
  final int currentIndex;

  /// Announced to screen readers alongside the step position. The dots
  /// themselves carry no visible text, so this is the only place the step's
  /// name is exposed to assistive technology.
  final String stepTitle;

  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: onBack == null
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      iconSize: 18,
                      color: cs.onSurfaceVariant,
                      tooltip: 'Back',
                      onPressed: onBack,
                    ),
            ),
            Expanded(
              child: Center(
                child: Semantics(
                  label: 'Step ${currentIndex + 1} of $total, $stepTitle',
                  child: ExcludeSemantics(
                    child: StepProgressDots(
                      total: total,
                      currentIndex: currentIndex,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: onSkip == null
                  ? null
                  : Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: onSkip,
                        child: const Text('Skip'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
