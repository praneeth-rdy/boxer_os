import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'pages/app_shell.dart';
import 'pages/onboarding_page.dart';
import 'providers/combos_provider.dart';
import 'providers/history_provider.dart';
import 'providers/reaction_provider.dart';
import 'providers/session_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/shell_provider.dart';
import 'services/audio_service.dart';
import 'services/cue_controller.dart';
import 'services/haptics_service.dart';
import 'services/notification_service.dart';
import 'services/reminder_scheduler.dart';
import 'services/voice_service.dart';
import 'services/wake_lock_service.dart';
import 'theme/app_theme.dart';

/// Held for the life of the process so the cue subscriptions stay alive.
late final CueController cues;

/// Held for the life of the process so the reminder listeners stay alive.
late final ReminderScheduler reminders;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surfaceRaised,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  final settings = SettingsProvider();
  await settings.load();
  final history = HistoryProvider();
  await history.load();
  final combos = CombosProvider();
  await combos.load();
  final session = SessionProvider();
  final audio = AudioService();
  final haptics = HapticsService();
  final voice = VoiceService();
  final wakeLock = WakeLockService();
  cues = CueController(
    session: session,
    settings: settings,
    audio: audio,
    haptics: haptics,
    voice: voice,
    wakeLock: wakeLock,
  );
  final notifications = NotificationService();
  await notifications.init();
  reminders = ReminderScheduler(
    settings: settings,
    history: history,
    notifications: notifications,
  );
  runApp(
    BoxerOsApp(
      settings: settings,
      session: session,
      history: history,
      combos: combos,
      voice: voice,
      notifications: notifications,
    ),
  );
}

class BoxerOsApp extends StatelessWidget {
  const BoxerOsApp({
    required this.settings,
    required this.session,
    required this.history,
    required this.combos,
    required this.voice,
    required this.notifications,
    super.key,
  });

  final SettingsProvider settings;
  final SessionProvider session;
  final HistoryProvider history;
  final CombosProvider combos;
  final VoiceService voice;
  final NotificationService notifications;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider.value(value: history),
        ChangeNotifierProvider.value(value: combos),
        ChangeNotifierProvider(create: (_) => ReactionProvider()),
        ChangeNotifierProvider(create: (_) => ShellProvider()),
        Provider<VoiceService>.value(value: voice),
        Provider<NotificationService>.value(value: notifications),
      ],
      child: MaterialApp(
        title: 'Boxer OS',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: settings.onboardingDone
            ? const AppShell()
            : const OnboardingPage(),
      ),
    );
  }
}
