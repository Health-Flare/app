import 'package:flutter/material.dart';

/// Bottom sheet for picking an energy level (1–5).
///
/// 1 = exhausted, 5 = good energy. Tapping a level calls [onSelected]
/// and pops the sheet. An already-selected level is highlighted.
class JournalEnergySheet extends StatelessWidget {
  const JournalEnergySheet({
    super.key,
    required this.currentLevel,
    required this.onSelected,
  });

  final int? currentLevel;
  final ValueChanged<int?> onSelected;

  static const _labels = ['Exhausted', 'Low', 'Okay', 'Good', 'Great'];

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
              'How\'s your energy?',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) {
                final level = i + 1; // 1-indexed
                final isSelected = level == currentLevel;
                return Semantics(
                  button: true,
                  selected: isSelected,
                  label: 'Energy ${_labels[i]}',
                  child: GestureDetector(
                    onTap: () {
                      // Tapping the already-selected level clears it
                      onSelected(isSelected ? null : level);
                      Navigator.of(context).pop();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 56,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? cs.primaryContainer
                            : cs.surfaceContainerHighest,
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$level',
                            style: tt.titleLarge?.copyWith(
                              color: isSelected
                                  ? cs.onPrimaryContainer
                                  : cs.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _labels[i],
                            style: tt.labelSmall?.copyWith(
                              color: isSelected
                                  ? cs.onPrimaryContainer
                                  : cs.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
