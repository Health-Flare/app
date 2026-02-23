import 'package:flutter/material.dart';

import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/features/journal/widgets/journal_energy_sheet.dart';
import 'package:health_flare/features/journal/widgets/journal_mood_sheet.dart';

/// A row of optional enrichment chips pinned above the keyboard in the
/// journal composer.
///
/// Contains:
/// - Mood chip (opens [JournalMoodSheet])
/// - Energy chip (opens [JournalEnergySheet])
///
/// Both are always visible but unobtrusive when unset. Selecting a value
/// updates the chip to show the current value and calls the appropriate
/// callback. Tapping an already-set value allows clearing it.
class JournalEnrichmentBar extends StatelessWidget {
  const JournalEnrichmentBar({
    super.key,
    required this.mood,
    required this.energyLevel,
    required this.onMoodChanged,
    required this.onEnergyChanged,
  });

  final JournalMood? mood;
  final int? energyLevel;
  final ValueChanged<JournalMood?> onMoodChanged;
  final ValueChanged<int?> onEnergyChanged;

  void _showMoodSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => JournalMoodSheet(
        currentMood: mood,
        onSelected: onMoodChanged,
      ),
    );
  }

  void _showEnergySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => JournalEnergySheet(
        currentLevel: energyLevel,
        onSelected: onEnergyChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Mood chip
          _EnrichmentChip(
            icon: Icons.mood_rounded,
            label: mood != null ? '${mood!.emoji} ${mood!.label}' : 'Mood',
            isSet: mood != null,
            semanticLabel: mood != null
                ? 'Mood: ${mood!.label}. Tap to change.'
                : 'Add mood',
            onTap: () => _showMoodSheet(context),
          ),
          const SizedBox(width: 8),
          // Energy chip
          _EnrichmentChip(
            icon: Icons.bolt_rounded,
            label: energyLevel != null ? 'Energy: $energyLevel' : 'Energy',
            isSet: energyLevel != null,
            semanticLabel: energyLevel != null
                ? 'Energy level: $energyLevel out of 5. Tap to change.'
                : 'Add energy level',
            onTap: () => _showEnergySheet(context),
          ),
        ],
      ),
    );
  }
}

class _EnrichmentChip extends StatelessWidget {
  const _EnrichmentChip({
    required this.icon,
    required this.label,
    required this.isSet,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSet;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSet ? cs.primaryContainer : cs.surfaceContainerHighest,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSet ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: tt.labelSmall?.copyWith(
                  color: isSet ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
