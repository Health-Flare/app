import 'package:flutter/material.dart';

import 'package:health_flare/models/interference.dart';

/// Five choice chips for "How much did it get in the way?".
///
/// Nothing is selected until the person picks; tapping the selected chip
/// clears it back to null ("not recorded"). Null is never shown or stored as
/// "Not at all".
class InterferenceSelector extends StatelessWidget {
  const InterferenceSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// 1 to 5, or null when not recorded.
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key('interference_selector'),
      spacing: 8,
      runSpacing: 4,
      children: [
        for (var i = 0; i < Interference.labels.length; i++)
          ChoiceChip(
            label: Text(Interference.labels[i]),
            selected: value == i + 1,
            onSelected: (_) => onChanged(value == i + 1 ? null : i + 1),
          ),
      ],
    );
  }
}
