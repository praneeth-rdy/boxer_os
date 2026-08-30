import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/pages/calendar_page.dart';
import 'package:boxer_os/pages/corner_page.dart';
import 'package:boxer_os/pages/facts_page.dart';
import 'package:boxer_os/pages/legends_page.dart';
import 'package:boxer_os/pages/quotes_page.dart';
import 'package:boxer_os/widgets/event_tile.dart';

Future<void> _pump(
  WidgetTester tester, {
  DateTime Function() clock = DateTime.now,
}) async {
  // A tall surface so every section, including the ones after the calendar
  // rows, sits inside the list's cache extent.
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(home: CornerPage(clock: clock)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the four sections', (tester) async {
    await _pump(tester);

    expect(find.text('Corner'), findsOneWidget);
    expect(find.text('LEGEND OF THE WEEK'), findsOneWidget);
    expect(find.text('All legends'), findsOneWidget);
    expect(find.text('NEXT UP'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('WORDS'), findsOneWidget);
    expect(find.text('Quotes'), findsOneWidget);
    expect(find.text('Did you know'), findsOneWidget);
  });

  testWidgets('shows the TODAY IN BOXING card on a date with an event', (
    tester,
  ) async {
    await _pump(tester, clock: () => DateTime(2026, 10, 30, 9));

    expect(find.text('TODAY IN BOXING'), findsOneWidget);
    expect(find.text('The Rumble in the Jungle'), findsOneWidget);
  });

  testWidgets('has no TODAY IN BOXING card on a date without an event', (
    tester,
  ) async {
    await _pump(tester, clock: () => DateTime(2026, 10, 29, 9));

    expect(find.text('TODAY IN BOXING'), findsNothing);
  });

  testWidgets("NEXT UP shows three tiles", (tester) async {
    await _pump(tester);

    expect(find.byType(EventTile), findsNWidgets(3));
  });

  testWidgets("tapping 'All legends' opens LegendsPage", (tester) async {
    await _pump(tester);

    await tester.tap(find.text('All legends'));
    await tester.pumpAndSettle();

    expect(find.byType(LegendsPage), findsOneWidget);
  });

  testWidgets("tapping 'Calendar' opens CalendarPage", (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarPage), findsOneWidget);
  });

  testWidgets("tapping 'Quotes' opens QuotesPage", (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Quotes'));
    await tester.pumpAndSettle();

    expect(find.byType(QuotesPage), findsOneWidget);
  });

  testWidgets("tapping 'Did you know' opens FactsPage", (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Did you know'));
    await tester.pumpAndSettle();

    expect(find.byType(FactsPage), findsOneWidget);
  });
}
