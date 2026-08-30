import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/pages/combos_page.dart';
import 'package:boxer_os/pages/footwork_page.dart';
import 'package:boxer_os/pages/reaction_page.dart';
import 'package:boxer_os/pages/skills_page.dart';
import 'package:boxer_os/providers/combos_provider.dart';
import 'package:boxer_os/providers/history_provider.dart';
import 'package:boxer_os/providers/reaction_provider.dart';
import 'package:boxer_os/providers/session_provider.dart';
import 'package:boxer_os/providers/settings_provider.dart';
import 'package:boxer_os/services/audio_service.dart';

Future<void> _pump(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final settings = SettingsProvider();
  await settings.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => ReactionProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => CombosProvider()),
        Provider<AudioService>(create: (_) => AudioService()),
      ],
      child: const MaterialApp(home: SkillsPage()),
    ),
  );
}

void main() {
  testWidgets('shows the three skill cards with no SOON badge', (tester) async {
    await _pump(tester);

    expect(find.text('Combos'), findsOneWidget);
    expect(find.text('Reaction'), findsOneWidget);
    expect(find.text('Footwork'), findsOneWidget);
    expect(find.text('Legends'), findsNothing);
    expect(find.text('SOON'), findsNothing);
  });

  testWidgets('tapping Combos opens the combination generator', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Combos'));
    await tester.pumpAndSettle();

    expect(find.byType(CombosPage), findsOneWidget);
  });

  testWidgets('tapping Reaction opens the reaction page', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Reaction'));
    await tester.pumpAndSettle();

    expect(find.byType(ReactionPage), findsOneWidget);
  });

  testWidgets('tapping Footwork opens the footwork page', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Footwork'));
    await tester.pumpAndSettle();

    expect(find.byType(FootworkPage), findsOneWidget);
  });
}
