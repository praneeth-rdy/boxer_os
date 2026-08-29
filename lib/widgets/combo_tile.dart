import 'package:flutter/material.dart';

import '../models/combination.dart';
import '../theme/app_theme.dart';

/// One combination as a tappable row with a bookmark toggle.
class ComboTile extends StatelessWidget {
  const ComboTile({
    required this.combination,
    required this.isSaved,
    required this.onTap,
    required this.onToggleSaved,
    super.key,
  });

  final Combination combination;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;

  static const double _minHeight = 72;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final subtitle = combination.isFromLibrary
        ? combination.name
        : combination.spoken;
    final details = [
      for (final tag in combination.tags) tag.label,
      combination.difficulty.label,
    ].join(' · ');

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              AppTheme.spaceSm,
              AppTheme.spaceMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(combination.notation, style: AppTheme.displaySmall),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.spaceXs),
                        Text(subtitle, style: AppTheme.body),
                      ],
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(details, style: AppTheme.caption),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                IconButton(
                  onPressed: onToggleSaved,
                  iconSize: _iconSize,
                  icon: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isSaved ? AppTheme.accent : AppTheme.chalkMuted,
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
