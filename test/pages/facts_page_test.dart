import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/boxing_facts.dart';
import 'package:boxer_os/pages/facts_page.dart';
import 'package:boxer_os/widgets/fact_card.dart';

Future<void> _pump(WidgetTester tester) async {
  // Tall enough that the lazy ListView.builder lays out every card.
  tester.view.physicalSize = const Size(800, 20000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const MaterialApp(home: FactsPage()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the header and all 40 facts', (tester) async {
    await _pump(tester);

    expect(find.text('Did you know'), findsOneWidget);
    expect(find.byType(FactCard), findsNWidgets(boxingFacts.length));
  });
}
