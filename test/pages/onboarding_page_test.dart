import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/pages/app_shell.dart';
import 'package:boxer_os/pages/onboarding_page.dart';
import 'package:boxer_os/providers/history_provider.dart';
import 'package:boxer_os/providers/settings_provider.dart';
import 'package:boxer_os/providers/shell_provider.dart';

class _Providers {
  _Providers(this.settings, this.history);

  final SettingsProvider settings;
  final HistoryProvider history;
}

Future<_Providers> _pump(WidgetTester tester) async {
  // Tall surface so every step's cards and the bottom action row are built.
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final settings = SettingsProvider();
  await settings.load();
  final history = HistoryProvider();
  await history.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: history),
        ChangeNotifierProvider(create: (_) => ShellProvider()),
      ],
      child: const MaterialApp(home: OnboardingPage()),
    ),
  );
  return _Providers(settings, history);
}

void main() {
  testWidgets('step one shows the wordmark, quote card and name field', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('BOXER OS'), findsOneWidget);
    expect(find.text('WHAT DO WE CALL YOU?'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('Next advances through the stance and level steps', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text('Which foot is forward?'), findsOneWidget);

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text('How far along are you?'), findsOneWidget);
    expect(find.text('START TRAINING'), findsOneWidget);
  });

  testWidgets('Back returns from the stance step to the name step', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();

    expect(find.text('BOXER OS'), findsOneWidget);
  });

  testWidgets('selecting Southpaw on the stance step calls setStance', (
    tester,
  ) async {
    final providers = await _pump(tester);
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Southpaw'));
    await tester.pump();

    expect(providers.settings.stance, Stance.southpaw);
  });

  testWidgets('selecting Advanced on the level step calls setDifficulty', (
    tester,
  ) async {
    final providers = await _pump(tester);
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Advanced'));
    await tester.pump();

    expect(providers.settings.difficulty, Difficulty.advanced);
  });

  testWidgets(
    'entering a name and finishing on the last step saves it and opens the shell',
    (tester) async {
      final providers = await _pump(tester);

      await tester.enterText(find.byType(TextField), 'Rocky');
      await tester.pump();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('START TRAINING'));
      // The shell's empty Progress state breathes forever, so settle a fixed
      // number of frames instead of pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(providers.settings.fighterName, 'Rocky');
      expect(providers.settings.onboardingDone, isTrue);
      expect(find.byType(AppShell), findsOneWidget);
    },
  );

  testWidgets('Skip on step one finishes onboarding with defaults', (
    tester,
  ) async {
    final providers = await _pump(tester);

    await tester.tap(find.text('Skip'));
    // The shell's empty Progress state breathes forever, so settle a fixed
    // number of frames instead of pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(providers.settings.onboardingDone, isTrue);
    expect(providers.settings.fighterName, isEmpty);
    expect(find.byType(AppShell), findsOneWidget);
  });
}
