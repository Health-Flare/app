import 'package:flutter/material.dart';

/// Minimal step-progress indicator: a row of small dots, one per step, with
/// no numbers or labels.
///
/// This is the one progress indicator used by every guided, multi-step flow
/// in the app (onboarding, and the post-setup weather/first-log mini-flow)
/// so a stepped experience always looks the same rather than each flow
/// inventing its own. See [GuidedStepHeader] for the full header this is
/// normally used inside of.
class StepProgressDots extends StatelessWidget {
  const StepProgressDots({
    super.key,
    required this.total,
    required this.currentIndex,
  });

  final int total;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isCurrent = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isCurrent ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isCurrent ? cs.primary : cs.outlineVariant,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
