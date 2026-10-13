// "Part of the Fibromyalgia flare" on the entry forms (#173). Worked out
// from the time on the form, so it changes as the date does. Remove takes
// the entry out of its flare; Add back puts it back.
// Spec: docs/features/flare.feature, "Which flare an entry is part of".
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/models/flare.dart';
import 'package:health_flare/models/user_condition.dart';

/// "the Fibromyalgia flare", "the Fibromyalgia and Arthritis flare", or,
/// with no conditions, "the flare that started 3 Mar".
String flareName(Flare flare, List<UserCondition> conditions) {
  return ''; // TODO(#173): red stub
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
    return const SizedBox.shrink(); // TODO(#173): red stub
  }
}

// Kept for the implementation.
// ignore: unused_element
final _date = DateFormat('d MMM');
