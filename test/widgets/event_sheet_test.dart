import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/boxing_event.dart';
import 'package:boxer_os/pages/legend_story_page.dart';
import 'package:boxer_os/widgets/event_sheet.dart';

const BoxingEvent _withLegend = BoxingEvent(
  month: 10,
  day: 30,
  year: 1974,
  title: 'The Rumble in the Jungle',
  blurb:
      'Kinshasa. Muhammad Ali knocks out George Foreman in the eighth round '
      'to regain the heavyweight title.',
  kind: EventKind.anniversary,
  legendId: 'ali',
);

const BoxingEvent _withoutLegend = BoxingEvent(
  month: 4,
  day: 6,
  title: 'International Day of Sport for Development and Peace',
  blurb:
      'A United Nations day marking the opening of the first modern Olympic '
      'Games in Athens in 1896.',
  kind: EventKind.internationalDay,
);

Future<void> _open(WidgetTester tester, BoxingEvent event) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showEventSheet(context, event),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the title, date line and kind chip', (tester) async {
    await _open(tester, _withLegend);

    expect(find.text('The Rumble in the Jungle'), findsOneWidget);
    expect(find.text('30 OCTOBER 1974'), findsOneWidget);
    expect(find.text('Anniversary'), findsOneWidget);
  });

  testWidgets('shows the date line without a year as an annual day', (
    tester,
  ) async {
    await _open(tester, _withoutLegend);

    expect(find.text('6 APRIL, EVERY YEAR'), findsOneWidget);
    expect(find.text('International day'), findsOneWidget);
  });

  testWidgets(
    "shows 'Read the legend' for an event with a legendId and opens the "
    'right story',
    (tester) async {
      await _open(tester, _withLegend);

      expect(find.text('READ THE LEGEND'), findsOneWidget);

      await tester.tap(find.text('READ THE LEGEND'));
      await tester.pumpAndSettle();

      final story = tester.widget<LegendStoryPage>(
        find.byType(LegendStoryPage),
      );
      expect(story.legend.id, 'ali');
    },
  );

  testWidgets("has no 'Read the legend' button for an event with no legendId", (
    tester,
  ) async {
    await _open(tester, _withoutLegend);

    expect(find.text('READ THE LEGEND'), findsNothing);
  });
}
