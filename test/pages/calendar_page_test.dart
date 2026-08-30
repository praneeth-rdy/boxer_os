import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/boxing_calendar.dart';
import 'package:boxer_os/pages/calendar_page.dart';
import 'package:boxer_os/widgets/event_tile.dart';

Future<void> _pump(WidgetTester tester) async {
  // A tall surface so every month group lays out without needing a real scroll.
  tester.view.physicalSize = const Size(393, 20000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const MaterialApp(home: CalendarPage()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the header and every month of the year', (tester) async {
    await _pump(tester);

    expect(find.text('Calendar'), findsOneWidget);
    expect(
      find.text("Anniversaries, birthdays and the sport's international days."),
      findsOneWidget,
    );
    for (var month = 1; month <= 12; month++) {
      // At least the month header; a month whose abbreviation matches its own
      // name in full (May) also shows it once per event that month.
      expect(
        find.text(monthName(month).toUpperCase()),
        findsAtLeastNWidgets(1),
      );
    }
  });

  testWidgets('renders one EventTile per bundled event', (tester) async {
    await _pump(tester);

    expect(find.byType(EventTile), findsNWidgets(boxingCalendar.length));
  });

  testWidgets('shows the title of a known bundled event', (tester) async {
    await _pump(tester);

    expect(find.text('The Rumble in the Jungle'), findsOneWidget);
    expect(find.text('George Foreman born'), findsOneWidget);
  });
}
