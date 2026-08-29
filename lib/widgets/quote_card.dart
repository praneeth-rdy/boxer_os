import 'package:flutter/material.dart';

import '../models/quote.dart';
import '../theme/app_theme.dart';

/// One quotation as a card, marked by an accent bar down its left edge.
class QuoteCard extends StatelessWidget {
  const QuoteCard({required this.quote, this.compact = false, super.key});

  static const double _barWidth = 3;

  final Quote quote;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              width: _barWidth,
              child: ColoredBox(color: AppTheme.accent),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quote.text,
                      style: compact ? AppTheme.title : AppTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            quote.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.bodyStrong,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceSm),
                        Flexible(
                          child: Text(
                            quote.sport,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.caption,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
