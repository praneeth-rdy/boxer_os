import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/round_spec.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/models/workout.dart';
import 'package:boxer_os/pages/session_complete_page.dart';
import 'package:boxer_os/providers/history_provider.dart';
import 'package:boxer_os/providers/session_provider.dart';
import 'package:boxer_os/widgets/journal_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Workout _loggableWorkout = Workout(
  id: 'w',
  name: 'Notes Test',
  type: TrainingType.shadowBoxing,
  difficulty: Difficulty.beginner,
  prepareSeconds: 0,
  rounds: [RoundSpec(workSeconds: 2, restSeconds: 0)],
);

const Workout _sparringWorkout = Workout(
  id: 'w',
  name: 'Sparring Test',
  type: TrainingType.sparring,
  difficulty: Difficulty.beginner,
  prepareSeconds: 0,
  rounds: [RoundSpec(workSeconds: 2, restSeconds: 0)],
);

void main() {
  Future<SessionProvider> completeSession(
    WidgetTester tester,
    Workout workout,
  ) async {
    var now = DateTime(2026, 1, 1);
    final session = SessionProvider(clock: () => now);
    session.start(
      workout,
      stance: session.stance,
      difficulty: workout.difficulty,
    );

    // Placeholder tree so pump() has a binding to advance before the real
    // page is built with the already-completed record.
    await tester.pumpWidget(const SizedBox());
    for (var second = 0; second < workout.rounds.first.workSeconds; second++) {
      now = now.add(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    }
    return session;
  }

  Future<void> pump(
    WidgetTester tester,
    SessionProvider session, {
    HistoryProvider? history,
  }) {
    // Tall surface so every journal field is built, not just the ones the
    // default test viewport's cache extent would lazily render.
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    return tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SessionProvider>.value(value: session),
          ChangeNotifierProvider<HistoryProvider>.value(
            value: history ?? HistoryProvider(),
          ),
        ],
        child: const MaterialApp(home: SessionCompletePage()),
      ),
    );
  }

  testWidgets('shows "No session" when there is no record', (tester) async {
    final session = SessionProvider();

    await pump(tester, session);

    expect(find.text('No session'), findsOneWidget);
  });

  testWidgets('offers nothing to log for a session with no rounds', (
    tester,
  ) async {
    const workout = Workout(
      id: 'w',
      name: 'Complete Test',
      type: TrainingType.footwork,
      difficulty: Difficulty.beginner,
      prepareSeconds: 0,
      rounds: [RoundSpec(workSeconds: 2, restSeconds: 0)],
    );
    final session = SessionProvider();
    session.start(
      workout,
      stance: session.stance,
      difficulty: workout.difficulty,
    );
    session.end();

    await pump(tester, session);

    expect(find.text('Nothing to log'), findsOneWidget);
    expect(find.text('DONE'), findsOneWidget);

    session.reset();
  });

  testWidgets('Done resets the session and pops to the first route', (
    tester,
  ) async {
    final session = SessionProvider();
    const workout = Workout(
      id: 'w',
      name: 'Done Test',
      type: TrainingType.footwork,
      difficulty: Difficulty.beginner,
      prepareSeconds: 0,
      rounds: [RoundSpec(workSeconds: 2, restSeconds: 0)],
    );
    session.start(
      workout,
      stance: session.stance,
      difficulty: workout.difficulty,
    );
    session.end();

    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      ChangeNotifierProvider<SessionProvider>.value(
        value: session,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          home: const _FirstPage(),
        ),
      ),
    );

    // Push the complete page manually so popUntil(isFirst) has a first route.
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const SessionCompletePage()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('DONE'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(_FirstPage), findsOneWidget);
    expect(session.record, isNull);
  });

  testWidgets('tapping a rating target selects it and updates the label', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final session = await completeSession(tester, _loggableWorkout);

    await pump(tester, session);

    expect(find.text('How did it go?'), findsOneWidget);

    await tester.tap(find.text('4'));
    await tester.pump();

    expect(find.text('Sharp'), findsOneWidget);

    session.reset();
  });

  testWidgets('Save persists the rating and journal texts on the record', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final session = await completeSession(tester, _loggableWorkout);
    final history = HistoryProvider();

    await pump(tester, session, history: history);

    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextField, 'Sharp jab, good distance'),
      'Felt sharp today',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Hands dropping when tired'),
      'Hands dropped late',
    );
    await tester.tap(find.text('SAVE'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(history.sessions, hasLength(1));
    final saved = history.sessions.first;
    expect(saved.rating, 5);
    expect(saved.whatWorked, 'Felt sharp today');
    expect(saved.whatNeedsWork, 'Hands dropped late');
    expect(session.record, isNull);
  });

  testWidgets(
    'sparring sessions show the opponent fields, other types do not',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sparringSession = await completeSession(tester, _sparringWorkout);

      await pump(tester, sparringSession);

      expect(find.byType(JournalField), findsNWidgets(3));
      expect(find.text('OPPONENT STANCE'), findsOneWidget);
      expect(find.text(Stance.orthodox.label), findsOneWidget);

      sparringSession.reset();

      final nonSparringSession = await completeSession(
        tester,
        _loggableWorkout,
      );

      await pump(tester, nonSparringSession);

      expect(find.byType(JournalField), findsNWidgets(2));
      expect(find.text('OPPONENT STANCE'), findsNothing);

      nonSparringSession.reset();
    },
  );

  testWidgets(
    'a 0-round 30-second session shows Nothing to log and saves nothing',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      var now = DateTime(2026, 1, 1);
      final session = SessionProvider(clock: () => now);
      const workout = Workout(
        id: 'w',
        name: 'Short Test',
        type: TrainingType.shadowBoxing,
        difficulty: Difficulty.beginner,
        prepareSeconds: 0,
        rounds: [RoundSpec(workSeconds: 60, restSeconds: 0)],
      );
      session.start(
        workout,
        stance: session.stance,
        difficulty: workout.difficulty,
      );

      await tester.pumpWidget(const SizedBox());
      for (var second = 0; second < 30; second++) {
        now = now.add(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
      }
      session.end();
      expect(session.record?.roundsCompleted, 0);
      expect(session.record?.durationSeconds, lessThan(60));

      final history = HistoryProvider();
      await pump(tester, session, history: history);

      expect(find.text('Nothing to log'), findsOneWidget);

      await tester.tap(find.text('DONE'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(history.sessions, isEmpty);
    },
  );
}

class _FirstPage extends StatelessWidget {
  const _FirstPage();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('First'));
}
