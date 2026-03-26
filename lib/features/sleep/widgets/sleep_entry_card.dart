import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/models/sleep_entry.dart';

/// A single row in the sleep history list.
///
/// Shows the wake-up date, duration, quality (if set), and a nap badge when
/// [entry.isNap] is true.
class SleepEntryCard extends StatelessWidget {
  const SleepEntryCard({super.key, required this.entry, required this.onTap});

  final SleepEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: _LeadingIcon(isNap: entry.isNap),
        title: Row(
          children: [
            Text(entry.formattedDuration, style: tt.titleMedium),
            if (entry.isNap) ...[const SizedBox(width: 8), _NapChip()],
          ],
        ),
        subtitle: Text(
          DateFormat('EEE d MMM, HH:mm').format(entry.wakeTime),
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: entry.qualityRating != null
            ? _QualityBadge(rating: entry.qualityRating!)
            : null,
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.isNap});
  final bool isNap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isNap ? Icons.airline_seat_flat : Icons.bedtime_outlined,
        color: cs.onSecondaryContainer,
        size: 20,
      ),
    );
  }
}

class _NapChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Nap',
        style: TextStyle(
          fontSize: 11,
          color: cs.onTertiaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  const _QualityBadge({required this.rating});
  final int rating;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$rating/5',
          style: TextStyle(
            color: cs.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          'quality',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
        ),
      ],
    );
  }
}
