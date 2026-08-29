import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/widgets/quick_action.dart';

void main() {
  testWidgets('shows the icon and label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickAction(
            label: 'Timer',
            icon: Icons.timer_rounded,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Timer'), findsOneWidget);
    expect(find.byIcon(Icons.timer_rounded), findsOneWidget);
  });

  testWidgets('tapping it calls onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickAction(
            label: 'Combos',
            icon: Icons.sports_mma_rounded,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(QuickAction));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
