import 'package:boxer_os/pages/session_page.dart';
import 'package:boxer_os/providers/session_provider.dart';
import 'package:boxer_os/providers/settings_provider.dart';
import 'package:boxer_os/widgets/quick_timer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SessionProvider> pump(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsProvider();
    await settings.load();
    final session = SessionProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: session),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: QuickTimerCard())),
        ),
      ),
    );
    return session;
  }

  testWidgets('shows the default rounds, work, rest and summary', (
    tester,
  ) async {
    final session = await pump(tester);

    expect(find.text('3'), findsOneWidget);
    expect(find.text('3:00'), findsOneWidget);
    expect(find.text('1:00'), findsOneWidget);
    expect(find.text('3 rounds, about 12 min'), findsOneWidget);

    session.reset();
  });

  testWidgets('incrementing rounds updates the value and the summary', (
    tester,
  ) async {
    final session = await pump(tester);

    await tester.tap(find.byIcon(Icons.add_rounded).at(0));
    await tester.pump();

    expect(find.text('4'), findsOneWidget);
    expect(find.text('4 rounds, about 16 min'), findsOneWidget);

    session.reset();
  });

  testWidgets('rounds cannot go below 1', (tester) async {
    final session = await pump(tester);
    final decrementRounds = find.byIcon(Icons.remove_rounded).at(0);

    for (var tap = 0; tap < 5; tap++) {
      await tester.tap(decrementRounds);
      await tester.pump();
    }

    expect(find.text('1'), findsOneWidget);
    expect(find.text('0'), findsNothing);

    session.reset();
  });

  testWidgets('work seconds clamp to 30s..600s in 15s steps', (tester) async {
    final session = await pump(tester);
    final decrementWork = find.byIcon(Icons.remove_rounded).at(1);
    final incrementWork = find.byIcon(Icons.add_rounded).at(1);

    for (var tap = 0; tap < 12; tap++) {
      await tester.tap(decrementWork);
      await tester.pump();
    }
    expect(find.text('0:30'), findsOneWidget);

    for (var tap = 0; tap < 40; tap++) {
      await tester.tap(incrementWork);
      await tester.pump();
    }
    expect(find.text('10:00'), findsOneWidget);

    session.reset();
  });

  testWidgets('rest seconds clamp to 0s..300s in 15s steps', (tester) async {
    final session = await pump(tester);
    final decrementRest = find.byIcon(Icons.remove_rounded).at(2);
    final incrementRest = find.byIcon(Icons.add_rounded).at(2);

    for (var tap = 0; tap < 8; tap++) {
      await tester.tap(decrementRest);
      await tester.pump();
    }
    expect(find.text('0:00'), findsOneWidget);

    for (var tap = 0; tap < 25; tap++) {
      await tester.tap(incrementRest);
      await tester.pump();
    }
    expect(find.text('5:00'), findsOneWidget);

    session.reset();
  });

  testWidgets('tapping Start launches the session on the session page', (
    tester,
  ) async {
    final session = await pump(tester);

    await tester.tap(find.text('START'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(SessionPage), findsOneWidget);
    expect(session.workout, isNotNull);

    session.reset();
  });
}
