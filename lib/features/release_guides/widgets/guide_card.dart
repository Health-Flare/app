import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/release_guides/guide_rules.dart';
import 'package:health_flare/features/release_guides/release_guide_provider.dart';

/// Set once a guide has been opened this app launch, so a saved step
/// resumes the guide only once per launch.
final guideOpenedThisLaunchProvider = StateProvider<bool>((ref) => false);

/// The dashboard card for a release guide (#145). Inline, like the What's
/// new card, which waits while this one is showing. Waits during a flare.
/// Spec: docs/features/release-guides.feature ("The guide card").
class GuideCard extends ConsumerStatefulWidget {
  const GuideCard({super.key});

  @override
  ConsumerState<GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends ConsumerState<GuideCard> {
  void _open({int? step}) {
    final s = ref.read(releaseGuideProvider);
    context.push(
      AppRoutes.guide(s.guide!.id, step: step ?? s.record.resumeStep ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(guideCardModeProvider);
    final s = ref.watch(releaseGuideProvider);
    final flaring = ref.watch(activeFlareProvider) != null;
    final change = s.change;
    final guide = s.guide;
    if (change == null || guide == null || s.highlightsOff || flaring) {
      return const SizedBox.shrink();
    }

    // Left mid-guide last time (a call, the app closed): carry on there.
    final resume = s.record.resumeStep;
    if (resume != null && !ref.read(guideOpenedThisLaunchProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || ref.read(guideOpenedThisLaunchProvider)) return;
        ref.read(guideOpenedThisLaunchProvider.notifier).state = true;
        _open(step: resume);
      });
    }
    if (mode == GuideCardMode.hidden) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final notes = movedPinNotes(
      ref.read(releaseGuideProvider).change!.customized ? change.before : null,
    );
    final notifier = ref.read(releaseGuideProvider.notifier);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.swap_horiz_rounded, color: cs.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    guideCardTitle(customized: change.customized),
                    style: tt.titleSmall?.copyWith(
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 36, right: 8, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!change.customized)
                    Text(
                      guide.cardBody,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  for (final n in notes)
                    Text(
                      n,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                ],
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                spacing: 4,
                children: [
                  TextButton(
                    onPressed: mode == GuideCardMode.dismiss
                        ? notifier.markSeen
                        : notifier.putOff,
                    child: Text(
                      mode == GuideCardMode.dismiss ? 'Dismiss' : 'Not now',
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: _open,
                    child: const Text('Show me'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
