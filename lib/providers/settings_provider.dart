import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/difficulty.dart';
import '../models/stance.dart';

/// Boxer preferences, persisted in `shared_preferences`.
class SettingsProvider extends ChangeNotifier {
  static const String stanceKey = 'stance';
  static const String difficultyKey = 'difficulty';
  static const String soundEnabledKey = 'sound_enabled';
  static const String hapticsEnabledKey = 'haptics_enabled';
  static const String voiceEnabledKey = 'voice_enabled';
  static const String keepScreenOnKey = 'keep_screen_on';
  static const String fighterNameKey = 'fighter_name';
  static const String onboardingDoneKey = 'onboarding_done';
  static const String reminderEnabledKey = 'reminder_enabled';
  static const String reminderHourKey = 'reminder_hour';
  static const String reminderMinuteKey = 'reminder_minute';
  static const String streakNudgeEnabledKey = 'streak_nudge_enabled';
  static const String eventRemindersEnabledKey = 'event_reminders_enabled';

  static const int _maxFighterNameLength = 24;
  static const int _defaultReminderHour = 18;

  Stance _stance = Stance.orthodox;
  Difficulty _difficulty = Difficulty.beginner;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  bool _voiceEnabled = true;
  bool _keepScreenOn = true;
  String _fighterName = '';
  bool _onboardingDone = false;
  bool _reminderEnabled = false;
  int _reminderHour = _defaultReminderHour;
  int _reminderMinute = 0;
  bool _streakNudgeEnabled = false;
  bool _eventRemindersEnabled = false;
  bool _isLoaded = false;
  String? _error;

  Stance get stance => _stance;
  Difficulty get difficulty => _difficulty;
  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get voiceEnabled => _voiceEnabled;
  bool get keepScreenOn => _keepScreenOn;
  String get fighterName => _fighterName;
  bool get onboardingDone => _onboardingDone;
  bool get reminderEnabled => _reminderEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;
  bool get streakNudgeEnabled => _streakNudgeEnabled;
  bool get eventRemindersEnabled => _eventRemindersEnabled;
  bool get isLoaded => _isLoaded;
  String? get error => _error;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _stance = Stance.fromName(prefs.getString(stanceKey));
      _difficulty = Difficulty.fromName(prefs.getString(difficultyKey));
      _soundEnabled = prefs.getBool(soundEnabledKey) ?? true;
      _hapticsEnabled = prefs.getBool(hapticsEnabledKey) ?? true;
      _voiceEnabled = prefs.getBool(voiceEnabledKey) ?? true;
      _keepScreenOn = prefs.getBool(keepScreenOnKey) ?? true;
      _fighterName = prefs.getString(fighterNameKey) ?? '';
      _onboardingDone = prefs.getBool(onboardingDoneKey) ?? false;
      _reminderEnabled = prefs.getBool(reminderEnabledKey) ?? false;
      _reminderHour = prefs.getInt(reminderHourKey) ?? _defaultReminderHour;
      _reminderMinute = prefs.getInt(reminderMinuteKey) ?? 0;
      _streakNudgeEnabled = prefs.getBool(streakNudgeEnabledKey) ?? false;
      _eventRemindersEnabled = prefs.getBool(eventRemindersEnabledKey) ?? false;
      _error = null;
    } catch (failure) {
      _error = 'Could not read settings: $failure';
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setStance(Stance stance) async {
    _stance = stance;
    notifyListeners();
    await _write((prefs) => prefs.setString(stanceKey, stance.name));
  }

  Future<void> setDifficulty(Difficulty difficulty) async {
    _difficulty = difficulty;
    notifyListeners();
    await _write((prefs) => prefs.setString(difficultyKey, difficulty.name));
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    notifyListeners();
    await _write((prefs) => prefs.setBool(soundEnabledKey, enabled));
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
    notifyListeners();
    await _write((prefs) => prefs.setBool(hapticsEnabledKey, enabled));
  }

  Future<void> setVoiceEnabled(bool enabled) async {
    _voiceEnabled = enabled;
    notifyListeners();
    await _write((prefs) => prefs.setBool(voiceEnabledKey, enabled));
  }

  Future<void> setKeepScreenOn(bool enabled) async {
    _keepScreenOn = enabled;
    notifyListeners();
    await _write((prefs) => prefs.setBool(keepScreenOnKey, enabled));
  }

  Future<void> setFighterName(String name) async {
    final trimmed = name.trim();
    final stored = trimmed.length > _maxFighterNameLength
        ? trimmed.substring(0, _maxFighterNameLength)
        : trimmed;
    _fighterName = stored;
    notifyListeners();
    await _write((prefs) => prefs.setString(fighterNameKey, stored));
  }

  Future<void> setOnboardingDone(bool done) async {
    _onboardingDone = done;
    notifyListeners();
    await _write((prefs) => prefs.setBool(onboardingDoneKey, done));
  }

  Future<void> setReminderEnabled(bool enabled) async {
    _reminderEnabled = enabled;
    notifyListeners();
    await _write((prefs) => prefs.setBool(reminderEnabledKey, enabled));
  }

  Future<void> setReminderTime(int hour, int minute) async {
    _reminderHour = hour;
    _reminderMinute = minute;
    notifyListeners();
    await _write((prefs) async {
      await prefs.setInt(reminderHourKey, hour);
      await prefs.setInt(reminderMinuteKey, minute);
    });
  }

  Future<void> setStreakNudgeEnabled(bool enabled) async {
    _streakNudgeEnabled = enabled;
    notifyListeners();
    await _write((prefs) => prefs.setBool(streakNudgeEnabledKey, enabled));
  }

  Future<void> setEventRemindersEnabled(bool enabled) async {
    _eventRemindersEnabled = enabled;
    notifyListeners();
    await _write((prefs) => prefs.setBool(eventRemindersEnabledKey, enabled));
  }

  /// Keeps the in-memory value whatever the platform does; failures surface on [error].
  Future<void> _write(
    Future<void> Function(SharedPreferences prefs) write,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await write(prefs);
      _setError(null);
    } catch (failure) {
      _setError('Could not save settings: $failure');
    }
  }

  void _setError(String? message) {
    if (_error == message) {
      return;
    }
    _error = message;
    notifyListeners();
  }
}
