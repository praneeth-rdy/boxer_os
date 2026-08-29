import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/round_cue.dart';
import 'package:boxer_os/models/round_spec.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/models/workout.dart';
import 'package:boxer_os/providers/session_provider.dart';
import 'package:boxer_os/providers/settings_provider.dart';
import 'package:boxer_os/services/audio_service.dart';
import 'package:boxer_os/services/cue_controller.dart';
import 'package:boxer_os/services/haptics_service.dart';
import 'package:boxer_os/services/voice_service.dart';
import 'package:boxer_os/services/wake_lock_service.dart';

/// Records calls instead of touching a plugin, so a session can be driven
/// through [SessionProvider] and the resulting service calls asserted in order.
class _FakeAudioService extends AudioService {
  final calls = <String>[];

  /// Kept apart from [calls] so the muted-sound tests still see an empty list.
  int initCalls = 0;

  @override
  Future<bool> init() async {
    initCalls++;
    return true;
  }

  @override
  Future<bool> playRoundStart() async {
    calls.add('roundStart');
    return true;
  }

  @override
  Future<bool> playRoundEnd() async {
    calls.add('roundEnd');
    return true;
  }

  @override
  Future<bool> playWarning() async {
    calls.add('warning');
    return true;
  }

  @override
  Future<bool> playFinalThirty() async {
    calls.add('finalThirty');
    return true;
  }

  @override
  Future<bool> playTick() async {
    calls.add('tick');
    return true;
  }
}

class _FakeHapticsService extends HapticsService {
  final calls = <String>[];

  @override
  Future<bool> roundStart() async {
    calls.add('roundStart');
    return true;
  }

  @override
  Future<bool> roundEnd() async {
    calls.add('roundEnd');
    return true;
  }

  @override
  Future<bool> warning() async {
    calls.add('warning');
    return true;
  }

  @override
  Future<bool> finalThirty() async {
    calls.add('finalThirty');
    return true;
  }

  @override
  Future<bool> cue() async {
    calls.add('cue');
    return true;
  }
}

class _FakeVoiceService extends VoiceService {
  _FakeVoiceService({bool available = true}) : _available = available;

  final bool _available;
  final calls = <String>[];

  @override
  bool get isAvailable => _available;

  @override
  Future<bool> init() async => _available;

  @override
  Future<bool> speak(String text) async {
    calls.add('speak:$text');
    return true;
  }

  @override
  Future<bool> stop() async {
    calls.add('stop');
    return true;
  }
}

class _FakeWakeLockService extends WakeLockService {
  final calls = <String>[];

  @override
  Future<bool> enable() async {
    calls.add('enable');
    return true;
  }

  @override
  Future<bool> disable() async {
    calls.add('disable');
    return true;
  }
}

Workout _workout() => Workout(
  id: 'test',
  name: 'Test workout',
  type: TrainingType.shadowBoxing,
  difficulty: Difficulty.beginner,
  prepareSeconds: 2,
  rounds: [
    // 60 s work: finalThirty at 30 s left, tenSecondWarning at 10 s left,
    // the cue at 55 s elapsed (5 s left) so it fires after both warnings.
    const RoundSpec(
      workSeconds: 60,
      restSeconds: 3,
      focus: 'Jab',
      cues: [RoundCue(atSecond: 55, text: '1-2')],
    ),
    const RoundSpec(workSeconds: 5, restSeconds: 0),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CueController', () {
    test('constructing the controller initialises the audio service', () {
      fakeAsync((async) {
        final session = SessionProvider(clock: () => DateTime(2026, 1, 1));
        final audio = _FakeAudioService();

        final controller = CueController(
          session: session,
          settings: SettingsProvider(),
          audio: audio,
          haptics: _FakeHapticsService(),
          voice: _FakeVoiceService(),
          wakeLock: _FakeWakeLockService(),
        );

        expect(audio.initCalls, 1);

        controller.dispose();
        session.dispose();
      });
    });

    test('a full session drives sound, haptics and voice in event order', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final session = SessionProvider(clock: () => now);
        final settings = SettingsProvider();
        final audio = _FakeAudioService();
        final haptics = _FakeHapticsService();
        final voice = _FakeVoiceService();
        final wakeLock = _FakeWakeLockService();

        final controller = CueController(
          session: session,
          settings: settings,
          audio: audio,
          haptics: haptics,
          voice: voice,
          wakeLock: wakeLock,
        );

        session.start(
          _workout(),
          stance: Stance.orthodox,
          difficulty: Difficulty.beginner,
        );

        // prepare(2) + round 1 work(60) + rest(3) + round 2 work(5), plus
        // one extra tick so the sessionCompleted event has been delivered.
        for (var i = 0; i < 71; i++) {
          now = now.add(const Duration(seconds: 1));
          async.elapse(const Duration(seconds: 1));
        }

        expect(audio.calls, [
          'warning', // prepareStarted
          'roundStart', // roundStarted (round 1)
          'finalThirty',
          'warning', // tenSecondWarning
          'tick', // cue
          'roundEnd', // restStarted
          'roundStart', // roundStarted (round 2)
          'roundEnd', // sessionCompleted
        ]);

        expect(haptics.calls, [
          'warning',
          'roundStart',
          'finalThirty',
          'warning',
          'cue',
          'roundEnd',
          'roundStart',
          'roundEnd',
        ]);

        expect(voice.calls, [
          'speak:Get ready',
          'speak:Round 1. Jab',
          'speak:Thirty seconds',
          'speak:jab, cross',
          'speak:Rest',
          'speak:Round 2',
          'speak:Session complete',
        ]);

        expect(wakeLock.calls, ['enable', 'disable']);

        controller.dispose();
        session.dispose();
      });
    });

    test('sound is muted end to end when soundEnabled is false', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final session = SessionProvider(clock: () => now);
        final settings = SettingsProvider();
        settings.setSoundEnabled(false);
        final audio = _FakeAudioService();
        final controller = CueController(
          session: session,
          settings: settings,
          audio: audio,
          haptics: _FakeHapticsService(),
          voice: _FakeVoiceService(),
          wakeLock: _FakeWakeLockService(),
        );

        session.start(
          _workout(),
          stance: Stance.orthodox,
          difficulty: Difficulty.beginner,
        );
        for (var i = 0; i < 71; i++) {
          now = now.add(const Duration(seconds: 1));
          async.elapse(const Duration(seconds: 1));
        }

        expect(audio.calls, isEmpty);

        controller.dispose();
        session.dispose();
      });
    });

    test('haptics are muted end to end when hapticsEnabled is false', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final session = SessionProvider(clock: () => now);
        final settings = SettingsProvider();
        settings.setHapticsEnabled(false);
        final haptics = _FakeHapticsService();
        final controller = CueController(
          session: session,
          settings: settings,
          audio: _FakeAudioService(),
          haptics: haptics,
          voice: _FakeVoiceService(),
          wakeLock: _FakeWakeLockService(),
        );

        session.start(
          _workout(),
          stance: Stance.orthodox,
          difficulty: Difficulty.beginner,
        );
        for (var i = 0; i < 71; i++) {
          now = now.add(const Duration(seconds: 1));
          async.elapse(const Duration(seconds: 1));
        }

        expect(haptics.calls, isEmpty);

        controller.dispose();
        session.dispose();
      });
    });

    test('voice is muted end to end when voiceEnabled is false', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final session = SessionProvider(clock: () => now);
        final settings = SettingsProvider();
        settings.setVoiceEnabled(false);
        final voice = _FakeVoiceService();
        final controller = CueController(
          session: session,
          settings: settings,
          audio: _FakeAudioService(),
          haptics: _FakeHapticsService(),
          voice: voice,
          wakeLock: _FakeWakeLockService(),
        );

        session.start(
          _workout(),
          stance: Stance.orthodox,
          difficulty: Difficulty.beginner,
        );
        for (var i = 0; i < 71; i++) {
          now = now.add(const Duration(seconds: 1));
          async.elapse(const Duration(seconds: 1));
        }

        expect(voice.calls, isEmpty);

        controller.dispose();
        session.dispose();
      });
    });

    test('voice stays silent when the voice service reports unavailable', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final session = SessionProvider(clock: () => now);
        final settings = SettingsProvider();
        final voice = _FakeVoiceService(available: false);
        final controller = CueController(
          session: session,
          settings: settings,
          audio: _FakeAudioService(),
          haptics: _FakeHapticsService(),
          voice: voice,
          wakeLock: _FakeWakeLockService(),
        );

        session.start(
          _workout(),
          stance: Stance.orthodox,
          difficulty: Difficulty.beginner,
        );
        for (var i = 0; i < 71; i++) {
          now = now.add(const Duration(seconds: 1));
          async.elapse(const Duration(seconds: 1));
        }

        expect(voice.calls, isEmpty);

        controller.dispose();
        session.dispose();
      });
    });

    test('wake lock is never engaged when keepScreenOn is false', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final session = SessionProvider(clock: () => now);
        final settings = SettingsProvider();
        settings.setKeepScreenOn(false);
        final wakeLock = _FakeWakeLockService();
        final controller = CueController(
          session: session,
          settings: settings,
          audio: _FakeAudioService(),
          haptics: _FakeHapticsService(),
          voice: _FakeVoiceService(),
          wakeLock: wakeLock,
        );

        session.start(
          _workout(),
          stance: Stance.orthodox,
          difficulty: Difficulty.beginner,
        );
        for (var i = 0; i < 71; i++) {
          now = now.add(const Duration(seconds: 1));
          async.elapse(const Duration(seconds: 1));
        }

        expect(wakeLock.calls, isEmpty);

        controller.dispose();
        session.dispose();
      });
    });

    test('wake lock is disabled once when a session is ended early', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final session = SessionProvider(clock: () => now);
        final settings = SettingsProvider();
        final wakeLock = _FakeWakeLockService();
        final controller = CueController(
          session: session,
          settings: settings,
          audio: _FakeAudioService(),
          haptics: _FakeHapticsService(),
          voice: _FakeVoiceService(),
          wakeLock: wakeLock,
        );

        session.start(
          _workout(),
          stance: Stance.orthodox,
          difficulty: Difficulty.beginner,
        );
        now = now.add(const Duration(seconds: 1));
        async.elapse(const Duration(seconds: 1));
        session.end();
        async.flushMicrotasks();

        expect(wakeLock.calls, ['enable', 'disable']);

        controller.dispose();
        session.dispose();
      });
    });

    test(
      'pause vibrates and stops speaking; resume and a skip only vibrate',
      () {
        fakeAsync((async) {
          var now = DateTime(2026, 1, 1);
          final session = SessionProvider(clock: () => now);
          final settings = SettingsProvider();
          final audio = _FakeAudioService();
          final haptics = _FakeHapticsService();
          final voice = _FakeVoiceService();
          final controller = CueController(
            session: session,
            settings: settings,
            audio: audio,
            haptics: haptics,
            voice: voice,
            wakeLock: _FakeWakeLockService(),
          );

          session.start(
            _workout(),
            stance: Stance.orthodox,
            difficulty: Difficulty.beginner,
          );
          async.flushMicrotasks();
          audio.calls.clear();
          haptics.calls.clear();
          voice.calls.clear();

          session.pause();
          async.flushMicrotasks();
          session.resume();
          async.flushMicrotasks();
          // Skipping out of prepare both skips and starts round 1, so it
          // also fires the roundStarted mapping.
          session.skipPhase();
          async.flushMicrotasks();

          expect(audio.calls, ['roundStart']);
          expect(haptics.calls, ['cue', 'cue', 'cue', 'roundStart']);
          expect(voice.calls, ['stop', 'speak:Round 1. Jab']);

          controller.dispose();
          session.dispose();
        });
      },
    );

    test('dispose stops listening to further session events', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final session = SessionProvider(clock: () => now);
        final settings = SettingsProvider();
        final audio = _FakeAudioService();
        final controller = CueController(
          session: session,
          settings: settings,
          audio: audio,
          haptics: _FakeHapticsService(),
          voice: _FakeVoiceService(),
          wakeLock: _FakeWakeLockService(),
        );

        controller.dispose();

        session.start(
          _workout(),
          stance: Stance.orthodox,
          difficulty: Difficulty.beginner,
        );
        async.elapse(const Duration(seconds: 1));

        expect(audio.calls, isEmpty);

        session.dispose();
      });
    });
  });
}
