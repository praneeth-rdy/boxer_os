import 'package:flutter/material.dart';

import '../data/quotes.dart';
import '../models/quote.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

/// One quotation as a card, marked by an accent bar down its left edge.
class QuoteCard extends StatelessWidget {
  const QuoteCard({
    required this.quote,
    this.compact = false,
    this.cycles = false,
    super.key,
  });

  final Quote quote;
  final bool compact;

  /// Whether a tap swaps the quote for the next one in the rotation.
  final bool cycles;

  @override
  Widget build(BuildContext context) {
    if (cycles) {
      return _CyclingQuoteCard(first: quote, compact: compact);
    }
    return _QuoteBody(quote: quote, compact: compact);
  }
}

/// Holds the quote on show so a tap can move on to the next one.
class _CyclingQuoteCard extends StatefulWidget {
  const _CyclingQuoteCard({required this.first, required this.compact});

  final Quote first;
  final bool compact;

  @override
  State<_CyclingQuoteCard> createState() => _CyclingQuoteCardState();
}

class _CyclingQuoteCardState extends State<_CyclingQuoteCard> {
  late Quote _quote = widget.first;

  @override
  void didUpdateWidget(_CyclingQuoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.first != oldWidget.first) {
      _quote = widget.first;
    }
  }

  void _next() => setState(() => _quote = quoteAfter(_quote));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _next,
      behavior: HitTestBehavior.opaque,
      child: AnimatedSwitcher(
        duration: AppMotion.of(context, AppMotion.base),
        child: _QuoteBody(
          key: ValueKey<String>(_quote.text),
          quote: _quote,
          compact: widget.compact,
          showHint: true,
        ),
      ),
    );
  }
}

class _QuoteBody extends StatelessWidget {
  const _QuoteBody({
    required this.quote,
    required this.compact,
    this.showHint = false,
    super.key,
  });

  static const double _barWidth = 3;

  final Quote quote;
  final bool compact;
  final bool showHint;

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
                    if (showHint) ...[
                      const SizedBox(height: AppTheme.spaceSm),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text('Tap for another', style: AppTheme.caption),
                      ),
                    ],
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
