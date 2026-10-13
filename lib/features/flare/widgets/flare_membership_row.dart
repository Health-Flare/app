// "Part of the Fibromyalgia flare" on the entry forms (#173). Worked out
// from the time on the form, so it changes as the date does. Remove takes
// the entry out of its flare; Add back puts it back.
// Spec: docs/features/flare.feature, "Which flare an entry is part of".
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/flare_entries_provider.dart';
import 'package:health_flare/models/flare.dart';
import 'package:health_flare/models/user_condition.dart';

/// "the Fibromyalgia flare", "the Fibromyalgia and Arthritis flare", or,
/// with no conditions, "the flare that started 3 Mar".
String flareName(Flare flare, List<UserCondition> conditions) {
  final names = [
    for (final id in flare.conditionIsarIds)
      for (final c in conditions)
        if (c.id == id) c.conditionName,
  ];
  if (names.isEmpty) {
    return 'the flare that started ${DateFormat('d MMM').format(flare.startedAt)}';
  }
  final joined = names.length == 1
      ? names.single
      : '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
  return 'the $joined flare';
}

class FlareMembershipRow extends ConsumerWidget {
  const FlareMembershipRow({
    super.key,
    required this.profileId,
    required this.at,
    required this.pinnedFlareId,
    required this.detached,
    required this.onChanged,
  });

  final int profileId;
  final DateTime at;
  final int? pinnedFlareId;
  final bool detached;

  /// Called with the new "taken out" value.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inFlare = ref.watch(
      entryFlareProvider((
        profileId: profileId,
        at: at,
        pinnedFlareId: pinnedFlareId,
        detached: detached,
      )),
    );
    final covering = ref.watch(
      coveringFlareProvider((profileId: profileId, at: at)),
    );
    final flare = inFlare ?? (detached ? covering : null);
    if (flare == null) return const SizedBox.shrink();

    final name = flareName(flare, ref.watch(userConditionListProvider));
    final cs = Theme.of(context).colorScheme;
    final part = inFlare != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            part ? Icons.local_fire_department : Icons.link_off,
            size: 20,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              part ? 'Part of $name' : 'Not part of $name',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () => onChanged(part),
            child: Text(part ? 'Remove' : 'Add back'),
          ),
        ],
      ),
    );
  }
}
