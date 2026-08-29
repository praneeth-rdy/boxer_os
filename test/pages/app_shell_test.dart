import 'package:boxer_os/main.dart';
import 'package:boxer_os/providers/combos_provider.dart';
import 'package:boxer_os/providers/history_provider.dart';
import 'package:boxer_os/providers/session_provider.dart';
import 'package:boxer_os/providers/settings_provider.dart';
import 'package:boxer_os/services/notification_service.dart';
import 'package:boxer_os/services/voice_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows four tabs and switches page on tap', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_done': true});
    final settings = SettingsProvider();
    await settings.load();

    await tester.pumpWidget(
      BoxerOsApp(
        settings: settings,
        session: SessionProvider(),
        history: HistoryProvider(),
        combos: CombosProvider(),
        voice: VoiceService(),
        notifications: NotificationService(),
      ),
    );
    // Progress lives in the shell's IndexedStack, and its empty state's
    // breathing dot loops forever, so settle a fixed number of frames.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Train'), findsOneWidget);
    expect(find.text('Skills'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('BOXER OS'), findsOneWidget);

    await tester.tap(find.text('Train'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Train'), findsWidgets);
    expect(find.text('Quick start'), findsOneWidget);
  });
}
