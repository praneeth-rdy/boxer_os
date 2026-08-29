import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

/// The live cue, or the round focus while no cue has fired.
class CueBanner extends StatelessWidget {
  const CueBanner({required this.cue, required this.fallback, super.key});

  final String? cue;
  final String fallback;

  static const double _rise = 16;

  @override
  Widget build(BuildContext context) {
    final text = cue ?? fallback;
    return AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.base),
      transitionBuilder: _riseIn,
      child: Text(
        text,
        key: ValueKey<String>(text),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: cue == null ? AppTheme.bodyMuted : AppTheme.displayMedium,
      ),
    );
  }

  /// The arriving cue rises as it fades in; the one it replaces only fades.
  static Widget _riseIn(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final isLeaving = animation.status == AnimationStatus.reverse;
        final risen = AppMotion.enter.transform(animation.value);
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, isLeaving ? 0 : (1 - risen) * _rise),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
