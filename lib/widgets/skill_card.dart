import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One skill area on the Skills hub, dimmed and marked SOON when [onTap] is null.
class SkillCard extends StatelessWidget {
  const SkillCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  static const double _minHeight = 96;
  static const double _iconSize = 28;
  static const double _soonAlpha = 0.5;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Row(
              children: [
                Icon(icon, size: _iconSize, color: AppTheme.accent),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: AppTheme.titleLarge),
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(description, style: AppTheme.bodyMuted),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                if (onTap == null)
                  const Text('SOON', style: AppTheme.label)
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.chalkFaint,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (onTap != null) {
      return card;
    }
    return Opacity(opacity: _soonAlpha, child: card);
  }
}
