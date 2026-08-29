import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Labelled numeric value with round decrement and increment buttons.
class StepperRow extends StatelessWidget {
  const StepperRow({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label.toUpperCase(), style: AppTheme.label)),
        Text(value, style: AppTheme.displayMedium),
        const SizedBox(width: AppTheme.spaceMd),
        _StepperButton(icon: Icons.remove_rounded, onPressed: onDecrement),
        const SizedBox(width: AppTheme.spaceSm),
        _StepperButton(icon: Icons.add_rounded, onPressed: onIncrement),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceRaised,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: AppTheme.minTapTarget,
          width: AppTheme.minTapTarget,
          child: Icon(
            icon,
            size: _iconSize,
            color: onPressed == null ? AppTheme.chalkFaint : AppTheme.chalk,
          ),
        ),
      ),
    );
  }
}
