import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Vertical bars scaled to the largest value, labelled underneath.
class BarChart extends StatelessWidget {
  const BarChart({
    required this.values,
    required this.labels,
    this.color = AppTheme.accent,
    this.height = _defaultHeight,
    super.key,
  });

  static const double _defaultHeight = 120;
  static const double _barGap = AppTheme.spaceXs;
  static const double _pastBarAlpha = 0.55;

  final List<int> values;

  /// Read by index; a missing label leaves the bar unlabelled.
  final List<String> labels;

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final peak = values.isEmpty ? 1 : max(values.reduce(max), 1);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < values.length; index++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: _barGap / 2),
                child: _Bar(
                  fraction: (values[index] / peak).clamp(0.0, 1.0),
                  label: index < labels.length ? labels[index] : '',
                  color: index == values.length - 1
                      ? color
                      : color.withValues(alpha: _pastBarAlpha),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.fraction,
    required this.label,
    required this.color,
  });

  static const BorderRadius _topCorners = BorderRadius.vertical(
    top: Radius.circular(AppTheme.radiusSm),
  );

  final double fraction;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppTheme.line,
              borderRadius: _topCorners,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: fraction,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: _topCorners,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.caption,
        ),
      ],
    );
  }
}
