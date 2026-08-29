import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/models/incoming_punch.dart';
import 'package:boxer_os/models/reaction_mode.dart';
import 'package:boxer_os/pages/reaction_page.dart';
import 'package:boxer_os/providers/history_provider.dart';
import 'package:boxer_os/providers/reaction_provider.dart';
import 'package:boxer_os/providers/settings_provider.dart';
import 'package:boxer_os/theme/app_theme.dart';
import 'package:boxer_os/widgets/defense_grid.dart';
import 'package:boxer_os/widgets/reaction_arena.dart';

/// A Random that always answers the same values, so a stimulus is predictable.
class _FixedRandom implements Random {
  _FixedRandom({this.doubleValue = 0.0});

  final double doubleValue;

  @override
  double nextDouble() => doubleValue;

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => false;
}

List<SingleChildWidget> _providers({
  required ReactionProvider reaction,
  HistoryProvider? history,
  SettingsProvider? settings,
}) => [
  ChangeNotifierProvider<ReactionProvider>.value(value: reaction),
  ChangeNotifierProvider<HistoryProvider>.value(
    value: history ?? HistoryProvider(),
  ),
  ChangeNotifierProvider<SettingsProvider>.value(
    value: settings ?? SettingsProvider(),
  ),
];

/// Unmounts the page (so its own dispose() cancels the run safely) before
/// disposing [reaction] directly; needed whenever a test ends mid-run.
Future<void> _tearDownRunning(
  WidgetTester tester,
  ReactionProvider reaction,
) async {
  await tester.pumpWidget(const SizedBox());
  reaction.dispose();
}

/// The mode picker's four cards run past the default 800x600 test surface;
/// grow it so the later cards are actually built, not just scrolled past.
void _growViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// The arena's background, set via AnimatedContainer's [color] shorthand
/// which the widget stores as a [BoxDecoration].
Color? _arenaColor(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.byType(AnimatedContainer),
  );
  return (container.decoration as BoxDecoration?)?.color;
}

Future<void> _elapseUntil(
  WidgetTester tester,
  ReactionProvider reaction,
  ReactionPhase phase,
) async {
  var budget = const Duration(seconds: 10);
  const step = Duration(milliseconds: 10);
  while (reaction.phase != phase) {
    await tester.pump(step);
    budget -= step;
    if (budget.isNegative) {
      fail('phase never reached $phase (stuck at ${reaction.phase})');
    }
  }
}

void main() {
  testWidgets(
    'walks from the mode picker through the countdown, stimulus and result screen',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      var now = DateTime(2026, 1, 1);
      final reaction = ReactionProvider(clock: () => now);

      await tester.pumpWidget(
        MultiProvider(
          providers: _providers(reaction: reaction),
          child: const MaterialApp(home: ReactionPage()),
        ),
      );

      expect(find.text('Tap'), findsOneWidget);
      expect(find.text('Direction'), findsOneWidget);

      await tester.tap(find.text('Tap'));
      await tester.pump();

      expect(find.text('TRIAL 1 OF 10'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('2'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('WAIT'), findsOneWidget);

      await _elapseUntil(tester, reaction, ReactionPhase.stimulus);
      expect(find.text('GO'), findsOneWidget);

      now = now.add(const Duration(milliseconds: 200));
      await tester.tap(find.byType(ReactionArena));
      await tester.pump();
      expect(reaction.phase, ReactionPhase.feedback);

      // Fast-forward through the remaining nine trials to reach the result screen.
      while (reaction.phase != ReactionPhase.complete) {
        if (reaction.phase == ReactionPhase.feedback) {
          await tester.pump(const Duration(milliseconds: 700));
        } else if (reaction.phase == ReactionPhase.stimulus) {
          await tester.tap(find.byType(ReactionArena));
          await tester.pump();
        } else {
          await tester.pump(const Duration(milliseconds: 10));
        }
      }
      await tester.pump();

      expect(find.text('RESULT'), findsOneWidget);
      expect(find.text('AGAIN'), findsOneWidget);
      expect(find.text('DONE'), findsOneWidget);

      reaction.dispose();
    },
  );

  testWidgets('saves the result to history exactly once on completion', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    var now = DateTime(2026, 1, 1);
    final reaction = ReactionProvider(clock: () => now);
    final history = HistoryProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: _providers(reaction: reaction, history: history),
        child: const MaterialApp(home: ReactionPage()),
      ),
    );

    await tester.tap(find.text('Tap'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    while (reaction.phase != ReactionPhase.complete) {
      if (reaction.phase == ReactionPhase.feedback) {
        await tester.pump(const Duration(milliseconds: 700));
      } else if (reaction.phase == ReactionPhase.stimulus) {
        now = now.add(const Duration(milliseconds: 200));
        await tester.tap(find.byType(ReactionArena));
        await tester.pump();
      } else {
        await tester.pump(const Duration(milliseconds: 10));
      }
    }
    await tester.pump();

    expect(history.reactions, hasLength(1));
    expect(history.reactions.first.mode, ReactionMode.tap);

    // A further rebuild with the same result must not save it again.
    await tester.pump();
    expect(history.reactions, hasLength(1));

    reaction.dispose();
  });

  testWidgets('Stop cancels a running test and returns to the mode picker', (
    tester,
  ) async {
    final reaction = ReactionProvider(clock: () => DateTime(2026, 1, 1));

    await tester.pumpWidget(
      MultiProvider(
        providers: _providers(reaction: reaction),
        child: const MaterialApp(home: ReactionPage()),
      ),
    );

    await tester.tap(find.text('Tap'));
    await tester.pump();
    expect(find.text('STOP'), findsOneWidget);

    await tester.tap(find.text('STOP'));
    await tester.pump();

    expect(reaction.phase, ReactionPhase.idle);
    expect(find.text('Tap'), findsOneWidget);
    expect(find.text('Direction'), findsOneWidget);

    reaction.dispose();
  });

  testWidgets(
    'mode picker shows the format toggle and four cards; Defense passes the stance',
    (tester) async {
      _growViewport(tester);
      SharedPreferences.setMockInitialValues({});
      final reaction = ReactionProvider(clock: () => DateTime(2026, 1, 1));
      final settings = SettingsProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: _providers(reaction: reaction, settings: settings),
          child: const MaterialApp(home: ReactionPage()),
        ),
      );

      expect(find.text('10 trials'), findsOneWidget);
      expect(find.text('Endurance 60'), findsOneWidget);
      expect(find.text('Tap'), findsOneWidget);
      expect(find.text('Direction'), findsOneWidget);
      expect(find.text('Defense'), findsOneWidget);
      expect(find.text('Go / No-go'), findsOneWidget);
      expect(
        find.text('Defense uses your Orthodox stance: slip outside the jab.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Defense'));
      await tester.pump();

      expect(reaction.mode, ReactionMode.defense);
      expect(reaction.stance, settings.stance);

      await _tearDownRunning(tester, reaction);
    },
  );

  testWidgets(
    'Defense stimulus shows the punch word over the grid; the matching zone records a hit',
    (tester) async {
      _growViewport(tester);
      SharedPreferences.setMockInitialValues({});
      var now = DateTime(2026, 1, 1);
      final reaction = ReactionProvider(
        clock: () => now,
        random: _FixedRandom(),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: _providers(reaction: reaction),
          child: const MaterialApp(home: ReactionPage()),
        ),
      );

      await tester.tap(find.text('Defense'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      // The grid is up during the wait too, with dimmed labels.
      expect(find.byType(DefenseGrid), findsOneWidget);
      final waitingLabel = tester.widget<Text>(find.text('SLIP RIGHT'));
      expect(waitingLabel.style?.color, AppTheme.chalkFaint);

      await _elapseUntil(tester, reaction, ReactionPhase.stimulus);

      expect(reaction.incomingPunch, IncomingPunch.jab);
      expect(find.text('JAB'), findsOneWidget);
      final armedLabel = tester.widget<Text>(find.text('SLIP RIGHT'));
      expect(armedLabel.style?.color, AppTheme.chalkMuted);

      now = now.add(const Duration(milliseconds: 180));
      await tester.tap(find.text('SLIP RIGHT'));
      await tester.pump();

      expect(reaction.phase, ReactionPhase.feedback);
      expect(reaction.feedback, '180 ms');

      await _tearDownRunning(tester, reaction);
    },
  );

  testWidgets('Defense: tapping the wrong zone shows Wrong defense', (
    tester,
  ) async {
    _growViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final reaction = ReactionProvider(
      clock: () => DateTime(2026, 1, 1),
      random: _FixedRandom(),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: _providers(reaction: reaction),
        child: const MaterialApp(home: ReactionPage()),
      ),
    );

    await tester.tap(find.text('Defense'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await _elapseUntil(tester, reaction, ReactionPhase.stimulus);

    // The stimulus is a jab, which orthodox beats with a slip right, not a block.
    await tester.tap(find.text('BLOCK'));
    await tester.pump();

    expect(reaction.feedback, 'Wrong defense');

    await _tearDownRunning(tester, reaction);
  });

  testWidgets('Go / No-go stimulus is mint for GO', (tester) async {
    _growViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final reaction = ReactionProvider(
      clock: () => DateTime(2026, 1, 1),
      random: _FixedRandom(),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: _providers(reaction: reaction),
        child: const MaterialApp(home: ReactionPage()),
      ),
    );

    await tester.tap(find.text('Go / No-go'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await _elapseUntil(tester, reaction, ReactionPhase.stimulus);

    expect(reaction.isGo, isTrue);
    expect(find.text('GO'), findsOneWidget);
    expect(_arenaColor(tester), AppTheme.rest);

    await _tearDownRunning(tester, reaction);
  });

  testWidgets('Go / No-go stimulus is red for HOLD', (tester) async {
    _growViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final reaction = ReactionProvider(
      clock: () => DateTime(2026, 1, 1),
      random: _FixedRandom(doubleValue: 0.9),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: _providers(reaction: reaction),
        child: const MaterialApp(home: ReactionPage()),
      ),
    );

    await tester.tap(find.text('Go / No-go'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await _elapseUntil(tester, reaction, ReactionPhase.stimulus);

    expect(reaction.isGo, isFalse);
    expect(find.text('HOLD'), findsOneWidget);
    expect(_arenaColor(tester), AppTheme.accent);

    await _tearDownRunning(tester, reaction);
  });

  testWidgets('Go / No-go result shows ACCURACY', (tester) async {
    _growViewport(tester);
    SharedPreferences.setMockInitialValues({});
    var now = DateTime(2026, 1, 1);
    final reaction = ReactionProvider(clock: () => now, random: _FixedRandom());

    await tester.pumpWidget(
      MultiProvider(
        providers: _providers(reaction: reaction),
        child: const MaterialApp(home: ReactionPage()),
      ),
    );

    await tester.tap(find.text('Go / No-go'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    while (reaction.phase != ReactionPhase.complete) {
      if (reaction.phase == ReactionPhase.feedback) {
        await tester.pump(const Duration(milliseconds: 700));
      } else if (reaction.phase == ReactionPhase.stimulus) {
        now = now.add(const Duration(milliseconds: 150));
        await tester.tap(find.byType(ReactionArena));
        await tester.pump();
      } else {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }
    await tester.pump();

    expect(find.text('ACCURACY'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);

    reaction.dispose();
  });

  testWidgets('Endurance header counts down and result shows the decay line', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    var now = DateTime(2026, 1, 1);
    final reaction = ReactionProvider(clock: () => now, random: _FixedRandom());

    await tester.pumpWidget(
      MultiProvider(
        providers: _providers(reaction: reaction),
        child: const MaterialApp(home: ReactionPage()),
      ),
    );

    await tester.tap(find.text('Endurance 60'));
    await tester.pump();
    await tester.tap(find.text('Tap'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    Future<void> toStimulus() async {
      var budget = const Duration(seconds: 10);
      const step = Duration(milliseconds: 50);
      while (reaction.phase != ReactionPhase.stimulus) {
        now = now.add(step);
        await tester.pump(step);
        budget -= step;
        if (budget.isNegative) {
          fail('stimulus never arrived (stuck at ${reaction.phase})');
        }
      }
    }

    await toStimulus();
    expect(find.text('60s LEFT · TRIAL 1'), findsOneWidget);

    const trialMillis = [100, 150, 200, 250];
    for (var index = 0; index < trialMillis.length; index++) {
      if (index > 0) await toStimulus();
      now = now.add(Duration(milliseconds: trialMillis[index]));
      await tester.tap(find.byType(ReactionArena));
      await tester.pump();
      if (index == trialMillis.length - 1) {
        // Push the clock past the endurance window so this trial ends the run.
        now = now.add(const Duration(seconds: 65));
      }
      await tester.pump(const Duration(milliseconds: 700));
    }

    expect(reaction.phase, ReactionPhase.complete);
    expect(find.text('80% slower by the end'), findsOneWidget);

    reaction.dispose();
  });
}
