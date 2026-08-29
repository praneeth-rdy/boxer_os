import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/round_spec.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/models/workout.dart';
import 'package:boxer_os/pages/session_complete_page.dart';
import 'package:boxer_os/pages/session_page.dart';
import 'package:boxer_os/providers/session_provider.dart';
import 'package:boxer_os/theme/app_theme.dart';
import 'package:boxer_os/widgets/pill_button.dart';
import 'package:boxer_os/widgets/round_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  // 1 round, 5s work, 0s rest, 2s prepare: matches the handoff's acceptance walk-through.
  const workout = Workout(
    id: 'w',
    name: 'Session Test',
    type: TrainingType.shadowBoxing,
    difficulty: Difficulty.beginner,
    prepareSeconds: 2,
    rounds: [RoundSpec(workSeconds: 5, restSeconds: 0)],
  );

  Future<void> tick(WidgetTester tester, ValueGetter<DateTime> advance) async {
    advance();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('runs prepare -> work -> complete and ends on the summary page', (
    tester,
  ) async {
    var now = DateTime(2026, 1, 1);
    final session = SessionProvider(clock: () => now);
    session.start(
      workout,
      stance: session.stance,
      difficulty: workout.difficulty,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<SessionProvider>.value(
        value: session,
        child: const MaterialApp(home: SessionPage()),
      ),
    );

    expect(find.text('GET READY'), findsOneWidget);
    expect(find.text('0:02'), findsOneWidget);

    // Elapse the 2s prepare phase; round 1's work phase starts.
    await tick(tester, () => now = now.add(const Duration(seconds: 1)));
    await tick(tester, () => now = now.add(const Duration(seconds: 1)));

    expect(find.text('ROUND 1 OF 1'), findsOneWidget);
    expect(find.text('0:05'), findsOneWidget);

    // Elapse the 5s work phase; the session completes.
    for (var second = 0; second < 5; second++) {
      await tick(tester, () => now = now.add(const Duration(seconds: 1)));
    }

    expect(find.text('0:00'), findsOneWidget);

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(SessionCompletePage), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);

    session.reset();
  });

  testWidgets('tapping the centre toggles pause', (tester) async {
    final session = SessionProvider();
    session.start(
      workout,
      stance: session.stance,
      difficulty: workout.difficulty,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<SessionProvider>.value(
        value: session,
        child: const MaterialApp(home: SessionPage()),
      ),
    );

    expect(find.text('PAUSED'), findsNothing);
    expect(find.text('PAUSE'), findsOneWidget);

    await tester.tap(find.byType(RoundClock));
    await tester.pump();

    expect(find.text('PAUSED'), findsOneWidget);
    expect(find.text('RESUME'), findsOneWidget);
    expect(session.isPaused, isTrue);

    session.reset();
  });

  testWidgets(
    'system back shows a confirm dialog; Keep going stays on the session',
    (tester) async {
      final session = SessionProvider();
      session.start(
        workout,
        stance: session.stance,
        difficulty: workout.difficulty,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<SessionProvider>.value(
          value: session,
          child: const MaterialApp(home: SessionPage()),
        ),
      );

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.maybePop();
      await tester.pumpAndSettle();

      expect(find.text('End session?'), findsOneWidget);

      await tester.tap(find.text('Keep going'));
      await tester.pumpAndSettle();

      expect(find.byType(SessionPage), findsOneWidget);
      expect(session.isActive, isTrue);

      session.reset();
    },
  );

  testWidgets('system back then End lands on the summary with nothing to log', (
    tester,
  ) async {
    final session = SessionProvider();
    session.start(
      workout,
      stance: session.stance,
      difficulty: workout.difficulty,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<SessionProvider>.value(
        value: session,
        child: const MaterialApp(home: SessionPage()),
      ),
    );

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.maybePop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('End'));
    await tester.pumpAndSettle();

    expect(find.byType(SessionCompletePage), findsOneWidget);
    expect(find.text('Nothing to log'), findsOneWidget);

    session.reset();
  });

  testWidgets('every control is at least 64dp tall', (tester) async {
    final session = SessionProvider();
    session.start(
      workout,
      stance: session.stance,
      difficulty: workout.difficulty,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<SessionProvider>.value(
        value: session,
        child: const MaterialApp(home: SessionPage()),
      ),
    );

    for (final button in tester.widgetList<PillButton>(
      find.byType(PillButton),
    )) {
      expect(button.height, greaterThanOrEqualTo(64));
    }
    expect(AppTheme.sessionTapTarget, greaterThanOrEqualTo(64));

    session.reset();
  });
}
