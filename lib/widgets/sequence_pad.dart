import 'package:flutter/material.dart';

import '../models/reaction_direction.dart';
import '../theme/app_theme.dart';

/// The four direction edges, with the sequence to reproduce over them.
///
/// With an empty [sequence] it is the plain direction pad and shows [centre].
class SequencePad extends StatelessWidget {
  const SequencePad({
    required this.onDirection,
    required this.centre,
    this.sequence = const [],
    this.isShowingSequence = false,
    this.entered = 0,
    super.key,
  });

  final void Function(ReactionDirection) onDirection;

  /// What the middle shows while no sequence is live.
  final Widget centre;

  /// The arrows of the live trial, in the order they must be tapped back.
  final List<ReactionDirection> sequence;

  /// Whether the arrows are still on show, rather than being tapped back.
  final bool isShowingSequence;

  /// How many arrows have been tapped back correctly.
  final int entered;

  static const int _edgeFlex = 1;
  static const int _middleFlex = 2;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            Expanded(
              flex: _edgeFlex,
              child: _SequenceZone(
                direction: ReactionDirection.up,
                onTap: onDirection,
              ),
            ),
            Expanded(
              flex: _middleFlex,
              child: Row(
                children: [
                  Expanded(
                    child: _SequenceZone(
                      direction: ReactionDirection.left,
                      onTap: onDirection,
                    ),
                  ),
                  Expanded(
                    child: _SequenceZone(
                      direction: ReactionDirection.right,
                      onTap: onDirection,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: _edgeFlex,
              child: _SequenceZone(
                direction: ReactionDirection.down,
                onTap: onDirection,
              ),
            ),
          ],
        ),
        IgnorePointer(child: Center(child: _middle())),
      ],
    );
  }

  Widget _middle() {
    if (sequence.isEmpty) {
      return centre;
    }
    return isShowingSequence
        ? _SequenceArrows(sequence: sequence)
        : _SequenceProgress(length: sequence.length, entered: entered);
  }
}

/// The arrows of the trial, shown together before the clock starts.
class _SequenceArrows extends StatelessWidget {
  const _SequenceArrows({required this.sequence});

  final List<ReactionDirection> sequence;

  static const double _arrowSize = 56;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final direction in sequence)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXs),
              child: Icon(
                direction.icon,
                size: _arrowSize,
                color: AppTheme.chalk,
              ),
            ),
        ],
      ),
    );
  }
}

/// One dot per arrow, filled as each is tapped back correctly.
class _SequenceProgress extends StatelessWidget {
  const _SequenceProgress({required this.length, required this.entered});

  final int length;
  final int entered;

  static const double _dotSize = 20;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < length; index++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
            child: SizedBox.square(
              dimension: _dotSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < entered ? AppTheme.accent : Colors.transparent,
                  border: Border.all(
                    color: index < entered
                        ? AppTheme.accent
                        : AppTheme.chalkFaint,
                    width: AppTheme.hairline,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// One outlined hit zone; taps register on press, not on release.
class _SequenceZone extends StatelessWidget {
  const _SequenceZone({required this.direction, required this.onTap});

  final ReactionDirection direction;
  final void Function(ReactionDirection) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => onTap(direction),
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
