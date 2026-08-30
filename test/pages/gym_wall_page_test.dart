import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/posters.dart';
import 'package:boxer_os/models/poster.dart';
import 'package:boxer_os/pages/gym_wall_page.dart';
import 'package:boxer_os/pages/poster_page.dart';
import 'package:boxer_os/widgets/phone_preview.dart';

int _gridItemCount(WidgetTester tester) {
  final grid = tester.widget<GridView>(find.byType(GridView));
  final delegate = grid.childrenDelegate as SliverChildBuilderDelegate;
  return delegate.childCount!;
}

void main() {
  testWidgets('shows the header, the blurb and a chip per poster kind', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GymWallPage()));
    await tester.pumpAndSettle();

    expect(find.text('Gym Wall'), findsOneWidget);
    expect(
      find.text('Posters in the Boxer OS style for your home and lock screen.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Taglines'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Legends'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Moments'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Inspiration'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Quotes'), findsOneWidget);
    expect(
      find.byType(ChoiceChip),
      findsNWidgets(PosterKind.values.length + 1),
    );
  });

  testWidgets('the grid holds every poster with no filter selected', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GymWallPage()));
    await tester.pumpAndSettle();

    expect(_gridItemCount(tester), posters().length);
  });

  testWidgets('the Taglines chip filters the grid to the 4 tagline posters', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GymWallPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Taglines'));
    await tester.pumpAndSettle();

    expect(_gridItemCount(tester), 4);
  });

  testWidgets('the Moments chip filters the grid to the moment posters', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GymWallPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Moments'));
    await tester.pumpAndSettle();

    expect(
      _gridItemCount(tester),
      posters().where((poster) => poster.kind == PosterKind.moment).length,
    );
  });

  testWidgets(
    'the Inspiration chip filters the grid to the inspiration posters',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GymWallPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Inspiration'));
      await tester.pumpAndSettle();

      expect(
        _gridItemCount(tester),
        posters()
            .where((poster) => poster.kind == PosterKind.inspiration)
            .length,
      );
    },
  );

  testWidgets('tapping a poster opens PosterPage for that poster', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GymWallPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PhonePreview).first);
    await tester.pumpAndSettle();

    expect(find.byType(PosterPage), findsOneWidget);
  });
}
