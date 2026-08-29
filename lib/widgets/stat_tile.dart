import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'count_up_text.dart';

/// One number with its uppercase label, as a surface card.
class StatTile extends StatelessWidget {
  /// A counted stat: the number runs up to [value], with [suffix] after it.
  const StatTile({
    required this.value,
    required this.label,
    this.suffix = '',
    this.accent,
    super.key,
  }) : text = null;

  /// A stat that is not a plain number, such as a rating that may be missing.
  const StatTile.text(
    String this.text, {
    required this.label,
    this.accent,
    super.key,
  }) : value = 0,
       suffix = '';

  final int value;
  final String suffix;
  final String? text;
  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final accentColor = accent;
    final style = accentColor == null
        ? AppTheme.displayMedium
        : AppTheme.displayMedium.copyWith(color: accentColor);
    final fixed = text;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: fixed == null
                ? CountUpText(value: value, suffix: suffix, style: style)
                : Text(fixed, maxLines: 1, style: style),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(label.toUpperCase(), style: AppTheme.label),
        ],
      ),
    );
  }
}
