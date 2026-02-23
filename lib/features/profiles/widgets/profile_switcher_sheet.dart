import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/features/profiles/widgets/profile_avatar.dart';
import 'package:health_flare/features/profiles/widgets/add_profile_sheet.dart';

/// Modal bottom sheet — profile switcher.
///
/// Shows all profiles with the active one highlighted. The user can:
///   • Tap a profile to switch to it
///   • Tap the edit icon on any profile to edit it
///   • Tap "Add profile" to create a new one
///
/// Opened via [showProfileSwitcher].
class ProfileSwitcherSheet extends ConsumerWidget {
  const ProfileSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profileListProvider);
    final activeId = ref.watch(activeProfileProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Drag handle ──────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.fromLTRB(0, 12, 0, 20),
              decoration: BoxDecoration(
                color: cs.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              'Profiles',
              style: tt.titleLarge?.copyWith(color: cs.onSurface),
            ),
          ),

          // ── Profile list ─────────────────────────────────────────────────
          if (profiles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'No profiles yet.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: profiles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final profile = profiles[index];
                final isActive = profile.id == activeId;
                return _ProfileTile(
                  profile: profile,
                  isActive: isActive,
                  onTap: () {
                    ref
                        .read(activeProfileProvider.notifier)
                        .setActive(profile.id);
                    Navigator.of(context).pop();
                  },
                  onEdit: () {
                    Navigator.of(context).pop();
                    showAddOrEditProfileSheet(context, existing: profile);
                  },
                );
              },
            ),

          const Divider(height: 24, indent: 24, endIndent: 24),

          // ── Add profile button ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, color: cs.primary),
              ),
              title: Text(
                'Add profile',
                style: tt.titleSmall?.copyWith(color: cs.primary),
              ),
              subtitle: Text(
                'Track a family member or dependant',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              onTap: () {
                Navigator.of(context).pop();
                showAddOrEditProfileSheet(context);
              },
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Individual profile row ──────────────────────────────────────────────────

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.profile,
    required this.isActive,
    required this.onTap,
    required this.onEdit,
  });

  final Profile profile;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Semantics(
      selected: isActive,
      label: isActive
          ? '${profile.name}, currently active profile'
          : profile.name,
      child: Material(
        color: isActive
            ? cs.primary.withAlpha(15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Avatar
                ProfileAvatar(
                  profile: profile,
                  radius: 24,
                  showBorder: isActive,
                ),

                const SizedBox(width: 16),

                // Name + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: tt.titleSmall?.copyWith(
                          color: cs.onSurface,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                      if (profile.ageLabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          profile.ageLabel!,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),

                // Active check
                if (isActive)
                  Icon(
                    Icons.check_circle_rounded,
                    color: cs.primary,
                    size: 20,
                    semanticLabel: 'Active',
                  ),

                // Edit button
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                  tooltip: 'Edit ${profile.name}',
                  onPressed: onEdit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Public helper ───────────────────────────────────────────────────────────

/// Show the profile switcher sheet from any context.
Future<void> showProfileSwitcher(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const ProfileSwitcherSheet(),
  );
}
