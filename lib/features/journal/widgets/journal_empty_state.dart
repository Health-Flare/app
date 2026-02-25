import 'package:flutter/material.dart';

/// Empty state shown in the journal list when there are no entries,
/// or when a search returns no results.
class JournalEmptyState extends StatelessWidget {
  const JournalEmptyState({
    super.key,
    required this.isSearch,
    this.onClearSearch,
  });

  /// True when the empty state is caused by a search with no results.
  /// False when the journal genuinely has no entries yet.
  final bool isSearch;

  /// Called when the user taps "Clear search". Only relevant when [isSearch].
  final VoidCallback? onClearSearch;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (isSearch) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 56,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(height: 20),
              Text(
                'No entries found.',
                style: tt.titleMedium?.copyWith(color: cs.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onClearSearch,
                child: const Text('Clear search'),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note_rounded, size: 64, color: cs.primary),
            const SizedBox(height: 24),
            Text(
              'Nothing written yet.',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This is your space. Write whatever helps — how you\'re '
              'feeling, what you noticed, things to tell your doctor.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
