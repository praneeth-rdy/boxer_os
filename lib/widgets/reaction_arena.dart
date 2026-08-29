import 'package:flutter/material.dart';

import '../models/defense_zone.dart';
import '../models/reaction_direction.dart';
import '../models/reaction_mode.dart';
import '../providers/reaction_provider.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import 'defense_grid.dart';

/// The full-bleed hit area of the reaction trainer: stimulus, zones and feedback.
class ReactionArena extends StatelessWidget {
  const ReactionArena({required this.reaction, required this.onTap, super.key});

  final ReactionProvider reaction;
  final void Function({ReactionDirection? direction, DefenseZone? defense})
  onTap;

  static const double _arrowSize = 200;
  static const int _edgeFlex = 1;
  static const int _middleFlex = 2;
  static const String _holdFeedback = 'Good hold';

  @override
  Widget build(BuildContext context) {
    final isStimulus = reaction.phase == ReactionPhase.stimulus;
    return AnimatedContainer(
      // The stimulus lands on its own frame: a fade in would be measured as
      // part of the boxer's reaction time.
      duration: isStimulus
          ? Duration.zero
          : AppMotion.of(context, AppMotion.fast),
      curve: AppMotion.change,
      color: _background,
      child: _body(),
    );
  }

  Widget _body() {
    final content = Center(child: _content());
    switch (reaction.mode) {
      case ReactionMode.direction:
        return Stack(
          fit: StackFit.expand,
          children: [
            _zones(),
            IgnorePointer(child: content),
          ],
        );
      case ReactionMode.defense:
        if (!_showsGrid) {
          return _tapCatcher(content);
        }
        return DefenseGrid(
          onZone: (zone) => onTap(defense: zone),
          isArmed: reaction.phase == ReactionPhase.stimulus,
          centre: content,
        );
      case ReactionMode.tap:
      case ReactionMode.goNoGo:
        return _tapCatcher(content);
    }
  }

  /// The grid stays up through the wait so the layout is learnt before the punch.
  bool get _showsGrid =>
      reaction.phase == ReactionPhase.waiting ||
      reaction.phase == ReactionPhase.stimulus;

  Widget _tapCatcher(Widget content) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTapDown: (_) => onTap(),
    child: IgnorePointer(child: content),
  );

  Color get _background {
    if (reaction.phase == ReactionPhase.feedback) {
      final feedback = reaction.feedback;
      final isGood =
          (feedback?.endsWith('ms') ?? false) || feedback == _holdFeedback;
      return isGood ? AppTheme.rest : AppTheme.warning;
    }
    if (reaction.phase != ReactionPhase.stimulus) {
      return AppTheme.surface;
    }
    return switch (reaction.mode) {
      ReactionMode.tap => AppTheme.accent,
      ReactionMode.goNoGo => reaction.isGo ? AppTheme.rest : AppTheme.accent,
      ReactionMode.direction || ReactionMode.defense => AppTheme.surface,
    };
  }

  Widget _content() {
    switch (reaction.phase) {
      case ReactionPhase.countdown:
        return Text(
          '${reaction.countdownSeconds}',
          style: AppTheme.displayHero,
        );
      case ReactionPhase.waiting:
        return Text(
          'WAIT',
          style: AppTheme.displaySmall.copyWith(color: AppTheme.chalkMuted),
        );
      case ReactionPhase.stimulus:
        return _PopIn(child: _stimulus());
      case ReactionPhase.feedback:
        return Text(
          reaction.feedback ?? '',
          style: AppTheme.displayLarge.copyWith(color: AppTheme.onAccent),
        );
      case ReactionPhase.idle:
      case ReactionPhase.complete:
        return const SizedBox.shrink();
    }
  }

  Widget _stimulus() {
    final target = reaction.direction;
    if (target != null) {
      return Icon(target.icon, size: _arrowSize, color: AppTheme.chalk);
    }
    final punch = reaction.incomingPunch;
    if (punch != null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(punch.label, style: AppTheme.displayHero, maxLines: 1),
      );
    }
    return Text(
      reaction.isGo ? 'GO' : 'HOLD',
      style: AppTheme.displayHero.copyWith(color: AppTheme.onAccent),
    );
  }

  Widget _zones() => Column(
    children: [
      Expanded(
        flex: _edgeFlex,
        child: _ReactionZone(direction: ReactionDirection.up, onTap: onTap),
      ),
      Expanded(
        flex: _middleFlex,
        child: Row(
          children: [
            Expanded(
              child: _ReactionZone(
                direction: ReactionDirection.left,
                onTap: onTap,
              ),
            ),
            Expanded(
              child: _ReactionZone(
                direction: ReactionDirection.right,
                onTap: onTap,
              ),
            ),
          ],
        ),
      ),
      Expanded(
        flex: _edgeFlex,
        child: _ReactionZone(direction: ReactionDirection.down, onTap: onTap),
      ),
    ],
  );
}

/// The stimulus glyph, scaled up as it appears.
class _PopIn extends StatelessWidget {
  const _PopIn({required this.child});

  static const double _scaleFrom = 0.8;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _scaleFrom, end: 1),
      duration: AppMotion.of(context, AppMotion.fast),
      curve: AppMotion.enter,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: child,
    );
  }
}

/// One outlined hit zone; taps register on press, not on release.
class _ReactionZone extends StatelessWidget {
  const _ReactionZone({required this.direction, required this.onTap});

  final ReactionDirection direction;
  final void Function({ReactionDirection? direction, DefenseZone? defense})
  onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => onTap(direction: direction),
      child: const DecoratedBox(
        decoration: BoxDecoration(
          border: Border.fromBorderSide(
            BorderSide(color: AppTheme.line, width: AppTheme.hairline),
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }
}
