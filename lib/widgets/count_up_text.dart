import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// A number that counts to [value] when it changes, on tabular figures so the
/// text does not jitter while it runs.
class CountUpText extends StatelessWidget {
  const CountUpText({
    required this.value,
    required this.style,
    this.suffix = '',
    super.key,
  });

  final int value;
  final TextStyle style;

  /// Text held after the number, as in "/6" or " day streak".
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(end: value),
      duration: AppMotion.of(context, AppMotion.slow),
      curve: AppMotion.change,
      builder: (context, shown, _) => Text(
        '$shown$suffix',
        maxLines: 1,
        style: style.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
