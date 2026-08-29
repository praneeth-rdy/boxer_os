import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/session_record.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/pages/session_detail_page.dart';
import 'package:boxer_os/providers/history_provider.dart';

SessionRecord _sparringSession() => SessionRecord(
  id: 'spar-1',
  workoutId: 'w',
  workoutName: 'Sparring Session',
  type: TrainingType.sparring,
  difficulty: Difficulty.intermediate,
  stance: Stance.orthodox,
  startedAt: DateTime(2026, 8, 20, 9, 5),
  durationSeconds: 300,
  roundsCompleted: 3,
  roundsPlanned: 4,
  completed: false,
  rating: 4,
  whatWorked: 'Jab worked well',
  whatNeedsWork: 'Footwork lagged',
  opponent: 'Sam',
  opponentStance: Stance.southpaw,
);

Future<HistoryProvider> _pumpDetail(
  WidgetTester tester,
  String id, {
  SessionRecord? seed,
}) async {
  SharedPreferences.setMockInitialValues({});
  final history = HistoryProvider();
  await history.load();
  if (seed != null) {
    await history.addSession(seed);
  }

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: history,
      child: MaterialApp(home: SessionDetailPage(id: id)),
    ),
  );
  return history;
}

void main() {
  testWidgets('missing session shows "Session not found"', (tester) async {
    await _pumpDetail(tester, 'missing');

    expect(find.text('Session not found'), findsOneWidget);
  });

  testWidgets('shows the journal texts and opponent stance', (tester) async {
    await _pumpDetail(tester, 'spar-1', seed: _sparringSession());

    expect(find.text('Sparring Session'), findsOneWidget);
    expect(find.text('Ended early'), findsOneWidget);
    expect(find.text('WHAT WORKED'), findsOneWidget);
    expect(find.text('Jab worked well'), findsOneWidget);
    expect(find.text('WHAT NEEDS WORK'), findsOneWidget);
    expect(find.text('Footwork lagged'), findsOneWidget);
    expect(find.text('OPPONENT · SOUTHPAW'), findsOneWidget);
    expect(find.text('Sam'), findsOneWidget);
    expect(find.text('4/5'), findsOneWidget);
    expect(find.text('3/4'), findsOneWidget);
  });

  testWidgets('a session with no rating shows "--"', (tester) async {
    final noRating = SessionRecord(
      id: 'no-rating',
      workoutId: 'w',
      workoutName: 'Shadow Session',
      type: TrainingType.shadowBoxing,
      difficulty: Difficulty.beginner,
      stance: Stance.orthodox,
      startedAt: DateTime(2026, 8, 20, 9, 5),
      durationSeconds: 180,
      roundsCompleted: 3,
      roundsPlanned: 3,
      completed: true,
    );

    await _pumpDetail(tester, 'no-rating', seed: noRating);

    expect(find.text('--'), findsOneWidget);
    expect(find.text('WHAT WORKED'), findsNothing);
    expect(find.text('Ended early'), findsNothing);
  });

  testWidgets('deleting removes the record from the provider and pops back', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final history = HistoryProvider();
    await history.load();
    await history.addSession(_sparringSession());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: history,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SessionDetailPage(id: 'spar-1'),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(SessionDetailPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(SessionDetailPage), findsNothing);
    expect(history.findSession('spar-1'), isNull);
  });
}
