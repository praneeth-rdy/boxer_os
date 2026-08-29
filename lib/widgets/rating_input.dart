import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// How the session felt, one to five, as a row of big round targets.
class RatingInput extends StatelessWidget {
  const RatingInput({required this.value, required this.onChanged, super.key});

  static const int _maxRating = 5;
  static const double _gap = AppTheme.spaceSm;

  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value;
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final diameter = min(
              AppTheme.sessionTapTarget,
              (constraints.maxWidth - _gap * (_maxRating - 1)) / _maxRating,
            );
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var score = 1; score <= _maxRating; score++)
                  _RatingTarget(
                    score: score,
                    diameter: diameter,
                    isFilled: selected != null && score <= selected,
                    onTap: () => onChanged(score),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Text(_labelFor(selected), style: AppTheme.caption),
      ],
    );
  }

  static String _labelFor(int? score) => switch (score) {
    1 => 'Rough',
    2 => 'Flat',
    3 => 'Solid',
    4 => 'Sharp',
    5 => 'On fire',
    _ => 'How did it go?',
  };
}

class _RatingTarget extends StatelessWidget {
  const _RatingTarget({
    required this.score,
    required this.diameter,
    required this.isFilled,
    required this.onTap,
  });

  final int score;
  final double diameter;
  final bool isFilled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isFilled ? AppTheme.accent : AppTheme.surfaceRaised,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Center(
            child: Text(
              '$score',
              style: AppTheme.displaySmall.copyWith(
                color: isFilled ? AppTheme.onAccent : AppTheme.chalk,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
