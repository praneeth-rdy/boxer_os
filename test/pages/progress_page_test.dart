import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/reaction_format.dart';
import 'package:boxer_os/models/reaction_mode.dart';
import 'package:boxer_os/models/reaction_result.dart';
import 'package:boxer_os/models/session_record.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/pages/history_page.dart';
import 'package:boxer_os/pages/progress_page.dart';
import 'package:boxer_os/providers/history_provider.dart';
import 'package:boxer_os/providers/shell_provider.dart';
import 'package:boxer_os/widgets/fact_card.dart';
import 'package:boxer_os/widgets/milestone_badge.dart';
import 'package:boxer_os/widgets/quote_card.dart';
import 'package:boxer_os/widgets/skill_card.dart';
import 'package:boxer_os/widgets/stat_tile.dart';

SessionRecord _session(
  String id, {
  required DateTime startedAt,
  required int roundsCompleted,
  required int durationSeconds,
}) => SessionRecord(
  id: id,
  workoutId: 'w',
  workoutName: 'Workout',
  type: TrainingType.shadowBoxing,
  difficulty: Difficulty.beginner,
  stance: Stance.orthodox,
  startedAt: startedAt,
  durationSeconds: durationSeconds,
  roundsCompleted: roundsCompleted,
  roundsPlanned: roundsCompleted,
  completed: true,
);

ReactionResult _reactionResult(
  ReactionMode mode,
  int bestMillis, {
  ReactionFormat format = ReactionFormat.standard,
  DateTime? completedAt,
}) => ReactionResult(
  mode: mode,
  format: format,
  completedAt: completedAt ?? DateTime(2026, 8, 29),
  reactionMillis: [bestMillis],
  falseStarts: 0,
  misses: 0,
);

Future<HistoryProvider> _pump(
  WidgetTester tester,
  List<SessionRecord> sessions, {
  ShellProvider? shell,
  List<ReactionResult> reactions = const [],
}) async {
  // The empty state and its quote card push milestones past the default
  // 800x600 test surface; grow it so nothing renders offstage.
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final history = HistoryProvider();
  await history.load();
  for (final session in sessions) {
    await history.addSession(session);
  }
  for (final reaction in reactions) {
    await history.addReaction(reaction);
  }

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: history),
        ChangeNotifierProvider.value(value: shell ?? ShellProvider()),
      ],
      child: const MaterialApp(home: ProgressPage()),
    ),
  );
  return history;
}

void main() {
  testWidgets(
    'empty history shows the empty state and eight unachieved badges',
    (tester) async {
      await _pump(tester, []);

      expect(find.text('YOUR RECORD STARTS HERE'), findsOneWidget);
      expect(find.text('Round one is waiting.'), findsOneWidget);
      expect(find.byType(QuoteCard), findsOneWidget);

      final badges = tester
          .widgetList<MilestoneBadge>(find.byType(MilestoneBadge))
          .toList();
      expect(badges.length, 8);
      expect(badges.every((badge) => !badge.milestone.achieved), isTrue);
      expect(badges.last.milestone.id, 'endurance_first');
    },
  );

  testWidgets(
    'tapping the empty state action switches the shell to the Train tab',
    (tester) async {
      final shell = ShellProvider();
      await _pump(tester, [], shell: shell);

      await tester.tap(find.text('START A SESSION'));
      await tester.pump();

      expect(shell.tabIndex, 1);
    },
  );

  testWidgets(
    'two sessions today shows correct rounds, minutes and streak tiles',
    (tester) async {
      final now = DateTime.now();
      await _pump(tester, [
        _session('a', startedAt: now, roundsCompleted: 4, durationSeconds: 300),
        _session(
          'b',
          startedAt: now.subtract(const Duration(minutes: 5)),
          roundsCompleted: 1,
          durationSeconds: 60,
        ),
        // Outside the current week: keeps the all-time totals from
        // colliding with the week values above so each number is unique.
        _session(
          'c',
          startedAt: now.subtract(const Duration(days: 10)),
          roundsCompleted: 10,
          durationSeconds: 600,
        ),
      ]);

      expect(find.text('YOUR RECORD STARTS HERE'), findsNothing);
      expect(find.byType(FactCard), findsOneWidget);
      final tiles = {
        for (final tile in tester.widgetList<StatTile>(find.byType(StatTile)))
          tile.label: tile.value,
      };
      // week rounds: 4 + 1 = 5, week minutes: 5 + 1 = 6, streak: 1 (both today).
      expect(tiles['WEEK ROUNDS'], 5);
      expect(tiles['WEEK MINUTES'], 6);
      expect(tiles['DAY STREAK'], 1);
    },
  );

  testWidgets('shows the History card with the book icon', (tester) async {
    await _pump(tester, []);

    final card = tester.widget<SkillCard>(find.byType(SkillCard));
    expect(card.title, 'History');
    expect(card.icon, Icons.menu_book_rounded);
  });

  testWidgets('History card caption reads empty with no logged sessions', (
    tester,
  ) async {
    await _pump(tester, []);

    expect(find.text('Nothing logged yet'), findsOneWidget);
  });

  testWidgets('History card caption counts only sessions with rounds', (
    tester,
  ) async {
    final now = DateTime.now();
    await _pump(tester, [
      _session('a', startedAt: now, roundsCompleted: 3, durationSeconds: 180),
      _session('b', startedAt: now, roundsCompleted: 0, durationSeconds: 20),
    ]);

    expect(find.text('1 session logged'), findsOneWidget);
  });

  testWidgets('History card caption pluralises past one session', (
    tester,
  ) async {
    final now = DateTime.now();
    await _pump(tester, [
      _session('a', startedAt: now, roundsCompleted: 3, durationSeconds: 180),
      _session('b', startedAt: now, roundsCompleted: 2, durationSeconds: 120),
    ]);

    expect(find.text('2 sessions logged'), findsOneWidget);
  });

  testWidgets('reaction section shows a best-time tile per mode with results', (
    tester,
  ) async {
    final now = DateTime.now();
    await _pump(
      tester,
      [_session('a', startedAt: now, roundsCompleted: 1, durationSeconds: 60)],
      reactions: [
        _reactionResult(
          ReactionMode.tap,
          120,
          completedAt: now.subtract(const Duration(minutes: 2)),
        ),
        _reactionResult(
          ReactionMode.tap,
          90,
          completedAt: now.subtract(const Duration(minutes: 1)),
        ),
        _reactionResult(ReactionMode.defense, 200, completedAt: now),
      ],
    );

    final tiles = {
      for (final tile in tester.widgetList<StatTile>(find.byType(StatTile)))
        tile.label: tile,
    };
    // Best of the two Tap results (90, 120) is the lower one.
    expect(tiles['Tap']?.value, 90);
    expect(tiles['Defense']?.value, 200);
    expect(tiles.containsKey('Direction'), isFalse);
    expect(tiles.containsKey('Go / No-go'), isFalse);
  });

  testWidgets(
    'reaction section shows the endurance decay caption for the newest run',
    (tester) async {
      final now = DateTime.now();
      await _pump(
        tester,
        [
          _session(
            'a',
            startedAt: now,
            roundsCompleted: 1,
            durationSeconds: 60,
          ),
        ],
        reactions: [
          ReactionResult(
            mode: ReactionMode.tap,
            format: ReactionFormat.endurance,
            completedAt: now,
            reactionMillis: const [100, 110, 150, 170],
            falseStarts: 0,
            misses: 0,
          ),
        ],
      );

      expect(find.text('Endurance: 52% slower over 60 s'), findsOneWidget);
    },
  );

  testWidgets(
    'reaction section falls back to the prompt when no results exist',
    (tester) async {
      final now = DateTime.now();
      await _pump(tester, [
        _session('a', startedAt: now, roundsCompleted: 1, durationSeconds: 60),
      ]);

      expect(
        find.text('Run the reaction trainer to see a trend.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('tapping the History card opens HistoryPage', (tester) async {
    await _pump(tester, []);

    await tester.tap(find.byType(SkillCard));
    // The empty state's breathing dot loops forever, so settle a fixed
    // number of frames instead of pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(HistoryPage), findsOneWidget);
  });
}
