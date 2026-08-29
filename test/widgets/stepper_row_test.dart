import 'package:boxer_os/widgets/stepper_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, StepperRow row) {
    return tester.pumpWidget(MaterialApp(home: Scaffold(body: row)));
  }

  testWidgets('shows the label uppercase and the value', (tester) async {
    await pump(
      tester,
      StepperRow(
        label: 'rounds',
        value: '3',
        onDecrement: () {},
        onIncrement: () {},
      ),
    );

    expect(find.text('ROUNDS'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('tapping the plus icon calls onIncrement', (tester) async {
    var increments = 0;
    await pump(
      tester,
      StepperRow(
        label: 'Rounds',
        value: '3',
        onDecrement: () {},
        onIncrement: () => increments++,
      ),
    );

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();

    expect(increments, 1);
  });

  testWidgets('tapping the minus icon calls onDecrement', (tester) async {
    var decrements = 0;
    await pump(
      tester,
      StepperRow(
        label: 'Rounds',
        value: '3',
        onDecrement: () => decrements++,
        onIncrement: () {},
      ),
    );

    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pump();

    expect(decrements, 1);
  });

  testWidgets('a null callback disables its button', (tester) async {
    var decrements = 0;
    await pump(
      tester,
      StepperRow(
        label: 'Rounds',
        value: '1',
        onDecrement: null,
        onIncrement: () => decrements++,
      ),
    );

    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pump();

    expect(decrements, 0);
  });
}
