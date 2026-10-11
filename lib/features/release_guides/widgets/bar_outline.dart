import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/features/release_guides/release_guide_provider.dart';

/// Outlines a bottom bar item after the guide's "Show me" (#145): two
/// pulses, or a still outline with Reduce Motion, then it goes.
class BarOutline extends ConsumerStatefulWidget {
  const BarOutline({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  ConsumerState<BarOutline> createState() => _BarOutlineState();
}

class _BarOutlineState extends ConsumerState<BarOutline>
    with SingleTickerProviderStateMixin {
  static const _pulse = Duration(milliseconds: 700);
  static const _still = Duration(seconds: 3);

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: _pulse,
  );
  bool _running = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _start(bool reduceMotion) async {
    _running = true;
    if (reduceMotion) {
      // Drawn still (the value is ignored); the controller only times it.
      await _c.animateTo(1, duration: _still);
    } else {
      for (var i = 0; i < 2; i++) {
        await _c.forward(from: 0);
        await _c.reverse();
      }
    }
    if (!mounted) return;
    _running = false;
    if (ref.read(barOutlineProvider) == widget.id) {
      ref.read(barOutlineProvider.notifier).state = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final on = ref.watch(barOutlineProvider) == widget.id;
    if (!on) return widget.child;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!_running) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_running) _start(reduceMotion);
      });
    }
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => DecoratedBox(
        key: ValueKey('bar-outline-${widget.id}'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.primary,
            width: reduceMotion ? 3 : 2 + 2 * _c.value,
          ),
        ),
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: widget.child,
      ),
    );
  }
}
