import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/whats_new/whats_new_provider.dart';

/// Off means off: say so in the setting itself, no confirmation.
const kHighlightsOffText =
    "You won't get a card after updates, even when screens move. "
    "Everything stays in What's new.";

/// "What's new" and "Show update highlights" rows for Settings (#139).
class WhatsNewSettingsTiles extends ConsumerWidget {
  const WhatsNewSettingsTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(whatsNewProvider).value?.highlightsOn ?? true;
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.auto_awesome_outlined),
          title: const Text("What's new"),
          subtitle: const Text('Changes in each version of Health Flare'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(AppRoutes.whatsNew),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.campaign_outlined),
          title: const Text('Show update highlights'),
          subtitle: Text(
            on
                ? 'A short card on the dashboard after an update. '
                      'Dismiss it any time.'
                : kHighlightsOffText,
          ),
          value: on,
          onChanged: (v) =>
              ref.read(whatsNewProvider.notifier).setHighlightsOn(v),
        ),
      ],
    );
  }
}
