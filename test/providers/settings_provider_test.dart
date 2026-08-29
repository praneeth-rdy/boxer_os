import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/providers/settings_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// In-memory store that fails on demand, to exercise the provider's error path.
class _FailingStore extends InMemorySharedPreferencesStore {
  _FailingStore.withData(
    super.data, {
    this.failGetAll = false,
    this.failSetValue = false,
  }) : super.withData();

  final bool failGetAll;
  final bool failSetValue;

  @override
  Future<Map<String, Object>> getAll() async {
    if (failGetAll) {
      throw Exception('disk unavailable');
    }
    return super.getAll();
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (failSetValue) {
      throw Exception('disk full');
    }
    return super.setValue(valueType, key, value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsProvider.load', () {
    test(
      'with empty prefs yields orthodox, beginner and all flags true',
      () async {
        final settings = SettingsProvider();

        await settings.load();

        expect(settings.isLoaded, isTrue);
        expect(settings.stance, Stance.orthodox);
        expect(settings.difficulty, Difficulty.beginner);
        expect(settings.soundEnabled, isTrue);
        expect(settings.hapticsEnabled, isTrue);
        expect(settings.voiceEnabled, isTrue);
        expect(settings.keepScreenOn, isTrue);
        expect(settings.reminderEnabled, isFalse);
        expect(settings.reminderHour, 18);
        expect(settings.reminderMinute, 0);
        expect(settings.streakNudgeEnabled, isFalse);
        expect(settings.error, isNull);
      },
    );

    test('with stored values yields them', () async {
      SharedPreferences.setMockInitialValues({
        'stance': 'southpaw',
        'difficulty': 'advanced',
        'sound_enabled': false,
        'haptics_enabled': false,
        'voice_enabled': false,
        'keep_screen_on': false,
        'reminder_enabled': true,
        'reminder_hour': 7,
        'reminder_minute': 15,
        'streak_nudge_enabled': true,
      });
      final settings = SettingsProvider();

      await settings.load();

      expect(settings.stance, Stance.southpaw);
      expect(settings.difficulty, Difficulty.advanced);
      expect(settings.soundEnabled, isFalse);
      expect(settings.hapticsEnabled, isFalse);
      expect(settings.voiceEnabled, isFalse);
      expect(settings.keepScreenOn, isFalse);
      expect(settings.reminderEnabled, isTrue);
      expect(settings.reminderHour, 7);
      expect(settings.reminderMinute, 15);
      expect(settings.streakNudgeEnabled, isTrue);
    });

    test('an unknown stored stance name falls back to orthodox', () async {
      SharedPreferences.setMockInitialValues({'stance': 'garbage'});
      final settings = SettingsProvider();

      await settings.load();

      expect(settings.stance, Stance.orthodox);
    });

    test(
      'a failing prefs read leaves defaults, marks loaded and sets error',
      () async {
        SharedPreferencesStorePlatform.instance = _FailingStore.withData(
          <String, Object>{},
          failGetAll: true,
        );
        final settings = SettingsProvider();

        await settings.load();

        expect(settings.isLoaded, isTrue);
        expect(settings.stance, Stance.orthodox);
        expect(settings.error, isNotNull);
      },
    );
  });

  group('SettingsProvider setters', () {
    test('setStance updates the value and persists it', () async {
      final settings = SettingsProvider();
      await settings.load();

      await settings.setStance(Stance.southpaw);

      expect(settings.stance, Stance.southpaw);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('stance'), 'southpaw');
    });

    test('setDifficulty updates the value and persists it', () async {
      final settings = SettingsProvider();
      await settings.load();

      await settings.setDifficulty(Difficulty.intermediate);

      expect(settings.difficulty, Difficulty.intermediate);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('difficulty'), 'intermediate');
    });

    test('setSoundEnabled updates the value and persists it', () async {
      final settings = SettingsProvider();
      await settings.load();

      await settings.setSoundEnabled(false);

      expect(settings.soundEnabled, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('sound_enabled'), isFalse);
    });

    test('setHapticsEnabled updates the value and persists it', () async {
      final settings = SettingsProvider();
      await settings.load();

      await settings.setHapticsEnabled(false);

      expect(settings.hapticsEnabled, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('haptics_enabled'), isFalse);
    });

    test('setVoiceEnabled updates the value and persists it', () async {
      final settings = SettingsProvider();
      await settings.load();

      await settings.setVoiceEnabled(false);

      expect(settings.voiceEnabled, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('voice_enabled'), isFalse);
    });

    test('setKeepScreenOn updates the value and persists it', () async {
      final settings = SettingsProvider();
      await settings.load();

      await settings.setKeepScreenOn(false);

      expect(settings.keepScreenOn, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('keep_screen_on'), isFalse);
    });

    test('setReminderEnabled updates the value and persists it', () async {
      final settings = SettingsProvider();
      await settings.load();

      await settings.setReminderEnabled(true);

      expect(settings.reminderEnabled, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('reminder_enabled'), isTrue);
    });

    test(
      'setReminderTime updates the hour and minute and persists them',
      () async {
        final settings = SettingsProvider();
        await settings.load();

        await settings.setReminderTime(6, 45);

        expect(settings.reminderHour, 6);
        expect(settings.reminderMinute, 45);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('reminder_hour'), 6);
        expect(prefs.getInt('reminder_minute'), 45);
      },
    );

    test('setStreakNudgeEnabled updates the value and persists it', () async {
      final settings = SettingsProvider();
      await settings.load();

      await settings.setStreakNudgeEnabled(true);

      expect(settings.streakNudgeEnabled, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('streak_nudge_enabled'), isTrue);
    });

    test(
      'a failing prefs write leaves the in-memory value set and sets error',
      () async {
        final settings = SettingsProvider();
        await settings.load();
        SharedPreferencesStorePlatform.instance = _FailingStore.withData(
          <String, Object>{},
          failSetValue: true,
        );

        await settings.setStance(Stance.southpaw);

        expect(settings.stance, Stance.southpaw);
        expect(settings.error, isNotNull);
      },
    );
  });
}
