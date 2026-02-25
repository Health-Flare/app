import 'dart:io';
import 'package:flutter/material.dart';

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
  });

  final Profile profile;

  /// Circle radius in logical pixels. Defaults to 24 (48px diameter).
  final double radius;

  /// When true, draws a 2px primary-coloured border — used for the
  /// active profile indicator in the switcher.
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = _avatarColor(profile.id);

    final circle = CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      backgroundImage: profile.hasAvatar
          ? FileImage(File(profile.avatarPath!))
          : null,
      child: profile.hasAvatar
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

  /// Deterministic colour from a small, accessible palette.
  static Color _avatarColor(int id) {
    const palette = [
      Color(0xFF2A9D8F), // teal
      Color(0xFF457B9D), // slate blue
      Color(0xFFE76F51), // coral
      Color(0xFF6A4C93), // purple
      Color(0xFF1D7A45), // forest green
      Color(0xFFD4A017), // amber
      Color(0xFF264653), // deep teal
      Color(0xFFC0392B), // crimson
    ];
    return palette[id % palette.length];
  }
}
