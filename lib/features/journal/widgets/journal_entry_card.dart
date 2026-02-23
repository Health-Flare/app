import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/journal_entry.dart';

/// A single journal entry row in the [JournalListScreen].
///
/// Shows:
/// - Date and time, with mood emoji if set
/// - Title or first-line preview
/// - Up to two lines of body snippet
/// - Energy level dots if set
class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final JournalEntry entry;
  final VoidCallback onTap;

  static final _timeFormat = DateFormat('h:mm a');
  static final _dateFormat = DateFormat('EEE d MMM');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final mood = entry.moodValue;
    final energy = entry.energyLevel;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date row with optional mood emoji
              Row(
                children: [
                  Text(
                    '${_dateFormat.format(entry.createdAt)}  '
                    '${_timeFormat.format(entry.createdAt)}',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (mood != null)
                    Semantics(
                      label: mood.label,
                      child: Text(
                        mood.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              // Title or preview
              Text(
                entry.displayTitle,
                style: tt.titleSmall?.copyWith(color: cs.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Body snippet (only if there's more content beyond the title)
              if (_hasBodySnippet(entry)) ...[
                const SizedBox(height: 4),
                Text(
                  _bodySnippet(entry),
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              // Energy level dots
              if (energy != null) ...[
                const SizedBox(height: 8),
                Semantics(
                  label: 'Energy: $energy out of 5',
                  child: Row(
                    children: List.generate(5, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < energy
                                ? cs.primary
                                : cs.outlineVariant,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _hasBodySnippet(JournalEntry entry) {
    // Show snippet only if the entry has meaningful content beyond the title
    if (entry.title != null && entry.title!.trim().isNotEmpty) {
      return entry.body.trim().isNotEmpty;
    }
    // No title set — the first line is the display title. Show additional lines.
    final lines = entry.body.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines.length > 1;
  }

  String _bodySnippet(JournalEntry entry) {
    if (entry.title != null && entry.title!.trim().isNotEmpty) {
      // Return the start of the body as the snippet
      return entry.body.trim();
    }
    // Skip the first non-empty line (used as title) and return the rest
    final lines = entry.body.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.length <= 1) return '';
    return lines.skip(1).join(' ');
  }
}
