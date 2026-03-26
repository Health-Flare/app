import 'package:flutter/material.dart';

/// A row of 5 quality buttons (1–5) with anchor labels at each end.
///
/// 1 = "Very poor", 5 = "Restful". The selected value is highlighted with
/// the primary colour. Tapping the currently selected value deselects it
/// (sets [value] back to null via [onChanged]).
class SleepQualitySelector extends StatelessWidget {
  const SleepQualitySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// Currently selected quality (1–5), or null if none selected.
  final int? value;

  final void Function(int? quality) onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      key: const Key('sleep_quality_selector'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(5, (i) {
            final rating = i + 1;
            final selected = value == rating;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _QualityButton(
                  rating: rating,
                  selected: selected,
                  onTap: () => onChanged(selected ? null : rating),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Very poor',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            Text(
              'Restful',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}

class _QualityButton extends StatelessWidget {
  const _QualityButton({
    required this.rating,
    required this.selected,
    required this.onTap,
  });

  final int rating;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          '$rating',
          style: TextStyle(
            color: selected ? cs.onPrimary : cs.onSurfaceVariant,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
