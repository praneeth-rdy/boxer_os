import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/boxing_facts.dart';
import '../data/quotes.dart';
import '../models/milestone.dart';
import '../models/reaction_format.dart';
import '../models/reaction_mode.dart';
import '../models/reaction_result.dart';
import '../models/session_record.dart';
import '../models/training_type.dart';
import '../providers/history_provider.dart';
import '../providers/reaction_provider.dart';
import '../providers/shell_provider.dart';
import '../theme/app_theme.dart';
import '../utils/milestones.dart';
import '../utils/training_stats.dart';
import '../widgets/bar_chart.dart';
import '../widgets/empty_state.dart';
import '../widgets/fact_card.dart';
import '../widgets/milestone_badge.dart';
import '../widgets/quote_card.dart';
import '../widgets/section_header.dart';
import '../widgets/settle_in.dart';
import '../widgets/skill_card.dart';
import '../widgets/stat_tile.dart';
import 'history_page.dart';

const List<String> _weekdayInitials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const int _trainTab = 1;

/// How many sessions with at least one completed round the history holds.
String _historyCaption(List<SessionRecord> sessions) {
  final logged = sessions
      .where((session) => session.roundsCompleted > 0)
      .length;
  if (logged == 0) {
    return 'Nothing logged yet';
  }
  return logged == 1 ? '1 session logged' : '$logged sessions logged';
}

/// The training numbers: this week, the last seven days, milestones and totals.
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: SafeArea(
        child: Consumer<HistoryProvider>(
          builder: (context, history, _) {
            final now = DateTime.now();
            final stats = TrainingStats.fromSessions(
              history.sessions,
              now: now,
            );
            final hasTraining = stats.totalSessions > 0;
            return ListView(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              children: [
                const SettleIn(
                  child: SectionHeader(
                    title: 'Progress',
                    eyebrow: 'ROUNDS, MINUTES, STREAK',
                  ),
                ),
                SettleIn(
                  index: 1,
                  child: SkillCard(
                    title: 'History',
                    description: _historyCaption(history.sessions),
                    icon: Icons.history_rounded,
                    onTap: () => _openHistory(context),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceLg),
                SettleIn(
                  index: 2,
                  child: hasTraining
                      ? _WeekSummary(
                          stats: stats,
                          reactions: history.reactions,
                          now: now,
                        )
                      : _EmptyProgress(now: now),
                ),
                const SizedBox(height: AppTheme.spaceXl),
                const SettleIn(
                  index: 3,
                  child: Text('MILESTONES', style: AppTheme.label),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                _MilestoneRow(
                  milestones: computeMilestones(stats, history.reactions),
                ),
                if (hasTraining) ...[
                  const SizedBox(height: AppTheme.spaceXl),
                  const SettleIn(
                    index: 4,
                    child: Text('ALL TIME', style: AppTheme.label),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  SettleIn(index: 4, child: _AllTimeRow(stats: stats)),
                  const SizedBox(height: AppTheme.spaceXl),
                  SettleIn(
                    index: 5,
                    child: FactCard(
                      fact: factFor(FactSurface.progress, now),
                      cycles: true,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const HistoryPage()));
  }
}

class _WeekSummary extends StatelessWidget {
  const _WeekSummary({
    required this.stats,
    required this.reactions,
    required this.now,
  });

  final TrainingStats stats;
  final List<ReactionResult> reactions;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: StatTile(value: stats.weekRounds, label: 'WEEK ROUNDS'),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            Expanded(
              child: StatTile(value: stats.weekMinutes, label: 'WEEK MINUTES'),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            Expanded(
              child: StatTile(
                value: stats.streakDays,
                label: 'DAY STREAK',
                accent: stats.streakDays > 0 ? AppTheme.rest : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceXl),
        const Text('LAST 7 DAYS', style: AppTheme.label),
        const SizedBox(height: AppTheme.spaceMd),
        BarChart(
          values: stats.minutesByDay,
          labels: _dayInitials(now, stats.minutesByDay.length),
        ),
        const SizedBox(height: AppTheme.spaceXl),
        const Text('THIS WEEK BY TYPE', style: AppTheme.label),
        const SizedBox(height: AppTheme.spaceMd),
        _TypeSplit(roundsByType: stats.weekRoundsByType),
        const SizedBox(height: AppTheme.spaceXl),
        const Text('REACTION', style: AppTheme.label),
        const SizedBox(height: AppTheme.spaceMd),
        _ReactionTrend(reactions: reactions),
      ],
    );
  }

  /// Initials for the chart window, oldest day first and today last.
  static List<String> _dayInitials(DateTime now, int days) => [
    for (var back = days - 1; back >= 0; back--)
      _weekdayInitials[DateTime(now.year, now.month, now.day - back).weekday -
          1],
  ];
}

class _TypeSplit extends StatelessWidget {
  const _TypeSplit({required this.roundsByType});

  final Map<TrainingType, int> roundsByType;

  @override
  Widget build(BuildContext context) {
    if (roundsByType.isEmpty) {
      return const Text('No rounds yet this week.', style: AppTheme.bodyMuted);
    }
    final entries = roundsByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final peak = max(entries.first.value, 1);
    return Column(
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          if (index > 0) const SizedBox(height: AppTheme.spaceMd),
          _TypeRow(
            label: entries[index].key.label,
            rounds: entries[index].value,
            fraction: (entries[index].value / peak).clamp(0.0, 1.0),
          ),
        ],
      ],
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow({
    required this.label,
    required this.rounds,
    required this.fraction,
  });

  static const double _labelWidth = 104;
  static const double _barHeight = 8;

  final String label;
  final int rounds;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final pill = BorderRadius.circular(AppTheme.radiusPill);
    return Row(
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.body,
          ),
        ),
        const SizedBox(width: AppTheme.spaceMd),
        Expanded(
          child: SizedBox(
            height: _barHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.line,
                borderRadius: pill,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fraction,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppTheme.rest,
                    borderRadius: pill,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spaceMd),
        Text('$rounds', style: AppTheme.bodyStrong),
      ],
    );
  }
}

class _ReactionTrend extends StatelessWidget {
  const _ReactionTrend({required this.reactions});

  static const int _trendLength = 10;

  final List<ReactionResult> reactions;

  @override
  Widget build(BuildContext context) {
    final bestByMode = _bestByMode();
    final bests = <int>[
      for (final result in reactions.take(_trendLength)) ?result.bestMillis,
    ].reversed.toList();
    if (bestByMode.isEmpty && bests.isEmpty) {
      return const Text(
        'Run the reaction trainer to see a trend.',
        style: AppTheme.bodyMuted,
      );
    }
    final endurance = _enduranceCaption();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bestByMode.isNotEmpty) ...[
          _ModeBests(bestByMode: bestByMode),
          const SizedBox(height: AppTheme.spaceLg),
        ],
        if (bests.isNotEmpty)
          BarChart(values: bests, labels: const [], color: AppTheme.warning),
        if (endurance != null) ...[
          const SizedBox(height: AppTheme.spaceSm),
          Text(endurance, style: AppTheme.caption),
        ],
      ],
    );
  }

  /// The best time each mode has managed over its last [_trendLength] results.
  Map<ReactionMode, int> _bestByMode() {
    final bests = <ReactionMode, int>{};
    final counted = <ReactionMode, int>{};
    for (final result in reactions) {
      final seen = counted[result.mode] ?? 0;
      if (seen >= _trendLength) {
        continue;
      }
      counted[result.mode] = seen + 1;
      final best = result.bestMillis;
      if (best == null) {
        continue;
      }
      final standing = bests[result.mode];
      bests[result.mode] = standing == null ? best : min(standing, best);
    }
    return bests;
  }

  /// How the newest endurance run held up, null until one has decay data.
  String? _enduranceCaption() {
    for (final result in reactions) {
      if (result.format != ReactionFormat.endurance) {
        continue;
      }
      final decay = result.decayPercent;
      if (decay == null) {
        return null;
      }
      final direction = decay < 0 ? 'faster' : 'slower';
      return 'Endurance: ${decay.abs()}% $direction over '
          '${ReactionProvider.enduranceSeconds} s';
    }
    return null;
  }
}

class _ModeBests extends StatelessWidget {
  const _ModeBests({required this.bestByMode});

  final Map<ReactionMode, int> bestByMode;

  static const int _perLine = 3;

  @override
  Widget build(BuildContext context) {
    final entries = [
      for (final mode in ReactionMode.values)
        if (bestByMode[mode] case final best?) MapEntry(mode, best),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            (constraints.maxWidth - AppTheme.spaceSm * (_perLine - 1)) /
            _perLine;
        return Wrap(
          spacing: AppTheme.spaceSm,
          runSpacing: AppTheme.spaceSm,
          children: [
            for (final entry in entries)
              SizedBox(
                width: width,
                child: StatTile(
                  value: entry.value,
                  suffix: ' ms',
                  label: entry.key.label,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.milestones});

  final List<Milestone> milestones;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < milestones.length; index++) ...[
            if (index > 0) const SizedBox(width: AppTheme.spaceSm),
            MilestoneBadge(milestone: milestones[index], index: index),
          ],
        ],
      ),
    );
  }
}

class _AllTimeRow extends StatelessWidget {
  const _AllTimeRow({required this.stats});

  final TrainingStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatTile(value: stats.totalSessions, label: 'SESSIONS'),
        ),
        const SizedBox(width: AppTheme.spaceSm),
        Expanded(
          child: StatTile(value: stats.totalRounds, label: 'ROUNDS'),
        ),
        const SizedBox(width: AppTheme.spaceSm),
        Expanded(
          child: StatTile(value: stats.totalMinutes, label: 'MINUTES'),
        ),
      ],
    );
  }
}

class _EmptyProgress extends StatelessWidget {
  const _EmptyProgress({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      eyebrow: 'YOUR RECORD STARTS HERE',
      title: 'Round one is waiting.',
      body:
          'Finish one session and this page fills with rounds, minutes, your '
          'streak and the badges you earn.',
      actionLabel: 'Start a session',
      onAction: () => context.read<ShellProvider>().showTab(_trainTab),
      extra: QuoteCard(
        quote: quoteFor(QuoteSurface.progress, now),
        cycles: true,
      ),
    );
  }
}
