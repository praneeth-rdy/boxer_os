import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/data/boxing_calendar.dart';
import 'package:boxer_os/data/boxing_facts.dart';
import 'package:boxer_os/data/legends.dart';
import 'package:boxer_os/data/quotes.dart';
import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/session_record.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/pages/home_page.dart';
import 'package:boxer_os/pages/legend_story_page.dart';
import 'package:boxer_os/pages/session_page.dart';
import 'package:boxer_os/pages/settings_page.dart';
import 'package:boxer_os/providers/history_provider.dart';
import 'package:boxer_os/providers/session_provider.dart';
import 'package:boxer_os/providers/settings_provider.dart';
import 'package:boxer_os/providers/shell_provider.dart';
import 'package:boxer_os/services/voice_service.dart';
import 'package:boxer_os/widgets/fact_card.dart';
import 'package:boxer_os/widgets/legend_card.dart';
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
  _Providers(this.history, this.settings, this.session, this.shell);

  final HistoryProvider history;
  final SettingsProvider settings;
  final SessionProvider session;
  final ShellProvider shell;
}

Future<_Providers> _pump(
  WidgetTester tester, {
  List<SessionRecord> sessions = const [],
  String fighterName = '',
  DateTime Function() clock = DateTime.now,
}) async {
  // The default 800x600 test surface clips content below the fold; grow it so the
  // legend-of-the-week card and everything after it sit inside the list's cache extent.
  tester.view.physicalSize = const Size(800, 3000);
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
  final shell = ShellProvider();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: history),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider.value(value: shell),
        Provider<VoiceService>.value(value: VoiceService()),
      ],
      child: MaterialApp(home: HomePage(clock: clock)),
    ),
  );
  return _Providers(history, settings, session, shell);
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
    final now = DateTime.now();

    expect(find.byType(QuoteCard), findsOneWidget);
    expect(find.byType(FactCard), findsOneWidget);
    expect(find.text(quoteFor(QuoteSurface.home, now).text), findsOneWidget);
    expect(find.text(factFor(FactSurface.home, now).text), findsOneWidget);

    providers.session.reset();
  });

  testWidgets("home's quote and fact differ from progress on the same day", (
    tester,
  ) async {
    final providers = await _pump(tester);
    final now = DateTime.now();

    expect(
      quoteFor(QuoteSurface.home, now) == quoteFor(QuoteSurface.progress, now),
      isFalse,
    );
    expect(
      factFor(FactSurface.home, now) == factFor(FactSurface.progress, now),
      isFalse,
    );

    providers.session.reset();
  });

  testWidgets('tapping the home quote card swaps in the next quote', (
    tester,
  ) async {
    final providers = await _pump(tester);
    final now = DateTime.now();
    final current = quoteFor(QuoteSurface.home, now);

    await tester.tap(find.byType(QuoteCard));
    await tester.pumpAndSettle();

    expect(find.text(quoteAfter(current).text), findsOneWidget);
    expect(find.text(current.text), findsNothing);

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

  testWidgets(
    'shows the featured legend of the week card matching legendOfTheWeek',
    (tester) async {
      final providers = await _pump(tester);
      final legend = legendOfTheWeek(DateTime.now());

      expect(find.text('LEGEND OF THE WEEK'), findsOneWidget);
      final card = tester.widget<LegendCard>(find.byType(LegendCard));
      expect(card.legend.id, legend.id);
      expect(card.featured, isTrue);
      expect(find.text(legend.name), findsOneWidget);

      providers.session.reset();
    },
  );

  testWidgets('tapping the featured legend card opens its story page', (
    tester,
  ) async {
    final providers = await _pump(tester);
    final legend = legendOfTheWeek(DateTime.now());

    await tester.tap(find.byType(LegendCard));
    await tester.pumpAndSettle();

    final story = tester.widget<LegendStoryPage>(find.byType(LegendStoryPage));
    expect(story.legend.id, legend.id);

    providers.session.reset();
  });

  testWidgets("tapping 'More in Corner' switches the shell to the Corner tab", (
    tester,
  ) async {
    final providers = await _pump(tester);

    await tester.tap(find.text('More in Corner'));
    await tester.pumpAndSettle();

    expect(providers.shell.tabIndex, 3);

    providers.session.reset();
  });

  testWidgets('shows the TODAY IN BOXING card on a date with an event', (
    tester,
  ) async {
    final providers = await _pump(
      tester,
      clock: () => DateTime(2026, 10, 30, 9),
    );

    expect(find.text('TODAY IN BOXING'), findsOneWidget);
    expect(find.text('The Rumble in the Jungle'), findsOneWidget);

    providers.session.reset();
  });

  testWidgets('has no TODAY IN BOXING card on a date without an event', (
    tester,
  ) async {
    final providers = await _pump(
      tester,
      clock: () => DateTime(2026, 10, 29, 9),
    );

    expect(find.text('TODAY IN BOXING'), findsNothing);

    providers.session.reset();
  });

  testWidgets('tapping the TODAY IN BOXING card opens its detail sheet', (
    tester,
  ) async {
    final providers = await _pump(
      tester,
      clock: () => DateTime(2026, 10, 30, 9),
    );

    await tester.tap(find.text('The Rumble in the Jungle'));
    await tester.pumpAndSettle();

    expect(find.text('30 OCTOBER 1974'), findsOneWidget);
    expect(find.text('READ THE LEGEND'), findsOneWidget);

    providers.session.reset();
  });

  testWidgets('the TODAY IN BOXING card shows the event blurb', (tester) async {
    final event = eventsOn(DateTime(2026, 10, 30)).first;
    final providers = await _pump(
      tester,
      clock: () => DateTime(2026, 10, 30, 9),
    );

    expect(find.text(event.blurb), findsOneWidget);

    providers.session.reset();
  });
}
