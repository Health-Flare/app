import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/app_lock_provider.dart';

// Shared by Settings > Privacy and the onboarding privacy step (#100, #101).
// Spec: docs/features/app-lock.feature

/// What the lock does, and what it doesn't. Shown wherever it can be turned
/// on. The lock is a screen in front of the app, not encryption.
const appLockDescription =
    'Health Flare will ask for your face, fingerprint or phone passcode '
    "before showing your records. It doesn't encrypt the records stored on "
    'your phone.';

const appLockNoScreenLockMessage =
    "Set a screen lock in your phone's settings first, then come back to "
    'turn this on.';

/// Turns the lock on, says why when it can't, and then offers to hide the
/// app in the app switcher too (never switching that on by itself).
Future<void> turnOnAppLock(BuildContext context, WidgetRef ref) async {
  final lock = ref.read(appLockProvider.notifier);
  final result = await lock.enable();
  if (!context.mounted) return;
  switch (result) {
    case LockChange.cancelled:
      return;
    case LockChange.noScreenLock:
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(appLockNoScreenLockMessage)));
      return;
    case LockChange.done:
      break;
  }
  if (ref.read(appLockProvider).settings.hideInAppSwitcher) return;

  final hide = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Also hide Health Flare in the app switcher?'),
      content: const Text(
        'The app switcher shows the last screen you were on. Hiding the app '
        'shows a plain screen there instead. You can change this in '
        'Settings > Privacy.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Hide it'),
        ),
      ],
    ),
  );
  if (hide == true) await lock.setHideInAppSwitcher(true);
}
