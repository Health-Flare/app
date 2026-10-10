import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/app_lock_provider.dart';

// App lock gate (#100). Spec: docs/features/app-lock.feature

const appLockPausedMessage =
    'App lock is paused because your phone has no screen lock. '
    "Set one in your phone's settings to turn it back on.";

/// Sits above the router (in `MaterialApp.router`'s `builder`). While the
/// app is locked it shows the lock screen and keeps [child] in the tree but
/// offstage, so nothing underneath is painted, announced or tappable, and
/// half-finished work survives the lock.
///
/// A router redirect would also hide the screens, but it throws away the
/// navigation stack and any unsaved form with it.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Registered before the Router's back button dispatcher (this widget's
    // initState runs before its child's), so back reaches us first.
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(appLockProvider.select((s) => s.paused), (
      previous,
      paused,
    ) {
      if (paused && previous != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showPaused());
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showPaused() {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text(appLockPausedMessage),
        duration: Duration(seconds: 10),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lock = ref.read(appLockProvider.notifier);
    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        lock.backgrounded();
      case AppLifecycleState.resumed:
        lock.resumed();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  bool get _locked => ref.read(appLockProvider).locked;

  // Back on the lock screen leaves the app instead of popping a route
  // nobody can see.
  @override
  Future<bool> didPopRoute() async {
    if (!_locked) return false;
    await SystemNavigator.pop();
    return true;
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) => _locked;

  @override
  void handleCommitBackGesture() {
    if (_locked) SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(appLockProvider.select((s) => s.locked));
    return Stack(
      fit: StackFit.expand,
      children: [
        // Same position in the tree locked or not, so the app keeps its
        // state underneath.
        Offstage(
          offstage: locked,
          // ExcludeFocus drops the keyboard: typing must not reach a hidden
          // text field.
          child: ExcludeFocus(
            excluding: locked,
            child: TickerMode(enabled: !locked, child: widget.child),
          ),
        ),
        if (locked) const _LockScreen(),
      ],
    );
  }
}

/// App name and an Unlock button: nothing that says whose data is here.
class _LockScreen extends ConsumerStatefulWidget {
  const _LockScreen();

  @override
  ConsumerState<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<_LockScreen> {
  @override
  void initState() {
    super.initState();
    // Ask straight away; the button is for after a cancel.
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  void _unlock() {
    if (!mounted) return;
    ref.read(appLockProvider.notifier).unlock();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Material(
      color: cs.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Icon(Icons.lock_outline, size: 48, color: cs.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'Health Flare',
                  style: tt.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _unlock,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
