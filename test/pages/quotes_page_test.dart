import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/quotes.dart';
import 'package:boxer_os/pages/quotes_page.dart';
import 'package:boxer_os/widgets/quote_card.dart';

final Finder _boxingChip = find.widgetWithText(ChoiceChip, 'Boxing');

const int _boxingCount = 52;

Future<void> _pump(WidgetTester tester) async {
  // Tall enough that the lazy ListView.builder lays out every card, so the
  // whole filtered list can be counted without scrolling.
  tester.view.physicalSize = const Size(800, 30000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const MaterialApp(home: QuotesPage()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the header and all 81 quotes with All selected', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Quotes'), findsOneWidget);
    expect(find.byType(QuoteCard), findsNWidgets(quotes.length));
  });

  testWidgets(
    "the Boxing chip filters to 52 quotes, counting 'Boxing trainer'",
    (tester) async {
      await _pump(tester);

      await tester.tap(_boxingChip);
      await tester.pumpAndSettle();

      expect(find.byType(QuoteCard), findsNWidgets(_boxingCount));
    },
  );
}
