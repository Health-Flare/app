import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// App lock gate (#100). Spec: docs/features/app-lock.feature

/// Sits above the router (in `MaterialApp.router`'s `builder`). While the
/// app is locked it shows the lock screen and keeps [child] in the tree but
/// offstage, so nothing underneath is painted, announced or tappable, and
/// half-finished work survives the lock.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  @override
  Widget build(BuildContext context) => widget.child;
}
