import 'package:flutter/material.dart';

import '../data/quotes.dart';
import '../models/legend.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../utils/external_links.dart';
import '../widgets/gallery_strip.dart';
import '../widgets/legend_card.dart';
import '../widgets/quote_card.dart';
import '../widgets/settle_in.dart';

/// One legend's story: photo hero, facts, sections with pull quotes, takeaways.
class LegendStoryPage extends StatefulWidget {
  const LegendStoryPage({required this.legend, super.key});

  final Legend legend;

  @override
  State<LegendStoryPage> createState() => _LegendStoryPageState();
}

class _LegendStoryPageState extends State<LegendStoryPage> {
  static const double _heroHeight = 360;

  final ScrollController _scroll = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final collapsed = _scroll.offset > _heroHeight - kToolbarHeight;
    if (collapsed != _isCollapsed) {
      setState(() => _isCollapsed = collapsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocks = _storyBlocks(widget.legend);
    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: _heroHeight,
            backgroundColor: _isCollapsed ? AppTheme.ink : Colors.transparent,
            surfaceTintColor: Colors.transparent,
            title: AnimatedOpacity(
              opacity: _isCollapsed ? 1 : 0,
              duration: AppMotion.of(context, AppMotion.fast),
              child: Text(
                widget.legend.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.title,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: LegendPhoto(legend: widget.legend),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceLg),
            sliver: SliverList.list(
              children: [
                for (var index = 0; index < blocks.length; index++)
                  SettleIn(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spaceLg),
                      child: blocks[index],
                    ),
                  ),
                const SizedBox(height: AppTheme.spaceXxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> _storyBlocks(Legend legend) {
  final blocks = <Widget>[
    _inColumn(_StoryHeader(legend: legend)),
    _inColumn(_FactsStrip(legend: legend)),
  ];
  final quoteSections = _quoteSections(legend.quoteIndexes.length);
  for (var index = 0; index < legend.sections.length; index++) {
    blocks.add(_inColumn(_StorySectionBlock(section: legend.sections[index])));
    final slot = quoteSections.indexOf(index + 1);
    if (slot >= 0) {
      blocks.add(
        _inColumn(QuoteCard(quote: quotes[legend.quoteIndexes[slot]])),
      );
    }
  }
  if (legend.gallery.isNotEmpty) {
    blocks.add(_Gallery(photos: legend.gallery));
  }
  blocks.add(_inColumn(_Takeaways(takeaways: legend.takeaways)));
  blocks.add(_inColumn(_PhotoCreditBlock(credit: legend.credit)));
  return blocks;
}

/// Holds a block to the text column; the gallery is the one block that bleeds.
Widget _inColumn(Widget child) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
  child: child,
);

/// Which section each pull quote follows, so the quotes break up the reading.
List<int> _quoteSections(int quoteCount) => switch (quoteCount) {
  1 => const [2],
  2 => const [1, 3],
  _ => const [1, 3, 4].take(quoteCount).toList(),
};

class _Gallery extends StatelessWidget {
  const _Gallery({required this.photos});

  final List<GalleryPhoto> photos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inColumn(const Text('FROM THE ARCHIVE', style: AppTheme.label)),
        const SizedBox(height: AppTheme.spaceMd),
        GalleryStrip(photos: photos),
      ],
    );
  }
}

class _StoryHeader extends StatelessWidget {
  const _StoryHeader({required this.legend});

  final Legend legend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${legend.nickname.toUpperCase()} · ${legend.years}',
          style: AppTheme.label,
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Text(legend.name, style: AppTheme.displayLarge),
        const SizedBox(height: AppTheme.spaceMd),
        Text(legend.hook, style: AppTheme.bodyMuted),
      ],
    );
  }
}

class _FactsStrip extends StatelessWidget {
  const _FactsStrip({required this.legend});

  final Legend legend;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spaceSm,
      runSpacing: AppTheme.spaceSm,
      children: [
        _FactChip(label: 'COUNTRY', value: legend.country),
        _FactChip(label: 'DIVISION', value: legend.division),
        _FactChip(label: 'RECORD', value: legend.record),
      ],
    );
  }
}

/// One fact of the strip, wide enough for its own value and no wider.
class _FactChip extends StatelessWidget {
  const _FactChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.label),
          const SizedBox(height: AppTheme.spaceSm),
          Text(value, style: AppTheme.body),
        ],
      ),
    );
  }
}

class _StorySectionBlock extends StatelessWidget {
  const _StorySectionBlock({required this.section});

  static const double _readingHeight = 1.5;

  final StorySection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.heading, style: AppTheme.displaySmall),
        const SizedBox(height: AppTheme.spaceMd),
        Text(
          section.body,
          style: AppTheme.body.copyWith(height: _readingHeight),
        ),
      ],
    );
  }
}

class _Takeaways extends StatelessWidget {
  const _Takeaways({required this.takeaways});

  static const double _numberWidth = 40;

  final List<String> takeaways;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WHAT TO TAKE FROM IT', style: AppTheme.label),
        const SizedBox(height: AppTheme.spaceMd),
        for (var index = 0; index < takeaways.length; index++) ...[
          if (index > 0) const SizedBox(height: AppTheme.spaceMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _numberWidth,
                child: Text(
                  '${index + 1}',
                  style: AppTheme.displaySmall.copyWith(color: AppTheme.accent),
                ),
              ),
              Expanded(child: Text(takeaways[index], style: AppTheme.body)),
            ],
          ),
        ],
      ],
    );
  }
}

class _PhotoCreditBlock extends StatelessWidget {
  const _PhotoCreditBlock({required this.credit});

  final PhotoCredit credit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PHOTO', style: AppTheme.label),
        const SizedBox(height: AppTheme.spaceSm),
        GestureDetector(
          onTap: () {
            openExternal(credit.source);
          },
          child: Text(
            '${credit.author}. ${credit.license}. Wikimedia Commons.',
            style: AppTheme.caption,
          ),
        ),
      ],
    );
  }
}
