import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/core/router/app_router.dart';

/// First-log prompt — shown once, immediately after the first profile
/// is created, over the dashboard.
///
/// Presents four option cards (Symptom, Vital, Meal, Medication) and a
/// dismiss link. Tapping a card navigates to the relevant entry form.
/// Dismissing or completing an entry marks the prompt as done permanently.
///
/// Copy source: docs/onboarding-copy.md › Post-Setup: First-Log Prompt
class FirstLogPrompt extends ConsumerWidget {
  const FirstLogPrompt({super.key, required this.profileName});

  final String profileName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: cs.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Heading — personalised with profile name
            Text(
              "You're all set, $profileName.",
              style: tt.headlineSmall?.copyWith(color: cs.onSurface),
            ),

            const SizedBox(height: 8),

            // Body
            Text(
              'The best way to spot patterns is to start logging now, while '
              'the day is fresh. What would you like to record first?',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // Option cards grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _LogOptionCard(
                  emoji: '🩺',
                  label: 'A symptom',
                  sublabel: 'How are you feeling right now?',
                  semanticsLabel:
                      'Log a symptom — how are you feeling right now?',
                  onTap: () {
                    ref.read(firstLogPromptProvider.notifier).dismiss();
                    Navigator.of(context).pop();
                    context.go(AppRoutes.symptoms);
                    // TODO: auto-open new symptom entry form
                  },
                ),
                _LogOptionCard(
                  emoji: '📊',
                  label: 'A vital',
                  sublabel: 'Blood pressure, heart rate, and more',
                  semanticsLabel:
                      'Log a vital — blood pressure, heart rate, and more',
                  onTap: () {
                    ref.read(firstLogPromptProvider.notifier).dismiss();
                    Navigator.of(context).pop();
                    context.go(AppRoutes.symptoms);
                    // TODO: auto-open new vital entry form
                  },
                ),
                _LogOptionCard(
                  emoji: '🍽️',
                  label: 'A meal',
                  sublabel: 'What did you last eat or drink?',
                  semanticsLabel:
                      'Log a meal — what did you last eat or drink?',
                  onTap: () {
                    ref.read(firstLogPromptProvider.notifier).dismiss();
                    Navigator.of(context).pop();
                    context.go(AppRoutes.meals);
                    // TODO: auto-open new meal entry form
                  },
                ),
                _LogOptionCard(
                  emoji: '💊',
                  label: 'A medication',
                  sublabel: "Add something you're currently taking",
                  semanticsLabel:
                      "Log a medication — add something you're currently taking",
                  onTap: () {
                    ref.read(firstLogPromptProvider.notifier).dismiss();
                    Navigator.of(context).pop();
                    context.go(AppRoutes.medications);
                    // TODO: auto-open add medication form
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Dismiss link
            Center(
              child: Semantics(
                button: true,
                label: 'Skip for now, explore the app on my own',
                child: TextButton(
                  onPressed: () {
                    ref.read(firstLogPromptProvider.notifier).dismiss();
                    Navigator.of(context).pop();
                  },
                  child: const Text("I'll explore on my own  →"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual option card in the first-log prompt grid.
class _LogOptionCard extends StatelessWidget {
  const _LogOptionCard({
    required this.emoji,
    required this.label,
    required this.sublabel,
    required this.semanticsLabel,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String sublabel;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Semantics(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
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
  }
}

/// Helper to show the first-log prompt as a modal bottom sheet.
///
/// Call this from the Dashboard after detecting [firstLogPromptProvider] == true.
Future<void> showFirstLogPrompt(
  BuildContext context, {
  required String profileName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: true,
    builder: (_) => FirstLogPrompt(profileName: profileName),
  );
}
