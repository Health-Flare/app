import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/profiles/widgets/profile_avatar.dart';
import 'package:health_flare/features/profiles/widgets/profile_switcher_sheet.dart';

/// Persistent profile avatar button embedded in every [HFAppBar].
///
/// Tap → opens the profile switcher sheet.
/// Swipe up → activates the profile one step earlier in the list
///            (wraps from first to last).
/// Swipe down → activates the profile one step later in the list
///              (wraps from last to first).
/// Both gestures are no-ops when only one profile exists.
class ProfileIconButton extends ConsumerWidget {
  const ProfileIconButton({super.key});

  void _cycleProfile(WidgetRef ref, {required bool up}) {
    final profiles = ref.read(profileListProvider);
    if (profiles.length <= 1) return;
    final activeId = ref.read(activeProfileProvider);
    final currentIndex = profiles.indexWhere((p) => p.id == activeId);
    if (currentIndex < 0) return;
    final nextIndex = up
        ? (currentIndex - 1 + profiles.length) % profiles.length
        : (currentIndex + 1) % profiles.length;
    ref.read(activeProfileProvider.notifier).setActive(profiles[nextIndex].id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileDataProvider);

    return GestureDetector(
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < 0) _cycleProfile(ref, up: true);
        if (velocity > 0) _cycleProfile(ref, up: false);
      },
      child: Semantics(
        button: true,
        label: activeProfile != null
            ? 'Switch profile. Current: ${activeProfile.name}'
            : 'Switch profile',
        child: InkWell(
          onTap: () => showProfileSwitcher(context),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: activeProfile != null
                ? ProfileAvatar(profile: activeProfile, radius: 18)
                : _DefaultProfileIcon(),
          ),
        ),
      ),
    );
  }
}

class _DefaultProfileIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 18,
      backgroundColor: cs.surfaceContainerHighest,
      child: Icon(
        Icons.person_outline_rounded,
        size: 20,
        color: cs.onSurfaceVariant,
      ),
    );
  }
}
