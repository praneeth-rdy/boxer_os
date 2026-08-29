import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/data/combination_library.dart';
import 'package:boxer_os/models/combo_tag.dart';
import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/pages/combos_page.dart';
import 'package:boxer_os/pages/session_page.dart';
import 'package:boxer_os/providers/combos_provider.dart';
import 'package:boxer_os/providers/session_provider.dart';
import 'package:boxer_os/providers/settings_provider.dart';
import 'package:boxer_os/widgets/combo_tile.dart';

class _Providers {
  _Providers(this.settings, this.session, this.combos);

  final SettingsProvider settings;
  final SessionProvider session;
  final CombosProvider combos;
}

Future<_Providers> _pump(
  WidgetTester tester, {
  Difficulty difficulty = Difficulty.beginner,
}) async {
  await tester.binding.setSurfaceSize(const Size(400, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  SharedPreferences.setMockInitialValues({});
  final settings = SettingsProvider();
  await settings.load();
  await settings.setDifficulty(difficulty);
  final session = SessionProvider();
  final combos = CombosProvider();
  await combos.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider.value(value: combos),
      ],
      child: const MaterialApp(home: CombosPage()),
    ),
  );

  return _Providers(settings, session, combos);
}

Future<void> _openView(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  group('Generate view', () {
    testWidgets('shows the difficulty control and a New combo button', (
      tester,
    ) async {
      await _pump(tester, difficulty: Difficulty.intermediate);

      expect(find.text('Beginner'), findsOneWidget);
      expect(find.text('Intermediate'), findsWidgets);
      expect(find.text('Advanced'), findsOneWidget);
      expect(find.text('NEW COMBO'), findsOneWidget);
    });

    testWidgets('the bookmark toggles saving the generated combination', (
      tester,
    ) async {
      final providers = await _pump(tester);

      expect(providers.combos.saved, isEmpty);
      await tester.tap(find.byIcon(Icons.bookmark_border_rounded).first);
      await tester.pump();

      expect(providers.combos.saved, hasLength(1));
    });
  });

  group('Library view', () {
    testWidgets('lists 15 tiles for beginner and defaults to that filter', (
      tester,
    ) async {
      await _pump(tester, difficulty: Difficulty.beginner);

      await _openView(tester, 'Library');

      expect(find.byType(ComboTile), findsNWidgets(15));
    });

    testWidgets('filtering by tag narrows the list', (tester) async {
      await _pump(tester, difficulty: Difficulty.beginner);
      await _openView(tester, 'Library');

      await tester.tap(find.text('Offense'));
      await tester.pumpAndSettle();

      final expected = combinationsWhere(
        difficulty: Difficulty.beginner,
        tag: ComboTag.offense,
      );
      expect(find.byType(ComboTile), findsNWidgets(expected.length));
    });

    testWidgets('tapping a tile opens the detail sheet', (tester) async {
      await _pump(tester, difficulty: Difficulty.beginner);
      await _openView(tester, 'Library');

      final combination = combinationsWhere(
        difficulty: Difficulty.beginner,
      ).first;
      await tester.tap(find.text(combination.notation).first);
      await tester.pumpAndSettle();

      expect(find.text('PRACTICE THIS'), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.text(combination.spoken), findsOneWidget);
    });

    testWidgets('Save in the sheet toggles the icon on the library tile', (
      tester,
    ) async {
      final providers = await _pump(tester, difficulty: Difficulty.beginner);
      await _openView(tester, 'Library');

      final combination = combinationsWhere(
        difficulty: Difficulty.beginner,
      ).first;
      await tester.tap(find.text(combination.notation).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(providers.combos.isSaved(combination), isTrue);
      expect(find.text('SAVED'), findsOneWidget);
    });
  });

  group('Saved view', () {
    testWidgets('shows the empty state when nothing is saved', (tester) async {
      await _pump(tester);
      await _openView(tester, 'Saved');

      expect(find.text('NOTHING SAVED YET'), findsOneWidget);
      expect(find.text('BROWSE THE LIBRARY'), findsOneWidget);
      expect(find.byType(ComboTile), findsNothing);
    });

    testWidgets('Browse the library switches to the library segment', (
      tester,
    ) async {
      await _pump(tester);
      await _openView(tester, 'Saved');

      await tester.tap(find.text('BROWSE THE LIBRARY'));
      await tester.pumpAndSettle();

      expect(find.byType(ComboTile), findsNWidgets(15));
    });

    testWidgets('shows a saved tile once a combination is bookmarked', (
      tester,
    ) async {
      final providers = await _pump(tester, difficulty: Difficulty.beginner);
      final combination = combinationsWhere(
        difficulty: Difficulty.beginner,
      ).first;
      await providers.combos.toggleSaved(combination);

      await _openView(tester, 'Saved');

      expect(find.byType(ComboTile), findsOneWidget);
      expect(find.text('NOTHING SAVED YET'), findsNothing);
      expect(find.text('PRACTICE SAVED'), findsOneWidget);
    });

    testWidgets('toggling a saved tile removes it and shows the empty state', (
      tester,
    ) async {
      final providers = await _pump(tester, difficulty: Difficulty.beginner);
      final combination = combinationsWhere(
        difficulty: Difficulty.beginner,
      ).first;
      await providers.combos.toggleSaved(combination);

      await _openView(tester, 'Saved');
      await tester.tap(find.byIcon(Icons.bookmark_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text('NOTHING SAVED YET'), findsOneWidget);
    });

    testWidgets(
      'Practice saved opens the session page with a workout of the saved combos',
      (tester) async {
        final providers = await _pump(tester, difficulty: Difficulty.beginner);
        final combination = combinationsWhere(
          difficulty: Difficulty.beginner,
        ).first;
        await providers.combos.toggleSaved(combination);

        await _openView(tester, 'Saved');
        await tester.tap(find.text('PRACTICE SAVED'));
        await tester.pump();
        await tester.pump();

        expect(find.byType(SessionPage), findsOneWidget);
        final workout = providers.session.workout!;
        expect(workout.id, 'combo_practice');
        expect(workout.rounds.first.cues.first.text, combination.notation);

        providers.session.reset();
      },
    );
  });
}
