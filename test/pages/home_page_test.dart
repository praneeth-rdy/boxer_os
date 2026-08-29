import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/session_record.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/pages/home_page.dart';
import 'package:boxer_os/pages/session_page.dart';
import 'package:boxer_os/pages/settings_page.dart';
import 'package:boxer_os/providers/history_provider.dart';
import 'package:boxer_os/providers/session_provider.dart';
import 'package:boxer_os/providers/settings_provider.dart';
import 'package:boxer_os/services/voice_service.dart';
import 'package:boxer_os/widgets/fact_card.dart';
import 'package:boxer_os/widgets/quote_card.dart';

SessionRecord _session({DateTime? startedAt}) => SessionRecord(
  id: 'last',
  workoutId: 'shadow_foundations',
  workoutName: 'Shadow Foundations',
  type: TrainingType.shadowBoxing,
  difficulty: Difficulty.beginner,
  stance: Stance.orthodox,
  startedAt: startedAt ?? DateTime.now(),
  durationSeconds: 360,
  roundsCompleted: 3,
  roundsPlanned: 3,
  completed: true,
);

String _expectedGreeting(DateTime now, {String who = 'fighter'}) {
  if (now.hour < 12) return 'Morning, $who';
  if (now.hour < 18) return 'Afternoon, $who';
  return 'Evening, $who';
}

class _Providers {
  _Providers(this.history, this.settings, this.session);

  final HistoryProvider history;
  final SettingsProvider settings;
  final SessionProvider session;
}

Future<_Providers> _pump(
  WidgetTester tester, {
  List<SessionRecord> sessions = const [],
  String fighterName = '',
}) async {
  // The default 800x600 test surface clips the quick actions row; grow it.
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({'fighter_name': fighterName});
  final settings = SettingsProvider();
  await settings.load();
  final history = HistoryProvider();
  for (final record in sessions) {
    await history.addSession(record);
  }
  final session = SessionProvider();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: history),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: session),
        Provider<VoiceService>.value(value: VoiceService()),
      ],
      child: const MaterialApp(home: HomePage()),
    ),
  );
  return _Providers(history, settings, session);
}

void main() {
  testWidgets('shows the greeting, streak strip and recommended session', (
    tester,
  ) async {
    final providers = await _pump(tester);

    expect(find.text(_expectedGreeting(DateTime.now())), findsOneWidget);
    expect(find.text('BOXER OS'), findsOneWidget);
    expect(find.text('No streak yet. Today is a good day.'), findsOneWidget);
    expect(find.text('YOUR FIRST SESSION'), findsOneWidget);
    expect(find.text('Shadow Foundations'), findsOneWidget);
    expect(find.text('QUICK ACTIONS'), findsOneWidget);
    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('Combos'), findsOneWidget);
    expect(find.text('Reaction'), findsOneWidget);

    providers.session.reset();
  });

  testWidgets('greets by name once a fighter name is set', (tester) async {
    final providers = await _pump(tester, fighterName: 'Rocky');

    expect(
      find.text(_expectedGreeting(DateTime.now(), who: 'Rocky')),
      findsOneWidget,
    );

    providers.session.reset();
  });

  testWidgets('shows the quote of the day and the fact of the day', (
    tester,
  ) async {
    final providers = await _pump(tester);

    expect(find.byType(QuoteCard), findsOneWidget);
    expect(find.byType(FactCard), findsOneWidget);

    providers.session.reset();
  });

  testWidgets(
    'with no history the first-session eyebrow and copy show, and the '
    'streak strip reads zero rounds this week',
    (tester) async {
      final providers = await _pump(tester);

      expect(find.text('YOUR FIRST SESSION'), findsOneWidget);
      expect(
        find.text(
          'Ten minutes is enough to start a streak. The bell does the rest.',
        ),
        findsOneWidget,
      );
      expect(find.text('0 rounds · 0 min this week'), findsOneWidget);

      providers.session.reset();
    },
  );

  testWidgets('has no last session section when history is empty', (
    tester,
  ) async {
    final providers = await _pump(tester);

    expect(find.text('LAST SESSION'), findsNothing);

    providers.session.reset();
  });

  testWidgets('shows the last session when history has one', (tester) async {
    final providers = await _pump(tester, sessions: [_session()]);

    expect(find.text('LAST SESSION'), findsOneWidget);
    expect(find.text('Shadow Foundations'), findsOneWidget);

    providers.session.reset();
  });

  testWidgets('tapping the settings icon opens SettingsPage', (tester) async {
    final providers = await _pump(tester);

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);

    providers.session.reset();
  });

  testWidgets(
    'tapping Start opens the session page for the recommended workout',
    (tester) async {
      final providers = await _pump(tester);

      await tester.tap(find.text('START'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(SessionPage), findsOneWidget);
      expect(providers.session.workout?.id, 'shadow_foundations');

      providers.session.reset();
    },
  );

  testWidgets('the Timer quick action starts a 3-round quick timer', (
    tester,
  ) async {
    final providers = await _pump(tester);

    await tester.tap(find.text('Timer'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(SessionPage), findsOneWidget);
    expect(providers.session.workout?.roundCount, 3);

    providers.session.reset();
  });
}
