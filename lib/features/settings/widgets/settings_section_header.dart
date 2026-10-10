import 'package:flutter/material.dart';

/// Small caps-style label above a group of settings tiles.
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(
        label,
        style: tt.labelSmall?.copyWith(
          color: cs.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
