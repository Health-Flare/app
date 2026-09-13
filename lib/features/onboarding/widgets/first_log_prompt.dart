import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/core/router/app_router.dart';

/// Final step of the post-setup guided mini-flow (see `PostSetupFlowScreen`),
/// shown once immediately after the first profile is created.
///
/// Presents six option chips (Illness, Symptom, Vital, Meal, Medication,
/// Journal) and a dismiss link. Tapping a chip navigates to the relevant
/// section; completing or backing out of the illness screen returns here
/// (it's pushed on top rather than replacing this step), while every other
/// option ends the flow once an entry is saved.
///
/// Each chip uses a real [Icon], not an emoji character, which is what
/// made the equivalent cards render with blank glyphs on iOS.
///
/// Copy source: docs/onboarding-copy.md › Post-Setup: First-Log Prompt
class FirstLogPrompt extends ConsumerStatefulWidget {
  const FirstLogPrompt({
    super.key,
    required this.profileName,
    required this.onFinished,
  });

  final String profileName;

  /// Called once this step is complete — the user dismissed it, or
  /// navigated away to save an entry. The mini-flow advances or closes
  /// itself in response.
  final VoidCallback onFinished;

  @override
  ConsumerState<FirstLogPrompt> createState() => _FirstLogPromptState();
}

class _FirstLogPromptState extends ConsumerState<FirstLogPrompt> {
  bool _illnessAdded = false;

  Future<void> _dismiss() async {
    await ref.read(firstLogPromptProvider.notifier).markShown();
    widget.onFinished();
  }

  Future<void> _openIllness() async {
    // Pushed on top of this step (not a replacement), so popping back from
    // the illness screen naturally lands here again, per the "returns to
    // the prompt" behaviour — with or without saving.
    await context.push(AppRoutes.illness);
    if (!mounted) return;
    setState(() => _illnessAdded = true);
  }

  Future<void> _openAndFinish(String route) async {
    await ref.read(firstLogPromptProvider.notifier).markShown();
    if (!mounted) return;
    context.go(route);
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final name = widget.profileName;

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Heading — updates once an illness has been added, to invite
          // the next, more routine kind of entry.
          Text(
            _illnessAdded
                ? 'What would you like to record for $name first?'
                : "$name's profile is ready.",
            style: tt.headlineSmall?.copyWith(color: cs.onSurface),
          ),

          const SizedBox(height: 8),

          Text(
            'The best way to spot patterns is to start logging now, while '
            'the day is fresh. What would you like to record for $name first?',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          // Option cards — 2-column grid (illness spans full width on top)
          Column(
            children: [
              _LogOptionCard(
                icon: Icons.local_hospital_outlined,
                label: 'An illness',
                sublabel: 'Add conditions you want to track',
                semanticsLabel:
                    'Track an illness — add conditions you want to track',
                fullWidth: true,
                onTap: _openIllness,
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                // Tiles hold an icon, a label, and a two-line sublabel;
                // anything above ~1.15 clips on narrow screens or at larger
                // text sizes.
                childAspectRatio: 1.15,
                children: [
                  _LogOptionCard(
                    icon: Icons.healing_outlined,
                    label: 'A symptom',
                    sublabel: 'How is $name feeling right now?',
                    semanticsLabel:
                        'Log a symptom — how is $name feeling right now?',
                    onTap: () => _openAndFinish(AppRoutes.symptoms),
                  ),
                  _LogOptionCard(
                    icon: Icons.monitor_heart_outlined,
                    label: 'A vital',
                    sublabel: 'Blood pressure, heart rate, and more',
                    semanticsLabel:
                        'Log a vital — blood pressure, heart rate, and more',
                    onTap: () => _openAndFinish(AppRoutes.symptoms),
                  ),
                  _LogOptionCard(
                    icon: Icons.restaurant_outlined,
                    label: 'A meal',
                    sublabel: 'What did $name last eat or drink?',
                    semanticsLabel:
                        'Log a meal — what did $name last eat or drink?',
                    onTap: () => _openAndFinish(AppRoutes.meals),
                  ),
                  _LogOptionCard(
                    icon: Icons.medication_outlined,
                    label: 'A medication',
                    sublabel: 'Add something $name is currently taking',
                    semanticsLabel:
                        'Log a medication — add something $name is currently taking',
                    onTap: () => _openAndFinish(AppRoutes.medications),
                  ),
                  _LogOptionCard(
                    icon: Icons.book_outlined,
                    label: 'A journal entry',
                    sublabel: 'Write down how today has really gone',
                    semanticsLabel:
                        'Write a journal entry — how has today really gone?',
                    onTap: () => _openAndFinish(AppRoutes.journal),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Dismiss link
          Center(
            child: Semantics(
              button: true,
              label: "Skip for now, explore $name's data on my own",
              child: TextButton(
                onPressed: _dismiss,
                child: const Text("I'll explore on my own  →"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual option card in the first-log prompt grid.
class _LogOptionCard extends StatelessWidget {
  const _LogOptionCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.semanticsLabel,
    required this.onTap,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final String semanticsLabel;
  final VoidCallback onTap;

  /// When true the card expands to full row width (used for the illness card).
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final card = Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: fullWidth
                ? Row(
                    children: [
                      Icon(icon, size: 28, color: cs.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: tt.titleSmall?.copyWith(
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sublabel,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 28, color: cs.primary),
                      const Spacer(),
                      Text(
                        label,
                        style: tt.titleSmall?.copyWith(color: cs.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sublabel,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    if (fullWidth) return SizedBox(width: double.infinity, child: card);
    return card;
  }
}
