import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/journal_entry.dart';

/// Full detail view for a single journal entry.
///
/// Shows the complete entry text (selectable for copying to share with a
/// doctor), along with mood, energy, title, and timestamps. Edit and
/// delete actions are in the AppBar.
class JournalDetailScreen extends ConsumerWidget {
  const JournalDetailScreen({super.key, required this.entryId});

  final int entryId;

  static final _dateTimeFormat = DateFormat('EEEE d MMMM yyyy \'at\' h:mm a');
  static final _shortFormat = DateFormat('d MMM \'at\' h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(journalEntryListProvider.notifier).byId(entryId);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Entry may have been deleted — pop back gracefully.
    if (entry == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Entry not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit entry',
            onPressed: () => context.push(AppRoutes.journalEdit(entry.id)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete entry',
            onPressed: () => _confirmDelete(context, ref, entry),
          ),
          // Leave space for the shell overlay profile avatar.
          const SizedBox(width: 56),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Text(
              _dateTimeFormat.format(entry.createdAt),
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),

            // Mood and energy chips (only shown if set)
            if (entry.moodValue != null || entry.energyLevel != null) ...[
              Row(
                children: [
                  if (entry.moodValue != null)
                    _InfoChip(
                      label:
                          '${entry.moodValue!.emoji}  ${entry.moodValue!.label}',
                      semanticLabel: 'Mood: ${entry.moodValue!.label}',
                    ),
                  if (entry.moodValue != null && entry.energyLevel != null)
                    const SizedBox(width: 8),
                  if (entry.energyLevel != null)
                    _InfoChip(
                      label: 'Energy ${entry.energyLevel}/5',
                      semanticLabel:
                          'Energy level: ${entry.energyLevel} out of 5',
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Title (if set)
            if (entry.title != null && entry.title!.trim().isNotEmpty) ...[
              Text(
                entry.title!,
                style: tt.headlineSmall?.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: 12),
            ],

            // Body — SelectableText so users can copy to share with doctor
            SelectableText(
              entry.body,
              style: tt.bodyLarge?.copyWith(color: cs.onSurface, height: 1.6),
            ),

            // Last-saved timestamp (shown when the entry has been edited after creation)
            if (entry.wasEdited) ...[
              const SizedBox(height: 24),
              Text(
                'Last saved ${_shortFormat.format(entry.lastSavedAt)}',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    JournalEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this entry?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(journalEntryListProvider.notifier).remove(entry.id);
      if (context.mounted) context.pop();
    }
  }
}

/// A small read-only chip for displaying mood or energy in the detail view.
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.semanticLabel});

  final String label;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: cs.surfaceContainerHighest,
        ),
        child: Text(
          label,
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}
