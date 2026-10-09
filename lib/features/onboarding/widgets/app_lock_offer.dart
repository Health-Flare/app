import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/app_lock_provider.dart';
import 'package:health_flare/core/security/device_auth.dart';
import 'package:health_flare/features/app_lock/app_lock_flows.dart';

// Onboarding privacy step offer for the app lock (#100).
// Spec: docs/features/app-lock.feature

/// "Lock Health Flare" switch on the onboarding privacy step. Renders
/// nothing on platforms without the lock.
class AppLockOffer extends ConsumerWidget {
  const AppLockOffer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(appLockSupportedProvider)) return const SizedBox.shrink();
    final enabled = ref.watch(
      appLockProvider.select((s) => s.settings.enabled),
    );

    // Own Material: the privacy step paints a coloured background, which
    // would hide the tile's ink.
    return Material(
      type: MaterialType.transparency,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Lock Health Flare'),
        subtitle: const Text(appLockDescription),
        value: enabled,
        onChanged: (on) async {
          if (on) {
            await turnOnAppLock(context, ref);
          } else {
            await ref.read(appLockProvider.notifier).disable();
          }
        },
      ),
    );
  }
}
