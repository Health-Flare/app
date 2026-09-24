import 'package:flutter/material.dart';

import 'package:health_flare/features/quick_log/widgets/quick_log_sheet.dart';

/// The dashboard + button that opens Quick Log.
///
/// Typed screens (Tracking, Meds, Meals, Journal, Sleep) keep their own
/// add buttons. Quick Log is the cross-type entry point on the dashboard.
class QuickLogFab extends StatelessWidget {
  const QuickLogFab({super.key, this.heroTag = 'quick_log_fab'});

  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      tooltip: 'Open quick log',
      onPressed: () => showQuickLogSheet(context),
      child: const Icon(Icons.add_rounded),
    );
  }
}
