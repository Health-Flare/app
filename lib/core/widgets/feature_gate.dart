import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/navigation/features_in_use.dart';

/// Shows [child] only while [featureId] is on for the active profile
/// (#142). For a feature's cards and prompts, never for its data.
class FeatureGate extends ConsumerWidget {
  const FeatureGate({super.key, required this.featureId, required this.child});

  final String featureId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(featureOnProvider(featureId)) ? child : const SizedBox.shrink();
}
