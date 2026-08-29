import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One shortcut on Home: an icon over its label, as a square raised card.
class QuickAction extends StatelessWidget {
  const QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
    super.key,
  });

  static const double _minHeight = 88;
  static const double _iconSize = 28;

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceRaised,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: _iconSize, color: AppTheme.chalk),
                const SizedBox(height: AppTheme.spaceSm),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.label,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
