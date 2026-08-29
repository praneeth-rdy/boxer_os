import 'dart:async';

import '../models/session_event.dart';
import '../providers/session_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/cue_speech.dart';
import 'audio_service.dart';
import 'haptics_service.dart';
import 'voice_service.dart';
import 'wake_lock_service.dart';

/// Turns session events into bells, haptics, speech and the wake lock.
class CueController {
  CueController({
    required SessionProvider session,
    required SettingsProvider settings,
    required AudioService audio,
    required HapticsService haptics,
    required VoiceService voice,
    required WakeLockService wakeLock,
  }) : _session = session,
       _settings = settings,
       _audio = audio,
       _haptics = haptics,
       _voice = voice,
       _wakeLock = wakeLock {
    _events = session.events.listen(_onEvent);
    session.addListener(_onSessionChanged);
    unawaited(audio.init());
    unawaited(voice.init());
  }

  final SessionProvider _session;
  final SettingsProvider _settings;
  final AudioService _audio;
  final HapticsService _haptics;
  final VoiceService _voice;
  final WakeLockService _wakeLock;

  late final StreamSubscription<SessionEvent> _events;
  bool _wasActive = false;
  bool _isScreenHeldAwake = false;

  void dispose() {
    unawaited(_events.cancel());
    _session.removeListener(_onSessionChanged);
    _releaseScreen();
  }

  void _onEvent(SessionEvent event) {
    switch (event.type) {
      case SessionEventType.prepareStarted:
        _playSound(_audio.playWarning);
        _vibrate(_haptics.warning);
        _speak('Get ready');
      case SessionEventType.roundStarted:
        _playSound(_audio.playRoundStart);
        _vibrate(_haptics.roundStart);
        _speak(_roundAnnouncement(event.round));
      case SessionEventType.tenSecondWarning:
        _playSound(_audio.playWarning);
        _vibrate(_haptics.warning);
      case SessionEventType.finalThirty:
        _playSound(_audio.playFinalThirty);
        _vibrate(_haptics.finalThirty);
        _speak('Thirty seconds');
      case SessionEventType.cue:
        _playSound(_audio.playTick);
        _vibrate(_haptics.cue);
        _speak(cueToSpeech(event.cueText ?? ''));
      case SessionEventType.restStarted:
        _playSound(_audio.playRoundEnd);
        _vibrate(_haptics.roundEnd);
        _speak('Rest');
      case SessionEventType.roundSkipped:
        _vibrate(_haptics.cue);
      case SessionEventType.paused:
        _vibrate(_haptics.cue);
        _stopSpeaking();
      case SessionEventType.resumed:
        _vibrate(_haptics.cue);
      case SessionEventType.sessionCompleted:
        _playSound(_audio.playRoundEnd);
        _vibrate(_haptics.roundEnd);
        _speak('Session complete');
      case SessionEventType.sessionEnded:
        _vibrate(_haptics.roundEnd);
        _stopSpeaking();
    }
  }

  void _onSessionChanged() {
    final isActive = _session.isActive;
    if (isActive == _wasActive) return;
    _wasActive = isActive;
    if (!isActive) {
      _releaseScreen();
      return;
    }
    if (_settings.keepScreenOn) {
      _isScreenHeldAwake = true;
      unawaited(_wakeLock.enable());
    }
  }

  void _releaseScreen() {
    if (!_isScreenHeldAwake) return;
    _isScreenHeldAwake = false;
    unawaited(_wakeLock.disable());
  }

  /// One utterance, since a second [VoiceService.speak] would cut the first off.
  String _roundAnnouncement(int round) {
    final rounds = _session.workout?.rounds;
    final hasRound = rounds != null && round >= 1 && round <= rounds.length;
    final focus = hasRound ? rounds[round - 1].focus : '';
    return focus.isEmpty ? 'Round $round' : 'Round $round. $focus';
  }

  void _playSound(Future<bool> Function() play) {
    if (_settings.soundEnabled) unawaited(play());
  }

  void _vibrate(Future<bool> Function() pattern) {
    if (_settings.hapticsEnabled) unawaited(pattern());
  }

  void _speak(String text) {
    if (_settings.voiceEnabled && _voice.isAvailable) {
      unawaited(_voice.speak(text));
    }
  }

  void _stopSpeaking() {
    if (_settings.voiceEnabled && _voice.isAvailable) {
      unawaited(_voice.stop());
    }
  }
}
