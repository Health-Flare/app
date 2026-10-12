import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/failed_upgrade/failed_upgrade_provider.dart';

/// Top of the dashboard while an upgrade has stopped retrying (#112). Stays
/// until it's resolved: no close button, no swipe.
class FailedUpgradeCard extends ConsumerWidget {
  const FailedUpgradeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(failedUpgradeProvider) == null) {
      return const SizedBox.shrink();
    }
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: cs.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.update_disabled_rounded, color: cs.tertiary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "This update didn't finish",
                    style: tt.titleSmall?.copyWith(
                      color: cs.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 36, right: 8, top: 4),
              child: Text(
                'Your data is safe and the app works. Updating the app again '
                'will retry it.',
                style: tt.bodyMedium?.copyWith(color: cs.onTertiaryContainer),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => context.push(AppRoutes.settingsUpdate),
                child: const Text('Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
