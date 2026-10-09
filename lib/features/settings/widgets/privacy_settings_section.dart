import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Settings > Privacy (#100, #101). Spec: docs/features/app-lock.feature

/// App lock, its re-lock time, and hide in app switcher. Renders nothing on
/// platforms without the lock (desktop, web).
class PrivacySettingsSection extends ConsumerWidget {
  const PrivacySettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const SizedBox.shrink();
}
