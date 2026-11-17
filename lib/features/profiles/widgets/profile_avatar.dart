import 'dart:io';
import 'package:flutter/material.dart';

import 'package:health_flare/core/files/photo_store.dart';
import 'package:health_flare/core/theme/app_colors.dart';
import 'package:health_flare/models/profile.dart';

/// Reusable circular avatar for a [Profile].
///
/// Shows the photo at [Profile.avatarPath] if available, otherwise
/// renders a coloured circle with [Profile.initials]. The colour is
/// deterministically derived from the profile id so it is always the
/// same for a given person.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.profile,
    this.radius = 24,
    this.showBorder = false,
    this.previewFile,
  });

  final Profile profile;

  /// A just-picked image to show before the profile is saved (#105).
  final File? previewFile;

  /// Circle radius in logical pixels. Defaults to 24 (48px diameter).
  final double radius;

  /// When true, draws a 2px primary-coloured border: used for the
  /// active profile indicator in the switcher.
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = _avatarColor(profile.id);
    // Only the app's own photos are shown (#105); a picked one is
    // previewed before it's saved.
    final photo = previewFile ?? PhotoStore.resolve(profile.avatarPath);

    final circle = CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      backgroundImage: photo == null ? null : FileImage(photo),
      child: photo != null
          ? null
          : Text(
              profile.initials,
              style: TextStyle(
                fontSize: radius * 0.75,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0,
              ),
            ),
    );

    if (!showBorder) return circle;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: cs.primary, width: 2.5),
      ),
      child: Padding(padding: const EdgeInsets.all(2), child: circle),
    );
  }

  /// Deterministic colour from the brand's profile tag palette
  /// (brand-guidelines.md v2.2) — no semantic meaning, just tells profiles
  /// apart at a glance.
  static Color _avatarColor(int id) {
    const palette = AppColors.profileTagPalette;
    return palette[id % palette.length];
  }
}
