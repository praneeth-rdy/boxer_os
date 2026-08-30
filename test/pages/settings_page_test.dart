import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/session_record.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/pages/about_page.dart';
import 'package:boxer_os/pages/settings_page.dart';
import 'package:boxer_os/providers/history_provider.dart';
import 'package:boxer_os/providers/settings_provider.dart';
import 'package:boxer_os/services/notification_service.dart';
import 'package:boxer_os/services/voice_service.dart';
import 'package:boxer_os/theme/app_theme.dart';
import 'package:boxer_os/widgets/pill_button.dart';

SessionRecord _session() => SessionRecord(
  id: 's',
  workoutId: 'shadow_foundations',
  workoutName: 'Shadow Foundations',
  type: TrainingType.shadowBoxing,
  difficulty: Difficulty.beginner,
  stance: Stance.orthodox,
  startedAt: DateTime.now(),
  durationSeconds: 180,
  roundsCompleted: 3,
  roundsPlanned: 3,
  completed: true,
);

/// Records whether [sayTest] was tapped and stands in for the real TTS
/// engine, which the widget test never touches.
class _FakeVoiceService extends VoiceService {
  _FakeVoiceService({String? name}) : _voiceName = name;

  final String? _voiceName;
  int sayTestCalls = 0;

  @override
  String? get voiceName => _voiceName;

  @override
  Future<bool> sayTest() async {
    sayTestCalls++;
    return true;
  }
}

/// Fake permission result, so the widget test never touches the platform plugin.
/// The delay stands in for the Android dialog the boxer has to answer.
class _FakeNotificationService extends NotificationService {
  _FakeNotificationService({this.permissionGranted = true});

  static const Duration dialogDelay = Duration(milliseconds: 300);

  final bool permissionGranted;
  int requestPermissionCalls = 0;

  @override
  Future<bool> requestPermission() async {
    requestPermissionCalls++;
    await Future<void>.delayed(dialogDelay);
    return permissionGranted;
  }
}

bool _switchIsOn(WidgetTester tester, String title) => tester
    .widget<SwitchListTile>(find.widgetWithText(SwitchListTile, title))
    .value;

class _Providers {
  _Providers(this.history, this.settings, this.voice, this.notifications);

  final HistoryProvider history;
  final SettingsProvider settings;
  final _FakeVoiceService voice;
  final _FakeNotificationService notifications;
}

Future<_Providers> _pump(
  WidgetTester tester, {
  String? voiceName,
  bool permissionGranted = true,
}) async {
  // The default 800x600 test surface clips the lower sections; grow it.
  tester.view.physicalSize = const Size(800, 1700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final settings = SettingsProvider();
  await settings.load();
  final history = HistoryProvider();
  await history.addSession(_session());
  final voice = _FakeVoiceService(name: voiceName);
  final notifications = _FakeNotificationService(
    permissionGranted: permissionGranted,
  );

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: history),
        ChangeNotifierProvider.value(value: settings),
        Provider<VoiceService>.value(value: voice),
        Provider<NotificationService>.value(value: notifications),
      ],
      child: const MaterialApp(home: SettingsPage()),
    ),
  );
  return _Providers(history, settings, voice, notifications);
}

void main() {
  testWidgets('shows the fighter profile sections and the version', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('STANCE'), findsOneWidget);
    expect(find.text('LEVEL'), findsOneWidget);
    expect(find.text('CUES'), findsOneWidget);
    expect(find.text('REMINDERS'), findsOneWidget);
    expect(find.text('DATA'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('About Boxer OS'),
      AppTheme.spaceXxl,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('ABOUT'), findsOneWidget);
    expect(find.text('About Boxer OS'), findsOneWidget);
    expect(
      find.text('Version ${AppTheme.appVersion}, license, privacy, credits'),
      findsOneWidget,
    );
  });

  testWidgets('tapping the About card pushes the About page', (tester) async {
    await _pump(tester);

    await tester.scrollUntilVisible(
      find.text('About Boxer OS'),
      AppTheme.spaceXxl,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('About Boxer OS'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.text('LICENSE'), findsOneWidget);
  });

  testWidgets('picking a stance segment calls setStance', (tester) async {
    final providers = await _pump(tester);
    expect(providers.settings.stance, Stance.orthodox);

    final southpaw = Stance.values.firstWhere((s) => s != Stance.orthodox);
    await tester.tap(find.text(southpaw.label));
    await tester.pumpAndSettle();

    expect(providers.settings.stance, southpaw);
  });

  testWidgets('picking a level segment calls setDifficulty', (tester) async {
    final providers = await _pump(tester);
    expect(providers.settings.difficulty, Difficulty.beginner);

    await tester.tap(find.text(Difficulty.advanced.label));
    await tester.pumpAndSettle();

    expect(providers.settings.difficulty, Difficulty.advanced);
  });

  testWidgets('toggling the Sound switch calls setSoundEnabled', (
    tester,
  ) async {
    final providers = await _pump(tester);
    expect(providers.settings.soundEnabled, isTrue);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Sound'));
    await tester.pumpAndSettle();

    expect(providers.settings.soundEnabled, isFalse);
  });

  testWidgets('toggling Keep screen on calls setKeepScreenOn', (tester) async {
    final providers = await _pump(tester);
    expect(providers.settings.keepScreenOn, isTrue);

    await tester.tap(
      find.widgetWithText(SwitchListTile, 'Keep screen on during sessions'),
    );
    await tester.pumpAndSettle();

    expect(providers.settings.keepScreenOn, isFalse);
  });

  testWidgets(
    'settings changes persist through a fresh SettingsProvider load',
    (tester) async {
      final providers = await _pump(tester);

      await tester.tap(find.widgetWithText(SwitchListTile, 'Haptics'));
      await tester.pumpAndSettle();
      expect(providers.settings.hapticsEnabled, isFalse);

      final reloaded = SettingsProvider();
      await reloaded.load();

      expect(reloaded.hapticsEnabled, isFalse);
    },
  );

  testWidgets(
    'clear history asks for confirmation and empties the provider on Delete',
    (tester) async {
      final providers = await _pump(tester);
      expect(providers.history.sessions, isNotEmpty);

      await tester.tap(find.text('CLEAR HISTORY'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Delete all sessions and reaction results? This cannot be undone.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(providers.history.sessions, isEmpty);
    },
  );

  testWidgets('clear history does nothing on Cancel', (tester) async {
    final providers = await _pump(tester);

    await tester.tap(find.text('CLEAR HISTORY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(providers.history.sessions, isNotEmpty);
  });

  testWidgets(
    'turning on Daily reminder requests permission and enables it when granted',
    (tester) async {
      final providers = await _pump(tester);
      expect(providers.settings.reminderEnabled, isFalse);

      await tester.tap(find.widgetWithText(SwitchListTile, 'Daily reminder'));
      await tester.pumpAndSettle();

      expect(providers.notifications.requestPermissionCalls, 1);
      expect(providers.settings.reminderEnabled, isTrue);
      expect(_switchIsOn(tester, 'Daily reminder'), isTrue);
      expect(
        find.text('Notifications are off for Boxer OS in Android settings.'),
        findsNothing,
      );
    },
  );

  testWidgets('the switch is still off while the permission dialog is open', (
    tester,
  ) async {
    final providers = await _pump(tester);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Daily reminder'));
    await tester.pump();

    expect(providers.settings.reminderEnabled, isFalse);
    expect(_switchIsOn(tester, 'Daily reminder'), isFalse);

    await tester.pumpAndSettle();

    expect(_switchIsOn(tester, 'Daily reminder'), isTrue);
  });

  testWidgets(
    'the switch stays off and shows a snackbar when permission is denied',
    (tester) async {
      final providers = await _pump(tester, permissionGranted: false);

      await tester.tap(find.widgetWithText(SwitchListTile, 'Daily reminder'));
      await tester.pumpAndSettle();

      expect(providers.settings.reminderEnabled, isFalse);
      expect(_switchIsOn(tester, 'Daily reminder'), isFalse);
      expect(
        find.text('Notifications are off for Boxer OS in Android settings.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('a granted permission survives leaving Settings mid-dialog', (
    tester,
  ) async {
    final providers = await _pump(tester);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Daily reminder'));
    await tester.pump();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: providers.history),
          ChangeNotifierProvider.value(value: providers.settings),
          Provider<VoiceService>.value(value: providers.voice),
          Provider<NotificationService>.value(value: providers.notifications),
        ],
        child: const MaterialApp(home: Scaffold()),
      ),
    );
    // The replacement tree schedules no frames, so step past the dialog delay.
    await tester.pump(_FakeNotificationService.dialogDelay);
    await tester.pumpAndSettle();

    expect(providers.settings.reminderEnabled, isTrue);
  });

  testWidgets(
    'the Time row and its edit icon are disabled until the reminder is on',
    (tester) async {
      await _pump(tester);

      final editButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.edit_outlined),
      );
      expect(editButton.onPressed, isNull);
    },
  );

  testWidgets('the time row updates after picking a new time', (tester) async {
    final providers = await _pump(tester);
    await providers.settings.setReminderEnabled(true);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Change reminder time'));
    await tester.pumpAndSettle();

    // Switches the time picker from the dial into typed hour/minute fields.
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();

    // The initial 18:00 default leaves PM selected; force AM so entering "07"
    // means 07:45, not 19:45.
    final amButton = find.text('AM');
    if (amButton.evaluate().isNotEmpty) {
      await tester.tap(amButton);
      await tester.pumpAndSettle();
    }
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, '07');
    await tester.enterText(fields.last, '45');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(providers.settings.reminderHour, 7);
    expect(providers.settings.reminderMinute, 45);
  });

  testWidgets(
    'turning on Streak nudge requests permission and enables it when granted',
    (tester) async {
      final providers = await _pump(tester);
      expect(providers.settings.streakNudgeEnabled, isFalse);

      await tester.tap(find.widgetWithText(SwitchListTile, 'Streak nudge'));
      await tester.pumpAndSettle();

      expect(providers.notifications.requestPermissionCalls, 1);
      expect(providers.settings.streakNudgeEnabled, isTrue);
      expect(_switchIsOn(tester, 'Streak nudge'), isTrue);
    },
  );

  testWidgets(
    'Streak nudge stays off and shows a snackbar when permission is denied',
    (tester) async {
      final providers = await _pump(tester, permissionGranted: false);

      await tester.tap(find.widgetWithText(SwitchListTile, 'Streak nudge'));
      await tester.pumpAndSettle();

      expect(providers.settings.streakNudgeEnabled, isFalse);
      expect(_switchIsOn(tester, 'Streak nudge'), isFalse);
      expect(
        find.text('Notifications are off for Boxer OS in Android settings.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'turning on Boxing days requests permission and enables it when granted',
    (tester) async {
      final providers = await _pump(tester);
      expect(providers.settings.eventRemindersEnabled, isFalse);

      await tester.tap(find.widgetWithText(SwitchListTile, 'Boxing days'));
      await tester.pumpAndSettle();

      expect(providers.notifications.requestPermissionCalls, 1);
      expect(providers.settings.eventRemindersEnabled, isTrue);
      expect(_switchIsOn(tester, 'Boxing days'), isTrue);
    },
  );

  testWidgets(
    'Boxing days stays off and shows a snackbar when permission is denied',
    (tester) async {
      final providers = await _pump(tester, permissionGranted: false);

      await tester.tap(find.widgetWithText(SwitchListTile, 'Boxing days'));
      await tester.pumpAndSettle();

      expect(providers.settings.eventRemindersEnabled, isFalse);
      expect(_switchIsOn(tester, 'Boxing days'), isFalse);
      expect(
        find.text('Notifications are off for Boxer OS in Android settings.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('shows the chosen voice name in the caption', (tester) async {
    await _pump(tester, voiceName: 'en-us-local');

    expect(find.text('TEST VOICE'), findsOneWidget);
    expect(find.text('Voice: en-us-local'), findsOneWidget);
  });

  testWidgets('shows the system default caption when no voice was chosen', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Voice: system default'), findsOneWidget);
  });

  testWidgets('tapping Test voice calls sayTest on the voice service', (
    tester,
  ) async {
    final providers = await _pump(tester, voiceName: 'en-us-local');
    expect(providers.settings.voiceEnabled, isTrue);

    await tester.tap(find.text('TEST VOICE'));
    await tester.pumpAndSettle();

    expect(providers.voice.sayTestCalls, 1);
  });

  testWidgets('Test voice is disabled when the Voice switch is off', (
    tester,
  ) async {
    final providers = await _pump(tester, voiceName: 'en-us-local');

    await tester.tap(find.widgetWithText(SwitchListTile, 'Voice'));
    await tester.pumpAndSettle();
    expect(providers.settings.voiceEnabled, isFalse);

    final button = tester.widget<PillButton>(
      find.ancestor(
        of: find.text('TEST VOICE'),
        matching: find.byType(PillButton),
      ),
    );
    expect(button.onPressed, isNull);

    await tester.tap(find.text('TEST VOICE'));
    await tester.pumpAndSettle();
    expect(providers.voice.sayTestCalls, 0);
  });
}
