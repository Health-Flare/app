import 'package:flutter/material.dart';

import 'package:health_flare/features/reports/models/insight_data.dart';

/// Vital trends on the insights screen: a picker over the vital types that
/// have readings, and a chart fitted to the selected type's values.
class VitalTrendsCard extends StatelessWidget {
  const VitalTrendsCard({super.key, required this.data});

  final InsightData data;

  @override
  Widget build(BuildContext context) {
    // TODO(#83): not implemented yet.
    return const SizedBox.shrink();
  }
}
