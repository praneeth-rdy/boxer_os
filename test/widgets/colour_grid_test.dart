import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/reaction_colour.dart';
import 'package:boxer_os/widgets/colour_grid.dart';

Future<void> _pump(
  WidgetTester tester, {
  required void Function(ReactionColour) onColour,
  Widget? centre,
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 300,
        height: 300,
        child: ColourGrid(onColour: onColour, centre: centre),
      ),
    ),
  ),
);

void main() {
  testWidgets('shows all four colour labels', (tester) async {
    await _pump(tester, onColour: (_) {});

    expect(find.text('RED'), findsOneWidget);
    expect(find.text('MINT'), findsOneWidget);
    expect(find.text('AMBER'), findsOneWidget);
    expect(find.text('CHALK'), findsOneWidget);
  });

  testWidgets(
    'tapping each zone calls onColour with the matching ReactionColour',
    (tester) async {
      final tapped = <ReactionColour>[];
      await _pump(tester, onColour: tapped.add);

      await tester.tap(find.text('RED'));
      await tester.tap(find.text('MINT'));
      await tester.tap(find.text('AMBER'));
      await tester.tap(find.text('CHALK'));

      expect(tapped, [
        ReactionColour.red,
        ReactionColour.mint,
        ReactionColour.amber,
        ReactionColour.chalk,
      ]);
    },
  );

  testWidgets('each label is painted in the colour it names, kept readable', (
    tester,
  ) async {
    await _pump(tester, onColour: (_) {});

    final red = tester.widget<Text>(find.text('RED'));
    expect(red.style?.color, ReactionColour.red.onSwatch);
    final amber = tester.widget<Text>(find.text('AMBER'));
    expect(amber.style?.color, ReactionColour.amber.onSwatch);
  });

  testWidgets('centre widget is shown but ignores taps', (tester) async {
    var tapped = false;
    await _pump(
      tester,
      onColour: (_) => tapped = true,
      centre: const Text('GO'),
    );

    expect(find.text('GO'), findsOneWidget);

    // The centre overlay ignores pointers, so a tap on it falls through to
    // whichever zone sits underneath.
    await tester.tap(find.text('GO'), warnIfMissed: false);
    expect(tapped, isTrue);
  });
}
