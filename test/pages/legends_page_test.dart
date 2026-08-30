import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/legends.dart';
import 'package:boxer_os/pages/legend_story_page.dart';
import 'package:boxer_os/pages/legends_page.dart';
import 'package:boxer_os/widgets/legend_card.dart';

Future<void> _pump(WidgetTester tester) async {
  // A tall surface so all twelve cards lay out without a scroll during the test.
  tester.view.physicalSize = const Size(393, 6000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const MaterialApp(home: LegendsPage()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists a card for every bundled legend', (tester) async {
    await _pump(tester);

    expect(find.text('Legends'), findsOneWidget);
    expect(find.byType(LegendCard), findsNWidgets(legends.length));
    for (final legend in legends) {
      expect(find.text(legend.name), findsOneWidget);
    }
  });

  testWidgets('tapping a card opens its story page for that legend', (
    tester,
  ) async {
    await _pump(tester);
    final legend = legends.first;

    // The card's own InkWell sits above the name in the stack and takes the tap.
    await tester.tap(find.text(legend.name), warnIfMissed: false);
    await tester.pumpAndSettle();

    final story = tester.widget<LegendStoryPage>(find.byType(LegendStoryPage));
    expect(story.legend.id, legend.id);
  });

  testWidgets(
    'renders all twelve cards with no exceptions and each photo cropped '
    "to its legend's photoFocus",
    (tester) async {
      await _pump(tester);

      expect(tester.takeException(), isNull);
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(images, hasLength(legends.length));
      for (var index = 0; index < legends.length; index++) {
        expect(images[index].alignment, legends[index].photoFocus);
      }
    },
  );
}
