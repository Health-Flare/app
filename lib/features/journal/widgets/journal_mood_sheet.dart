import 'package:flutter/material.dart';

import '../../../models/journal_entry.dart';

/// Bottom sheet for picking a mood value.
///
/// Displays five emoji buttons in a row. Tapping one calls [onSelected]
/// and pops the sheet. An already-selected mood is visually highlighted.
class JournalMoodSheet extends StatelessWidget {
  const JournalMoodSheet({
    super.key,
    required this.currentMood,
    required this.onSelected,
  });

  final JournalMood? currentMood;
  final ValueChanged<JournalMood?> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withAlpha(76),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'How are you feeling?',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: JournalMood.values.map((mood) {
                final isSelected = mood == currentMood;
                return Semantics(
                  button: true,
                  selected: isSelected,
                  label: mood.label,
                  child: GestureDetector(
                    onTap: () {
                      // Tapping the already-selected mood clears it
                      onSelected(isSelected ? null : mood);
                      Navigator.of(context).pop();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? cs.primaryContainer
                            : Colors.transparent,
                      ),
                      child: Column(
                        children: [
                          Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mood.label,
                            style: tt.labelSmall?.copyWith(
                              color: isSelected
                                  ? cs.onPrimaryContainer
                                  : cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
