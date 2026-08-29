import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/session_record.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/pages/history_page.dart';
import 'package:boxer_os/pages/session_detail_page.dart';
import 'package:boxer_os/providers/history_provider.dart';
import 'package:boxer_os/providers/shell_provider.dart';

SessionRecord _session(String id, {required DateTime startedAt}) =>
    SessionRecord(
      id: id,
      workoutId: 'w',
      workoutName: 'Workout $id',
      type: TrainingType.shadowBoxing,
      difficulty: Difficulty.beginner,
      stance: Stance.orthodox,
      startedAt: startedAt,
      durationSeconds: 180,
      roundsCompleted: 3,
      roundsPlanned: 3,
      completed: true,
    );

Future<_HistoryProviders> _pump(
  WidgetTester tester,
  List<SessionRecord> sessions,
) async {
  SharedPreferences.setMockInitialValues({});
  final history = HistoryProvider();
  await history.load();
  for (final session in sessions) {
    await history.addSession(session);
  }
  final shell = ShellProvider();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: history),
        ChangeNotifierProvider.value(value: shell),
      ],
      child: const MaterialApp(home: HistoryPage()),
    ),
  );
  return _HistoryProviders(history, shell);
}

class _HistoryProviders {
  _HistoryProviders(this.history, this.shell);

  final HistoryProvider history;
  final ShellProvider shell;
}

void main() {
  testWidgets('empty history shows the empty state', (tester) async {
    await _pump(tester, []);

    expect(find.text('NOTHING LOGGED YET'), findsOneWidget);
    expect(find.text('Your first session lands here.'), findsOneWidget);
  });

  testWidgets(
    'tapping the empty state action pops the page and switches to Train',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      SharedPreferences.setMockInitialValues({});
      final history = HistoryProvider();
      await history.load();
      final shell = ShellProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: history),
            ChangeNotifierProvider.value(value: shell),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const _HistoryHost(),
          ),
        ),
      );
      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const HistoryPage()),
      );
      // The empty state's breathing dot loops forever, so settle a fixed
      // number of frames instead of pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      await tester.tap(find.text('GO TO TRAIN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.byType(HistoryPage), findsNothing);
      expect(shell.tabIndex, 1);
    },
  );

  testWidgets(
    'sessions are grouped newest first under TODAY and YESTERDAY headers',
    (tester) async {
      final now = DateTime.now();
      await _pump(tester, [
        _session('older', startedAt: now.subtract(const Duration(days: 1))),
        _session('newer', startedAt: now),
      ]);

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('YESTERDAY'), findsOneWidget);
      expect(find.text('Workout newer'), findsOneWidget);
      expect(find.text('Workout older'), findsOneWidget);

      final todayHeader = tester.getTopLeft(find.text('TODAY'));
      final yesterdayHeader = tester.getTopLeft(find.text('YESTERDAY'));
      expect(todayHeader.dy, lessThan(yesterdayHeader.dy));
    },
  );

  testWidgets('tapping a session tile pushes the detail page', (tester) async {
    final now = DateTime.now();
    await _pump(tester, [_session('1', startedAt: now)]);

    await tester.tap(find.text('Workout 1'));
    await tester.pumpAndSettle();

    expect(find.byType(SessionDetailPage), findsOneWidget);
  });
}

class _HistoryHost extends StatelessWidget {
  const _HistoryHost();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Host'));
}
