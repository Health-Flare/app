import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/profiles/widgets/profile_avatar.dart';
import 'package:health_flare/models/profile.dart';

/// App-bar action for reassigning an existing entry to another profile:
/// recovery for the "logged it under the wrong person" mistake.
///
/// Renders nothing when only one profile exists. The flow is built so that
/// nothing is ever lost:
///
/// 1. Pick a profile from a sheet listing every other profile.
/// 2. Confirm in a dialog that says what, if anything, the move changes
///    ([notices] for every target, [noticesFor] per target).
/// 3. [beforeMove] runs first, so an edit screen saves pending changes and
///    they move with the entry. If it returns false, nothing moves and the
///    screen stays open.
/// 4. [onMove] does the reassignment in one transaction. If it throws, the
///    entry is untouched; the person is told and the screen stays open.
/// 5. Only on success: a confirmation snackbar, and the screen pops (the
///    entry no longer belongs to the profile being viewed).
class MoveEntryAction extends ConsumerWidget {
  const MoveEntryAction({
    super.key,
    required this.onMove,
    this.beforeMove,
    this.notices = const [],
    this.noticesFor,
  });

  /// Performs the actual reassignment (a provider `moveToProfile` call).
  final Future<void> Function(Profile target) onMove;

  /// Runs before [onMove]; return false to abort (e.g. validation failed).
  final Future<bool> Function()? beforeMove;

  /// Lines for the confirmation, shown for every target.
  final List<String> notices;

  /// Target-specific lines for the confirmation, shown after [notices].
  final List<String> Function(Profile target)? noticesFor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profileListProvider);
    final activeId = ref.watch(activeProfileProvider);
    final others = profiles.where((p) => p.id != activeId).toList();
    if (others.isEmpty) return const SizedBox.shrink();
    final current = profiles.where((p) => p.id == activeId).firstOrNull;

    return IconButton(
      icon: const Icon(Icons.swap_horiz),
      tooltip: 'Move to another profile',
      onPressed: () => _pickAndMove(context, others, current),
    );
  }

  Future<void> _pickAndMove(
    BuildContext context,
    List<Profile> targets,
    Profile? current,
  ) async {
    final target = await showModalBottomSheet<Profile>(
      context: context,
      useSafeArea: true,
      builder: (_) => _MoveTargetSheet(targets: targets),
    );
    if (target == null || !context.mounted) return;

    final lines = [...notices, ...?noticesFor?.call(target)];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Move to ${target.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The entry keeps its date and details. Only the person it '
              'belongs to changes.',
            ),
            for (final line in lines) ...[
              const SizedBox(height: 8),
              Text(line),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Move'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    if (beforeMove != null && !await beforeMove!()) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Fix the highlighted fields first, then move it again.',
          ),
        ),
      );
      return;
    }

    try {
      await onMove(target);
    } catch (_) {
      final owner = current == null ? 'the original' : "${current.name}'s";
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't move this entry. It's still in $owner record.",
          ),
        ),
      );
      return;
    }
    if (!context.mounted) return;

    messenger.showSnackBar(SnackBar(content: Text('Moved to ${target.name}')));
    context.pop();
  }
}

class _MoveTargetSheet extends StatelessWidget {
  const _MoveTargetSheet({required this.targets});

  final List<Profile> targets;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
            child: Text(
              'Move this entry to',
              style: tt.titleLarge?.copyWith(color: cs.onSurface),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              'The entry keeps its date and details. Only the person '
              'it belongs to changes.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          for (final profile in targets)
            ListTile(
              leading: ProfileAvatar(profile: profile),
              title: Text(profile.name),
              onTap: () => Navigator.of(context).pop(profile),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
