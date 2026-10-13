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
      // A stack, not a row of fixed-width slots: the dots stay centred on
      // the screen and Back and Skip take the room their text needs (at
      // 200% text "Skip" wrapped a letter per line in 48 points, #171).
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        // Full width: positioned children outside a stack's own size
        // are drawn but can't be tapped.
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Semantics(
                label: 'Step ${currentIndex + 1} of $total, $stepTitle',
                child: ExcludeSemantics(
                  child: StepProgressDots(
                    total: total,
                    currentIndex: currentIndex,
                  ),
                ),
              ),
              if (onBack != null)
                Positioned(
                  left: 4,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    iconSize: 18,
                    color: cs.onSurfaceVariant,
                    tooltip: 'Back',
                    onPressed: onBack,
                  ),
                ),
              if (onSkip != null)
                Positioned(
                  right: 12,
                  child: TextButton(
                    onPressed: onSkip,
                    child: const Text('Skip', maxLines: 1, softWrap: false),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
