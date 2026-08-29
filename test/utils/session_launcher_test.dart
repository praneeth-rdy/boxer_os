import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/round_spec.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/models/workout.dart';
import 'package:boxer_os/pages/session_page.dart';
import 'package:boxer_os/providers/session_provider.dart';
import 'package:boxer_os/providers/settings_provider.dart';
import 'package:boxer_os/utils/session_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const workout = Workout(
    id: 'w',
    name: 'Launcher Test',
    type: TrainingType.strength,
    difficulty: Difficulty.advanced,
    rounds: [RoundSpec(workSeconds: 60, restSeconds: 20)],
  );

  testWidgets(
    'starts the workout on SessionProvider and opens the session page',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final settings = SettingsProvider();
      await settings.load();
      await settings.setStance(Stance.southpaw);
      final session = SessionProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settings),
            ChangeNotifierProvider.value(value: session),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => startSession(context, workout),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pump();
      await tester.pump();

      expect(session.workout?.id, 'w');
      expect(session.stance, Stance.southpaw);
      expect(session.difficulty, Difficulty.advanced);
      expect(find.byType(SessionPage), findsOneWidget);

      session.reset();
    },
  );
}
