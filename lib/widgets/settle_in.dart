import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Fades and lifts its child into place once, staggered by [index].
class SettleIn extends StatelessWidget {
  const SettleIn({required this.child, this.index = 0, super.key});

  final Widget child;

  /// Place in the group: later items start later, up to [_maxSteps] of delay.
  final int index;

  static const int _maxSteps = 8;
  static const double _rise = 12;

  @override
  Widget build(BuildContext context) {
    final delay = AppMotion.stagger * index.clamp(0, _maxSteps);
    final total = delay + AppMotion.base;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: AppMotion.of(context, total),
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: AppMotion.enter,
      ),
      builder: (context, progress, child) => Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, (1 - progress) * _rise),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
