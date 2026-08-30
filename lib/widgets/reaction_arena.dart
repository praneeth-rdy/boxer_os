import 'package:flutter/material.dart';

import '../models/defense_zone.dart';
import '../models/reaction_colour.dart';
import '../models/reaction_direction.dart';
import '../models/reaction_mode.dart';
import '../providers/reaction_provider.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import 'colour_grid.dart';
import 'defense_grid.dart';
import 'sequence_pad.dart';

/// Everything a tap on the arena can answer with.
typedef ReactionTap =
    void Function({
      ReactionDirection? direction,
      DefenseZone? defense,
      Offset? at,
      ReactionColour? colour,
    });

/// The full-bleed hit area of the reaction trainer: stimulus, zones and feedback.
class ReactionArena extends StatelessWidget {
  const ReactionArena({required this.reaction, required this.onTap, super.key});

  final ReactionProvider reaction;
  final ReactionTap onTap;

  static const double _arrowSize = 200;
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
        return SequencePad(
          onDirection: (direction) => onTap(direction: direction),
          centre: content,
        );
      case ReactionMode.sequence:
        return SequencePad(
          onDirection: (direction) => onTap(direction: direction),
          centre: content,
          sequence: reaction.phase == ReactionPhase.stimulus
              ? reaction.sequence
              : const [],
          isShowingSequence: reaction.isShowingSequence,
          entered: reaction.entered,
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
      case ReactionMode.colour:
        if (!_showsGrid) {
          return _tapCatcher(content);
        }
        return ColourGrid(
          onColour: (colour) => onTap(colour: colour),
          centre: content,
        );
      case ReactionMode.peripheral:
        return _PeripheralField(
          dot: reaction.dotPosition,
          onTapAt: (at) => onTap(at: at),
          child: content,
        );
      case ReactionMode.tap:
      case ReactionMode.goNoGo:
      case ReactionMode.sound:
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
      // Sound trials give nothing away, so the screen never lights up.
      return reaction.isSoundMode ? AppTheme.ink : AppTheme.surface;
    }
    return switch (reaction.mode) {
      ReactionMode.tap => AppTheme.accent,
      ReactionMode.goNoGo => reaction.isGo ? AppTheme.rest : AppTheme.accent,
      ReactionMode.sound => AppTheme.ink,
      ReactionMode.direction ||
      ReactionMode.defense ||
      ReactionMode.peripheral ||
      ReactionMode.colour ||
      ReactionMode.sequence => AppTheme.surface,
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
        if (reaction.isSoundMode) {
          return const _PulseRing();
        }
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
    switch (reaction.mode) {
      case ReactionMode.direction:
        final target = reaction.direction;
        return target == null
            ? const SizedBox.shrink()
            : Icon(target.icon, size: _arrowSize, color: AppTheme.chalk);
      case ReactionMode.defense:
        final punch = reaction.incomingPunch;
        return punch == null
            ? const SizedBox.shrink()
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  punch.label,
                  style: AppTheme.displayHero,
                  maxLines: 1,
                ),
              );
      case ReactionMode.colour:
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            reaction.wordColour.label,
            style: AppTheme.displayHero.copyWith(
              color: reaction.inkColour.swatch,
            ),
            maxLines: 1,
          ),
        );
      case ReactionMode.tap:
      case ReactionMode.goNoGo:
        return Text(
          reaction.isGo ? 'GO' : 'HOLD',
          style: AppTheme.displayHero.copyWith(color: AppTheme.onAccent),
        );
      case ReactionMode.peripheral:
      case ReactionMode.sequence:
      case ReactionMode.sound:
        return const SizedBox.shrink();
    }
  }
}

/// The peripheral target: the whole arena answers, the dot is what to find.
class _PeripheralField extends StatelessWidget {
  const _PeripheralField({
    required this.dot,
    required this.onTapAt,
    required this.child,
  });

  /// Where the dot sits as fractions of the arena, null between trials.
  final Offset? dot;
  final void Function(Offset) onTapAt;
  final Widget child;

  static const double _dotSize = 44;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final target = dot;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => onTapAt(
            Offset(
              details.localPosition.dx / constraints.maxWidth,
              details.localPosition.dy / constraints.maxHeight,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(child: child),
              if (target != null)
                Positioned(
                  left: target.dx * constraints.maxWidth - _dotSize / 2,
                  top: target.dy * constraints.maxHeight - _dotSize / 2,
                  child: const SizedBox.square(
                    dimension: _dotSize,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// A ring breathing through the wait, so a dark sound trial still reads as live.
class _PulseRing extends StatefulWidget {
  const _PulseRing();

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  static const double _size = 64;
  static const double _minScale = 0.8;
  static const Duration _period = Duration(milliseconds: 900);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _period,
    value: 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.stop();
      return;
    }
    if (!_controller.isAnimating) {
      _controller.repeat(min: _minScale, max: 1, reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: SizedBox.square(
        dimension: _size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.chalkFaint,
              width: AppTheme.hairline,
            ),
          ),
        ),
      ),
    );
  }
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
