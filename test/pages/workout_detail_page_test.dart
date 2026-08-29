import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/round_cue.dart';
import 'package:boxer_os/models/round_spec.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/models/workout.dart';
import 'package:boxer_os/pages/session_page.dart';
import 'package:boxer_os/pages/workout_detail_page.dart';
import 'package:boxer_os/providers/session_provider.dart';
import 'package:boxer_os/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const workout = Workout(
    id: 'test',
    name: 'Detail Test',
    type: TrainingType.mittWork,
    difficulty: Difficulty.advanced,
    description: 'A short description.',
    rounds: [
      RoundSpec(
        workSeconds: 90,
        restSeconds: 30,
        focus: 'Combos',
        cues: [RoundCue(atSecond: 5, text: '1-2')],
      ),
      RoundSpec(workSeconds: 90, restSeconds: 30),
    ],
  );

  Future<SessionProvider> pump(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsProvider();
    await settings.load();
    final session = SessionProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: session),
        ],
        child: const MaterialApp(home: WorkoutDetailPage(workout: workout)),
      ),
    );
    return session;
  }

  testWidgets('shows the workout stats and each round', (tester) async {
    final session = await pump(tester);

    expect(find.text('Detail Test'), findsOneWidget);
    expect(find.text('A short description.'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // rounds stat
    expect(find.text('1:30'), findsOneWidget); // work per round
    expect(find.text('R1'), findsOneWidget);
    expect(find.text('R2'), findsOneWidget);
    expect(find.text('Combos'), findsOneWidget);
    expect(find.text('Free round'), findsOneWidget); // round 2 has no focus
    expect(find.textContaining('1 cue'), findsOneWidget);

    session.reset();
  });

  testWidgets('Start workout opens the session page', (tester) async {
    final session = await pump(tester);

    await tester.tap(find.text('START WORKOUT'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(SessionPage), findsOneWidget);
    expect(session.workout?.id, 'test');

    session.reset();
  });
}
