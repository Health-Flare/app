import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/settings/widgets/settings_section_header.dart';

/// Settings > Your layout (#142). Features in use now; the bottom bar
/// joins it in #143. Hidden until Track and Care ships.
class YourLayoutTiles extends ConsumerWidget {
  const YourLayoutTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(featureFlagsProvider).trackAndCare) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsSectionHeader(label: 'Your layout'),
        ListTile(
          leading: const Icon(Icons.tune_rounded),
          title: const Text('Features in use'),
          subtitle: const Text("Turn off what you don't track"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(AppRoutes.featuresInUse),
        ),
      ],
    );
  }
}
