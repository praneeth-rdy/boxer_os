import 'package:flutter/material.dart';

import '../models/milestone.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import 'settle_in.dart';

/// One milestone as a circular badge, dimmed while it is unearned.
class MilestoneBadge extends StatelessWidget {
  const MilestoneBadge({required this.milestone, this.index = 0, super.key});

  static const double _width = 96;
  static const double _circleSize = 56;
  static const double _iconSize = 26;
  static const double _achievedTintAlpha = 0.18;
  static const double _unachievedAlpha = 0.6;
  static const double _earnedScaleFrom = 0.9;

  final Milestone milestone;

  /// Place in the row, so earned badges arrive one after another.
  final int index;

  @override
  Widget build(BuildContext context) {
    final achieved = milestone.achieved;
    final badge = SizedBox(
      width: _width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _circleSize,
            height: _circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: achieved
                  ? AppTheme.accent.withValues(alpha: _achievedTintAlpha)
                  : AppTheme.surfaceRaised,
            ),
            child: Icon(
              milestone.icon,
              size: _iconSize,
              color: achieved ? AppTheme.accent : AppTheme.chalkFaint,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            milestone.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.caption,
          ),
        ],
      ),
    );
    if (!achieved) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: _unachievedAlpha),
        duration: AppMotion.of(context, AppMotion.base),
        curve: AppMotion.change,
        builder: (context, opacity, child) =>
            Opacity(opacity: opacity, child: child),
        child: badge,
      );
    }
    return SettleIn(
      index: index,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: _earnedScaleFrom, end: 1),
        duration: AppMotion.of(context, AppMotion.base),
        curve: AppMotion.enter,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: badge,
      ),
    );
  }
}
