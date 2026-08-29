import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

/// Visual weight of a [PillButton].
enum PillStyle { filled, outlined, ghost }

/// Full-width pill-shaped action with an uppercase label.
class PillButton extends StatefulWidget {
  const PillButton({
    required this.label,
    required this.onPressed,
    this.style = PillStyle.filled,
    this.height = AppTheme.minTapTarget,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillStyle style;
  final double height;
  final IconData? icon;

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  static const double _disabledAlpha = 0.4;
  static const double _wideLabelHeight = 64;
  static const double _iconSize = 20;
  static const double _pressedScale = 0.97;

  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final foreground = switch (widget.style) {
      PillStyle.filled => AppTheme.onAccent,
      PillStyle.outlined => AppTheme.chalk,
      PillStyle.ghost => AppTheme.chalkMuted,
    };
    final background = widget.style == PillStyle.filled
        ? AppTheme.accent
        : Colors.transparent;
    final textStyle = AppTheme.bodyStrong.copyWith(
      color: isEnabled
          ? foreground
          : foreground.withValues(alpha: _disabledAlpha),
      letterSpacing: widget.height >= _wideLabelHeight ? 1 : null,
    );
    final iconData = widget.icon;

    return AnimatedScale(
      scale: _isPressed ? _pressedScale : 1,
      duration: AppMotion.of(context, AppMotion.fast),
      curve: AppMotion.change,
      child: Material(
        color: isEnabled
            ? background
            : background.withValues(alpha: _disabledAlpha),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          side: widget.style == PillStyle.outlined
              ? const BorderSide(color: AppTheme.line, width: AppTheme.hairline)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: widget.onPressed,
          onHighlightChanged: (isHighlighted) =>
              setState(() => _isPressed = isHighlighted),
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconData != null) ...[
                  Icon(iconData, size: _iconSize, color: textStyle.color),
                  const SizedBox(width: AppTheme.spaceSm),
                ],
                Flexible(
                  child: Text(
                    widget.label.toUpperCase(),
                    style: textStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
