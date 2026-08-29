import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/combination.dart';
import 'package:boxer_os/models/combo_tag.dart';
import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/widgets/combo_tile.dart';

const Combination _libraryCombo = Combination(
  id: 'c01',
  moves: ['1', '2'],
  difficulty: Difficulty.intermediate,
  seed: 0,
  name: 'One-two',
  tags: [ComboTag.counter, ComboTag.body],
);

const Combination _generatedCombo = Combination(
  moves: ['1', '2', '3'],
  difficulty: Difficulty.beginner,
  seed: 5,
);

Future<void> _pump(WidgetTester tester, ComboTile tile) {
  return tester.pumpWidget(MaterialApp(home: Scaffold(body: tile)));
}

void main() {
  testWidgets('a library combination shows its notation and name', (
    tester,
  ) async {
    await _pump(
      tester,
      ComboTile(
        combination: _libraryCombo,
        isSaved: false,
        onTap: () {},
        onToggleSaved: () {},
      ),
    );

    expect(find.text(_libraryCombo.notation), findsOneWidget);
    expect(find.text('One-two'), findsOneWidget);
    expect(find.text('Counter · Body · Intermediate'), findsOneWidget);
  });

  testWidgets(
    'a generated combination shows its spoken text instead of a name',
    (tester) async {
      await _pump(
        tester,
        ComboTile(
          combination: _generatedCombo,
          isSaved: false,
          onTap: () {},
          onToggleSaved: () {},
        ),
      );

      expect(find.text(_generatedCombo.notation), findsOneWidget);
      expect(find.text(_generatedCombo.spoken), findsOneWidget);
    },
  );

  testWidgets('tapping the tile calls onTap', (tester) async {
    var tapped = false;
    await _pump(
      tester,
      ComboTile(
        combination: _libraryCombo,
        isSaved: false,
        onTap: () => tapped = true,
        onToggleSaved: () {},
      ),
    );

    await tester.tap(find.text(_libraryCombo.notation));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('the bookmark icon reflects isSaved and toggles on tap', (
    tester,
  ) async {
    var toggled = false;
    await _pump(
      tester,
      ComboTile(
        combination: _libraryCombo,
        isSaved: true,
        onTap: () {},
        onToggleSaved: () => toggled = true,
      ),
    );

    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.bookmark_rounded));
    await tester.pump();

    expect(toggled, isTrue);
  });

  testWidgets('an unsaved combination shows the outline bookmark icon', (
    tester,
  ) async {
    await _pump(
      tester,
      ComboTile(
        combination: _libraryCombo,
        isSaved: false,
        onTap: () {},
        onToggleSaved: () {},
      ),
    );

    expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_rounded), findsNothing);
  });

  testWidgets('is at least 72dp tall', (tester) async {
    await _pump(
      tester,
      ComboTile(
        combination: _libraryCombo,
        isSaved: false,
        onTap: () {},
        onToggleSaved: () {},
      ),
    );

    final size = tester.getSize(find.byType(ComboTile));
    expect(size.height, greaterThanOrEqualTo(72));
  });
}
