import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import 'pill_button.dart';

/// A designed stand-in for a page with nothing to show yet, with a way forward.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.eyebrow,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.extra,
    super.key,
  });

  /// Roughly 60 characters of body text per line.
  static const double _bodyWidth = 420;
  static const double _actionHeight = 56;

  final String eyebrow;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _BreathingDot(),
            const SizedBox(width: AppTheme.spaceSm),
            Flexible(child: Text(eyebrow.toUpperCase(), style: AppTheme.label)),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Text(title, maxLines: 2, softWrap: true, style: AppTheme.displayMedium),
        const SizedBox(height: AppTheme.spaceMd),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _bodyWidth),
          child: Text(body, style: AppTheme.bodyMuted),
        ),
        if (label != null) ...[
          const SizedBox(height: AppTheme.spaceXl),
          PillButton(label: label, height: _actionHeight, onPressed: onAction),
        ],
        if (extra != null) ...[
          const SizedBox(height: AppTheme.spaceXl),
          ?extra,
        ],
      ],
    );
  }
}

/// The one thing on a bare page that moves, so it reads as waiting rather than broken.
class _BreathingDot extends StatefulWidget {
  const _BreathingDot();

  @override
  State<_BreathingDot> createState() => _BreathingDotState();
}

class _BreathingDotState extends State<_BreathingDot>
    with SingleTickerProviderStateMixin {
  static const double _size = 6;
  static const double _restingAlpha = 0.4;
  static const Duration _halfBreath = Duration(milliseconds: 800);

  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: _halfBreath,
  );
  late final Animation<double> _opacity = Tween<double>(
    begin: _restingAlpha,
    end: 1,
  ).animate(CurvedAnimation(parent: _breath, curve: AppMotion.change));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _breath
        ..stop()
        ..value = 1;
    } else if (!_breath.isAnimating) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: _size,
        height: _size,
        decoration: const BoxDecoration(
          color: AppTheme.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
