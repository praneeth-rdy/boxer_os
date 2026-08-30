import 'package:flutter/material.dart';

import '../data/boxing_calendar.dart';
import '../data/legends.dart';
import '../models/legend.dart';
import '../theme/app_theme.dart';
import '../widgets/event_card.dart';
import '../widgets/event_sheet.dart';
import '../widgets/event_tile.dart';
import '../widgets/legend_card.dart';
import '../widgets/section_header.dart';
import '../widgets/settle_in.dart';
import '../widgets/skill_card.dart';
import 'calendar_page.dart';
import 'facts_page.dart';
import 'legend_story_page.dart';
import 'legends_page.dart';
import 'quotes_page.dart';

const int _nextEventCount = 3;

/// The reading tab: the legends, the boxing calendar, the quotes and the facts.
class CornerPage extends StatelessWidget {
  const CornerPage({this.clock = DateTime.now, super.key});

  /// Injectable so a test can render the page on any date.
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) {
    final now = clock();
    final legend = legendOfTheWeek(now);
    final today = eventsOn(now);
    final next = nextEvents(now, count: _nextEventCount);
    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          children: [
            const SettleIn(
              child: SectionHeader(
                title: 'Corner',
                eyebrow: 'STORIES, DAYS, WORDS',
              ),
            ),
            const SettleIn(
              index: 1,
              child: Text('LEGEND OF THE WEEK', style: AppTheme.label),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            SettleIn(
              index: 1,
              child: LegendCard(
                legend: legend,
                featured: true,
                onTap: () => _openStory(context, legend),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            SettleIn(
              index: 1,
              child: SkillCard(
                title: 'All legends',
                description: 'Twelve fighters and what they teach.',
                icon: Icons.auto_stories_rounded,
                onTap: () => _push(context, const LegendsPage()),
              ),
            ),
            const SizedBox(height: AppTheme.spaceXl),
            if (today.isNotEmpty) ...[
              const SettleIn(
                index: 2,
                child: Text('TODAY IN BOXING', style: AppTheme.label),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              SettleIn(index: 2, child: EventCard(event: today.first)),
              const SizedBox(height: AppTheme.spaceXl),
            ],
            const SettleIn(
              index: 3,
              child: Text('NEXT UP', style: AppTheme.label),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            for (final event in next)
              SettleIn(
                index: 3,
                child: EventTile(
                  event: event,
                  onTap: () => showEventSheet(context, event),
                ),
              ),
            const SizedBox(height: AppTheme.spaceMd),
            SettleIn(
              index: 3,
              child: SkillCard(
                title: 'Calendar',
                description: 'Anniversaries, birthdays and boxing days.',
                icon: Icons.event_rounded,
                onTap: () => _push(context, const CalendarPage()),
              ),
            ),
            const SizedBox(height: AppTheme.spaceXl),
            const SettleIn(
              index: 4,
              child: Text('WORDS', style: AppTheme.label),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            SettleIn(
              index: 4,
              child: SkillCard(
                title: 'Quotes',
                description: '81 lines from boxers and other athletes.',
                icon: Icons.format_quote_rounded,
                onTap: () => _push(context, const QuotesPage()),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            SettleIn(
              index: 4,
              child: SkillCard(
                title: 'Did you know',
                description: '40 facts and records from the ring.',
                icon: Icons.lightbulb_outline_rounded,
                onTap: () => _push(context, const FactsPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openStory(BuildContext context, Legend legend) {
    _push(context, LegendStoryPage(legend: legend));
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}
