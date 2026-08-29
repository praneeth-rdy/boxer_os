import 'package:boxer_os/data/workout_library.dart';
import 'package:boxer_os/pages/train_page.dart';
import 'package:boxer_os/pages/session_page.dart';
import 'package:boxer_os/pages/workout_detail_page.dart';
import 'package:boxer_os/providers/session_provider.dart';
import 'package:boxer_os/providers/settings_provider.dart';
import 'package:boxer_os/widgets/workout_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SessionProvider> pump(WidgetTester tester) async {
    // Tall surface so every library tile lays out without scrolling.
    await tester.binding.setSurfaceSize(const Size(400, 4000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

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
        child: const MaterialApp(home: TrainPage()),
      ),
    );
    return session;
  }

  testWidgets('shows the quick timer card and a tile per library workout', (
    tester,
  ) async {
    final session = await pump(tester);

    expect(find.text('Quick start'), findsOneWidget);
    expect(find.byType(WorkoutTile), findsNWidgets(workoutLibrary.length));

    session.reset();
  });

  testWidgets('tapping a workout tile opens its detail page', (tester) async {
    final session = await pump(tester);
    final firstWorkout = workoutLibrary.first;

    await tester.tap(find.text(firstWorkout.name));
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutDetailPage), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(WorkoutDetailPage),
        matching: find.text(firstWorkout.name),
      ),
      findsOneWidget,
    );

    session.reset();
  });

  testWidgets('starting a workout from its detail page opens prepare', (
    tester,
  ) async {
    final session = await pump(tester);
    final firstWorkout = workoutLibrary.first;

    await tester.tap(find.text(firstWorkout.name));
    await tester.pumpAndSettle();
    await tester.tap(find.text('START WORKOUT'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(SessionPage), findsOneWidget);
    expect(find.text('GET READY'), findsOneWidget);

    session.reset();
  });
}
