import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/whats_new/models/release_note.dart';
import 'package:health_flare/features/whats_new/whats_new_provider.dart';

/// Dashboard card after an update with highlights (#139).
///
/// Sits inline in the dashboard list: nothing covers the screen, no badge,
/// no count. Waits during an active flare. One gesture (close button or
/// swipe) dismisses it for good; opening What's new counts as seen.
/// Spec: docs/features/whats-new.feature.
class WhatsNewCard extends ConsumerStatefulWidget {
  const WhatsNewCard({super.key});

  @override
  ConsumerState<WhatsNewCard> createState() => _WhatsNewCardState();
}

class _WhatsNewCardState extends ConsumerState<WhatsNewCard> {
  /// Set the moment the card is dismissed, so it leaves the tree in the
  /// same frame (Dismissible requires it) before the save lands.
  bool _gone = false;
  bool _noted = false;

  void _noteShown(String message) {
    if (_noted) return;
    _noted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // Counted, and announced, once per app launch: coming back to the
      // dashboard doesn't repeat it.
      final first = await ref.read(whatsNewProvider.notifier).noteCardShown();
      if (!first || !mounted) return;
      // Polite, and focus stays where it was.
      unawaited(
        SemanticsService.sendAnnouncement(
          View.of(context),
          message,
          Directionality.of(context),
        ),
      );
    });
  }

  void _dismiss() {
    setState(() => _gone = true);
    unawaited(ref.read(whatsNewProvider.notifier).dismiss());
  }

  void _open() {
    _dismiss();
    context.push(AppRoutes.whatsNew);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(whatsNewProvider).value;
    final flaring = ref.watch(activeFlareProvider) != null;
    final releases = state?.card ?? const <ReleaseNote>[];
    if (_gone || flaring || releases.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final title = releases.length == 1
        ? "What's new in ${_short(releases.first.version)}"
        : "What's new since your last update";
    final highlights = [
      for (final r in releases) ...r.highlights.map((h) => h.title),
    ];
    _noteShown('$title. ${highlights.join('. ')}.');

    return Dismissible(
      key: const ValueKey('whats-new-card'),
      onDismissed: (_) => _dismiss(),
      movementDuration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 200),
      resizeDuration: reduceMotion ? null : const Duration(milliseconds: 300),
      child: Card(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        color: cs.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_outlined, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: tt.titleSmall?.copyWith(
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Dismiss',
                    color: cs.onPrimaryContainer,
                    onPressed: _dismiss,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 36, right: 12),
                child: Text(
                  highlights.join(' · '),
                  style: tt.bodyMedium?.copyWith(color: cs.onPrimaryContainer),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: _open,
                  child: const Text("See what's new"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "1.10.0" -> "1.10"; patch versions keep all three parts.
String _short(String v) => v.endsWith('.0') ? v.substring(0, v.length - 2) : v;
