import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/app_lock_provider.dart';
import 'package:health_flare/core/security/device_auth.dart';
import 'package:health_flare/features/app_lock/app_lock_flows.dart';
import 'package:health_flare/features/settings/widgets/settings_section_header.dart';

// Settings > Privacy (#100, #101). Spec: docs/features/app-lock.feature

/// App lock, its re-lock time, and hide in app switcher. Renders nothing on
/// platforms without the lock (desktop, web).
class PrivacySettingsSection extends ConsumerWidget {
  const PrivacySettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(appLockSupportedProvider)) return const SizedBox.shrink();
    final settings = ref.watch(appLockProvider.select((s) => s.settings));
    final lock = ref.read(appLockProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsSectionHeader(label: 'Privacy'),
        SwitchListTile(
          secondary: const Icon(Icons.lock_outline),
          title: const Text('App lock'),
          subtitle: const Text(appLockDescription),
          value: settings.enabled,
          onChanged: (on) async {
            if (on) {
              await turnOnAppLock(context, ref);
            } else {
              await lock.disable();
            }
          },
        ),
        if (settings.enabled)
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Lock after'),
            subtitle: Text(settings.relockAfter.label),
            onTap: () => _pickRelockAfter(context, ref, settings.relockAfter),
          ),
        SwitchListTile(
          secondary: const Icon(Icons.visibility_off_outlined),
          title: const Text('Hide in app switcher'),
          subtitle: Text(_hideDescription),
          value: settings.hideInAppSwitcher,
          onChanged: lock.setHideInAppSwitcher,
        ),
      ],
    );
  }

  /// Android's FLAG_SECURE can't hide the app switcher without also
  /// blocking screenshots, so the copy says so there. iOS only covers the
  /// app switcher snapshot.
  static String get _hideDescription =>
      defaultTargetPlatform == TargetPlatform.android
      ? 'Show a blank screen in the app switcher instead of your records. '
            'This also blocks screenshots and screen recording of Health '
            'Flare.'
      : 'Show a plain screen in the app switcher instead of your records.';

  Future<void> _pickRelockAfter(
    BuildContext context,
    WidgetRef ref,
    RelockAfter current,
  ) async {
    final picked = await showDialog<RelockAfter>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Lock after'),
        children: [
          RadioGroup<RelockAfter>(
            groupValue: current,
            onChanged: (value) => Navigator.of(context).pop(value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in RelockAfter.values)
                  RadioListTile<RelockAfter>(
                    value: option,
                    title: Text(option.label),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked == null) return;
    await ref.read(appLockProvider.notifier).setRelockAfter(picked);
  }
}
