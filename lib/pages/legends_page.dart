import 'package:flutter/material.dart';

import '../data/legends.dart';
import '../models/legend.dart';
import '../theme/app_theme.dart';
import '../widgets/legend_card.dart';
import '../widgets/section_header.dart';
import '../widgets/settle_in.dart';
import 'legend_story_page.dart';

/// The twelve legends as photo covers, each opening its story.
class LegendsPage extends StatelessWidget {
  const LegendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        children: [
          const SettleIn(
            child: SectionHeader(
              title: 'Legends',
              eyebrow: 'STORIES FROM THE RING',
            ),
          ),
          const SettleIn(
            child: Text(
              'Twelve fighters, what they went through, and what it teaches.',
              style: AppTheme.bodyMuted,
            ),
          ),
          const SizedBox(height: AppTheme.spaceLg),
          for (var index = 0; index < legends.length; index++) ...[
            if (index > 0) const SizedBox(height: AppTheme.spaceMd),
            SettleIn(
              index: index + 1,
              child: LegendCard(
                legend: legends[index],
                onTap: () => _openStory(context, legends[index]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openStory(BuildContext context, Legend legend) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LegendStoryPage(legend: legend)),
    );
  }
}
