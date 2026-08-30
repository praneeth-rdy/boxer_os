import 'dart:math' show pi, sin;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/boxing_calendar.dart';
import '../data/boxing_facts.dart';
import '../data/legends.dart';
import '../data/quotes.dart';
import '../models/legend.dart';
import '../models/workout.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/shell_provider.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../utils/duration_format.dart';
import '../utils/recommendation.dart';
import '../utils/session_launcher.dart';
import '../utils/training_stats.dart';
import '../widgets/event_card.dart';
import '../widgets/fact_card.dart';
import '../widgets/legend_card.dart';
import '../widgets/pill_button.dart';
import '../widgets/quick_action.dart';
import '../widgets/quote_card.dart';
import '../widgets/count_up_text.dart';
import '../widgets/section_header.dart';
import '../widgets/session_tile.dart';
import '../widgets/settle_in.dart';
import 'combos_page.dart';
import 'legend_story_page.dart';
import 'reaction_page.dart';
import 'session_detail_page.dart';
import 'settings_page.dart';
import 'workout_detail_page.dart';

const int _cornerTab = 3;
const int _quickRounds = 3;
const int _quickWorkSeconds = 180;
const int _quickRestSeconds = 60;
const int _afternoonHour = 12;
const int _eveningHour = 18;
const double _startHeight = 56;

final TextStyle _ghostLink = AppTheme.bodyStrong.copyWith(
  color: AppTheme.chalkMuted,
  decoration: TextDecoration.underline,
  decorationColor: AppTheme.chalkMuted,
);

/// The command centre: the streak, today's session and the shortcuts.
class HomePage extends StatelessWidget {
  const HomePage({this.clock = DateTime.now, super.key});

  /// Injectable so a test can render the page on any date.
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: SafeArea(
        child: Consumer2<HistoryProvider, SettingsProvider>(
          builder: (context, history, settings, _) {
            final now = clock();
            final stats = TrainingStats.fromSessions(
              history.sessions,
              now: now,
            );
            final sessions = history.sessions;
            final legend = legendOfTheWeek(now);
            final today = eventsOn(now);
            final hasHistory = sessions.isNotEmpty;
            return ListView(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              children: [
                SettleIn(
                  child: SectionHeader(
                    title: _greeting(now, settings.fighterName),
                    eyebrow: 'BOXER OS',
                    trailing: IconButton(
                      icon: const Icon(Icons.settings_rounded),
                      color: AppTheme.chalkMuted,
                      onPressed: () => _openSettings(context),
                    ),
                  ),
                ),
                SettleIn(index: 1, child: _StreakStrip(stats: stats)),
                if (today.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spaceMd),
                  const SettleIn(
                    index: 2,
                    child: Text('TODAY IN BOXING', style: AppTheme.label),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  SettleIn(index: 2, child: EventCard(event: today.first)),
                ],
                const SizedBox(height: AppTheme.spaceMd),
                SettleIn(
                  index: 2,
                  child: QuoteCard(
                    quote: quoteFor(QuoteSurface.home, now),
                    compact: true,
                    cycles: true,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXl),
                const SettleIn(
                  index: 3,
                  child: Text('LEGEND OF THE WEEK', style: AppTheme.label),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                SettleIn(
                  index: 3,
                  child: LegendCard(
                    legend: legend,
                    featured: true,
                    onTap: () => _openLegend(context, legend),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        context.read<ShellProvider>().showTab(_cornerTab),
                    child: Text('More in Corner', style: _ghostLink),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXl),
                SettleIn(
                  index: 4,
                  child: Text(
                    hasHistory ? "TODAY'S SESSION" : 'YOUR FIRST SESSION',
                    style: AppTheme.label,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                SettleIn(
                  index: 4,
                  child: _RecommendedCard(
                    workout: recommendWorkout(
                      stats,
                      settings.difficulty,
                      now: now,
                    ),
                    isFirstSession: !hasHistory,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXl),
                const SettleIn(
                  index: 5,
                  child: Text('QUICK ACTIONS', style: AppTheme.label),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                const SettleIn(index: 5, child: _QuickActionRow()),
                const SizedBox(height: AppTheme.spaceXl),
                SettleIn(
                  index: 6,
                  child: FactCard(
                    fact: factFor(FactSurface.home, now),
                    cycles: true,
                  ),
                ),
                if (hasHistory) ...[
                  const SizedBox(height: AppTheme.spaceXl),
                  const SettleIn(
                    index: 7,
                    child: Text('LAST SESSION', style: AppTheme.label),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  SettleIn(
                    index: 7,
                    child: SessionTile(
                      record: sessions.first,
                      onTap: () => _openSession(context, sessions.first.id),
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

  static String _greeting(DateTime now, String name) {
    final who = name.isEmpty ? 'fighter' : name;
    if (now.hour < _afternoonHour) return 'Morning, $who';
    if (now.hour < _eveningHour) return 'Afternoon, $who';
    return 'Evening, $who';
  }

  void _openSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
  }

  void _openSession(BuildContext context, String id) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => SessionDetailPage(id: id)));
  }

  void _openLegend(BuildContext context, Legend legend) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LegendStoryPage(legend: legend)),
    );
  }
}

class _StreakStrip extends StatelessWidget {
  const _StreakStrip({required this.stats});

  final TrainingStats stats;

  @override
  Widget build(BuildContext context) {
    final hasStreak = stats.streakDays > 0;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StreakFlame(isLit: hasStreak),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: hasStreak
                    ? CountUpText(
                        value: stats.streakDays,
                        suffix: ' day streak',
                        style: AppTheme.title,
                      )
                    : const Text(
                        'No streak yet. Today is a good day.',
                        style: AppTheme.bodyMuted,
                      ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            '${stats.weekRounds} rounds · ${stats.weekMinutes} min this week',
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }
}

/// The flame beats once when the page opens on a live streak.
class _StreakFlame extends StatelessWidget {
  const _StreakFlame({required this.isLit});

  static const double _beatDepth = 0.15;

  final bool isLit;

  @override
  Widget build(BuildContext context) {
    final flame = Icon(
      Icons.local_fire_department_rounded,
      color: isLit ? AppTheme.accent : AppTheme.chalkFaint,
    );
    if (!isLit || AppMotion.reduced(context)) return flame;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: AppMotion.slow,
      builder: (context, beat, child) =>
          Transform.scale(scale: 1 + _beatDepth * sin(pi * beat), child: child),
      child: flame,
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.workout, required this.isFirstSession});

  final Workout workout;
  final bool isFirstSession;

  @override
  Widget build(BuildContext context) {
    final workSeconds = workout.rounds.isEmpty
        ? 0
        : workout.rounds.first.workSeconds;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${workout.type.label} · ${workout.difficulty.label}'.toUpperCase(),
            style: AppTheme.label,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(workout.name, style: AppTheme.displayMedium),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            '${workout.roundCount} x ${formatClock(workSeconds)} · '
            '${workout.estimatedMinutes} min',
            style: AppTheme.bodyMuted,
          ),
          if (isFirstSession) ...[
            const SizedBox(height: AppTheme.spaceMd),
            const Text(
              'Ten minutes is enough to start a streak. The bell does the '
              'rest.',
              style: AppTheme.bodyMuted,
            ),
          ],
          const SizedBox(height: AppTheme.spaceLg),
          PillButton(
            label: 'Start',
            height: _startHeight,
            onPressed: () => startSession(context, workout),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Center(
            child: TextButton(
              onPressed: () => _openDetail(context),
              child: Text('See details', style: _ghostLink),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WorkoutDetailPage(workout: workout),
      ),
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  const _QuickActionRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: QuickAction(
            label: 'Timer',
            icon: Icons.timer_rounded,
            onTap: () => startSession(
              context,
              Workout.quick(
                rounds: _quickRounds,
                workSeconds: _quickWorkSeconds,
                restSeconds: _quickRestSeconds,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spaceSm),
        Expanded(
          child: QuickAction(
            label: 'Combos',
            icon: Icons.sports_mma_rounded,
            onTap: () => _push(context, const CombosPage()),
          ),
        ),
        const SizedBox(width: AppTheme.spaceSm),
        Expanded(
          child: QuickAction(
            label: 'Reaction',
            icon: Icons.flash_on_rounded,
            onTap: () => _push(context, const ReactionPage()),
          ),
        ),
      ],
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}
