import 'dart:math' show pi, sin;

import 'package:flutter/material.dart';

import '../models/session_phase.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../utils/duration_format.dart';

/// Arm's-length countdown with a progress bar, coloured by session phase.
class RoundClock extends StatelessWidget {
  const RoundClock({
    required this.secondsLeft,
    required this.phaseSeconds,
    required this.phase,
    super.key,
  });

  final int secondsLeft;
  final int phaseSeconds;
  final SessionPhase phase;

  static const double _barHeight = 6;
  static const int _pulseFrom = 10;
  static const double _pulseDepth = 0.04;
  static const Duration _tick = Duration(seconds: 1);

  /// The colour a phase owns, shared with the session screen's phase word.
  static Color colorFor(SessionPhase phase) => switch (phase) {
    SessionPhase.prepare => AppTheme.warning,
    SessionPhase.work => AppTheme.accent,
    SessionPhase.rest => AppTheme.rest,
    SessionPhase.idle || SessionPhase.complete => AppTheme.chalk,
  };

  @override
  Widget build(BuildContext context) {
    final color = colorFor(phase);
    final progress = phaseSeconds <= 0
        ? 0.0
        : (1 - secondsLeft / phaseSeconds).clamp(0.0, 1.0);
    final isPulsing =
        phase == SessionPhase.work &&
        secondsLeft <= _pulseFrom &&
        !AppMotion.reduced(context);
    final clock = Text(formatClock(secondsLeft), maxLines: 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedDefaultTextStyle(
          duration: AppMotion.of(context, AppMotion.base),
          curve: AppMotion.change,
          style: AppTheme.displayHero.copyWith(color: color),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: isPulsing ? _pulse(clock) : clock,
          ),
        ),
        const SizedBox(height: AppTheme.spaceLg),
        SizedBox(
          height: _barHeight,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_barHeight / 2),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: AppTheme.line),
                AnimatedFractionallySizedBox(
                  duration: AppMotion.of(context, _tick),
                  curve: Curves.linear,
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: AnimatedContainer(
                    duration: AppMotion.of(context, AppMotion.base),
                    curve: AppMotion.change,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// One heartbeat per tick of the last ten seconds: 1.0 up to 1.04 and back.
  Widget _pulse(Widget clock) => TweenAnimationBuilder<double>(
    key: ValueKey<int>(secondsLeft),
    tween: Tween<double>(begin: 0, end: 1),
    duration: AppMotion.base,
    builder: (context, beat, child) =>
        Transform.scale(scale: 1 + _pulseDepth * sin(pi * beat), child: child),
    child: clock,
  );
}
