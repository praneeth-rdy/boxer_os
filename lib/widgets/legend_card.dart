import 'package:flutter/material.dart';

import '../models/legend.dart';
import '../theme/app_theme.dart';

/// One legend as a photo over a text block: where they fought, name and hook.
class LegendCard extends StatelessWidget {
  const LegendCard({
    required this.legend,
    required this.onTap,
    this.featured = false,
    super.key,
  });

  final Legend legend;
  final VoidCallback onTap;

  /// Whether this is the single highlighted card, wider and set in bigger type.
  final bool featured;

  static const double _listRatio = 4 / 3;
  static const double _featuredRatio = 16 / 10;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: featured ? _featuredRatio : _listRatio,
              child: LegendPhoto(legend: legend),
            ),
            Padding(
              padding: EdgeInsets.all(
                featured ? AppTheme.spaceLg : AppTheme.spaceMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${legend.country} · ${legend.division}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.label,
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      legend.name,
                      maxLines: 1,
                      style: featured
                          ? AppTheme.displayLarge
                          : AppTheme.displayMedium,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    legend.hook,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A legend's portrait, held to the top so the face stays in frame.
class LegendPhoto extends StatelessWidget {
  const LegendPhoto({required this.legend, super.key});

  final Legend legend;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      legend.imageAsset,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (context, error, stack) =>
          const ColoredBox(color: AppTheme.surfaceRaised),
    );
  }
}
