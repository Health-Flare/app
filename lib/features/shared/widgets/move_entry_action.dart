import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/profiles/widgets/profile_avatar.dart';
import 'package:health_flare/models/profile.dart';

/// App-bar action for reassigning an existing entry to another profile —
/// recovery for the "logged it under the wrong person" mistake.
///
/// Renders nothing when only one profile exists. Tapping it opens a sheet
/// listing every other profile; choosing one calls [onMove], shows a
/// confirmation snackbar, and pops the current screen (the entry no longer
/// belongs to the profile being viewed).
class MoveEntryAction extends ConsumerWidget {
  const MoveEntryAction({super.key, required this.onMove});

  /// Performs the actual reassignment (a provider `moveToProfile` call).
  final Future<void> Function(Profile target) onMove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profileListProvider);
    final activeId = ref.watch(activeProfileProvider);
    final others = profiles.where((p) => p.id != activeId).toList();
    if (others.isEmpty) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.swap_horiz),
      tooltip: 'Move to another profile',
      onPressed: () => _pickAndMove(context, others),
    );
  }

  Future<void> _pickAndMove(BuildContext context, List<Profile> targets) async {
    final target = await showModalBottomSheet<Profile>(
      context: context,
      useSafeArea: true,
      builder: (_) => _MoveTargetSheet(targets: targets),
    );
    if (target == null || !context.mounted) return;

    await onMove(target);
    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Moved to ${target.name}')));
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
              'The entry keeps its date and details — only the person '
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
