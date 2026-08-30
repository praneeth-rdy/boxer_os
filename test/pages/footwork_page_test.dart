import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/footwork_drills.dart';
import 'package:boxer_os/pages/footwork_page.dart';
import 'package:boxer_os/widgets/workout_tile.dart';

void main() {
  testWidgets('lists a tile for every footwork drill', (tester) async {
    // Tall surface so the whole catalogue builds instead of scrolling lazily.
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: FootworkPage()));

    expect(find.byType(WorkoutTile), findsNWidgets(footworkDrills.length));
    for (final drill in footworkDrills) {
      expect(find.text(drill.name), findsOneWidget);
    }
  });

  testWidgets('tapping a drill opens its detail page with a start button', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: FootworkPage()));

    final firstDrill = footworkDrills.first;
    await tester.tap(find.text(firstDrill.name));
    await tester.pumpAndSettle();

    expect(find.text(firstDrill.name), findsOneWidget);
    expect(find.text('START WORKOUT'), findsOneWidget);
  });
}
