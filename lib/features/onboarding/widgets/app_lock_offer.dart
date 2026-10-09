import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Onboarding privacy step offer for the app lock (#100).
// Spec: docs/features/app-lock.feature

/// "Lock Health Flare" switch on the onboarding privacy step. Renders
/// nothing on platforms without the lock.
class AppLockOffer extends ConsumerWidget {
  const AppLockOffer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const SizedBox.shrink();
}
