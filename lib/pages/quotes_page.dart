import 'package:flutter/material.dart';

import '../data/quotes.dart';
import '../models/quote.dart';
import '../theme/app_theme.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/quote_card.dart';
import '../widgets/section_header.dart';
import '../widgets/settle_in.dart';

const String _boxing = 'Boxing';

/// The whole quote library, filtered by the sport it comes from.
class QuotesPage extends StatefulWidget {
  const QuotesPage({super.key});

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  String? _sport;

  @override
  Widget build(BuildContext context) {
    final shown = _sport == null
        ? quotes
        : quotes.where((quote) => _sportOf(quote) == _sport).toList();
    return Scaffold(
      backgroundColor: AppTheme.ink,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        itemCount: shown.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Header(
              sport: _sport,
              onSelected: (sport) => setState(() => _sport = sport),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
            child: QuoteCard(quote: shown[index - 1], compact: true),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.sport, required this.onSelected});

  final String? sport;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SettleIn(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quotes', eyebrow: 'WORDS TO TRAIN BY'),
          FilterChipRow<String>(
            values: _sports,
            selected: sport,
            label: (value) => value,
            onSelected: onSelected,
          ),
          const SizedBox(height: AppTheme.spaceLg),
        ],
      ),
    );
  }
}

/// The sport a quote is filed under; a trainer's line counts as boxing.
String _sportOf(Quote quote) =>
    quote.sport.startsWith(_boxing) ? _boxing : quote.sport;

/// Boxing first, then every other sport alphabetically.
List<String> _sportFilters() {
  final others = {for (final quote in quotes) _sportOf(quote)}..remove(_boxing);
  return [_boxing, ...others.toList()..sort()];
}

final List<String> _sports = _sportFilters();
