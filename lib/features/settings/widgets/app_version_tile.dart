import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/app_version_provider.dart';

/// "App version" row for the About section of Settings.
class AppVersionTile extends ConsumerWidget {
  const AppVersionTile({super.key, this.leading, this.contentPadding});

  final Widget? leading;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = ref
        .watch(appVersionProvider)
        .when(
          data: (version) => version,
          loading: () => 'Loading…',
          error: (_, _) => 'Unavailable',
        );
    return ListTile(
      contentPadding: contentPadding,
      leading: leading,
      title: const Text('App version'),
      subtitle: Text(subtitle),
    );
  }
}
