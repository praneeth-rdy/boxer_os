import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/round_spec.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/models/workout.dart';
import 'package:boxer_os/widgets/workout_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const workout = Workout(
    id: 'test',
    name: 'Test Workout',
    type: TrainingType.heavyBag,
    difficulty: Difficulty.intermediate,
    rounds: [
      RoundSpec(workSeconds: 120, restSeconds: 60),
      RoundSpec(workSeconds: 120, restSeconds: 60),
    ],
  );

  testWidgets('shows the name, shape and estimated minutes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkoutTile(workout: workout, onTap: () {}),
        ),
      ),
    );

    expect(find.text('Test Workout'), findsOneWidget);
    expect(find.text('2 x 2:00 · Intermediate'), findsOneWidget);
    expect(find.text('${workout.estimatedMinutes}'), findsOneWidget);
    expect(find.text('MIN'), findsOneWidget);
  });

  testWidgets('the whole tile is tappable', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkoutTile(workout: workout, onTap: () => taps++),
        ),
      ),
    );

    await tester.tap(find.text('Test Workout'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('is at least 72dp tall', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkoutTile(workout: workout, onTap: () {}),
        ),
      ),
    );

    final size = tester.getSize(find.byType(WorkoutTile));
    expect(size.height, greaterThanOrEqualTo(72));
  });
}
