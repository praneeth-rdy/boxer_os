import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/quotes.dart';
import 'package:boxer_os/widgets/quote_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  final quote = quoteFor(QuoteSurface.home, DateTime(2026, 1, 1));

  testWidgets('with cycles false shows the quote and no tap hint', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(QuoteCard(quote: quote)));

    expect(find.text(quote.text), findsOneWidget);
    expect(find.text('Tap for another'), findsNothing);
  });

  testWidgets('with cycles true shows the tap hint and swaps on tap', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(QuoteCard(quote: quote, cycles: true)));

    expect(find.text(quote.text), findsOneWidget);
    expect(find.text('Tap for another'), findsOneWidget);

    await tester.tap(find.byType(QuoteCard));
    await tester.pumpAndSettle();

    final next = quoteAfter(quote);
    expect(find.text(next.text), findsOneWidget);
    expect(find.text(quote.text), findsNothing);
  });

  testWidgets('repeated taps keep walking the rotation', (tester) async {
    await tester.pumpWidget(_wrap(QuoteCard(quote: quote, cycles: true)));

    await tester.tap(find.byType(QuoteCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(QuoteCard));
    await tester.pumpAndSettle();

    final expected = quoteAfter(quoteAfter(quote));
    expect(find.text(expected.text), findsOneWidget);
  });
}
