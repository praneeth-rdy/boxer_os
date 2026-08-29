import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/services/voice_service.dart';

const _channel = MethodChannel('flutter_tts');

/// Wires the flutter_tts channel to a fake platform so [VoiceService] can be
/// driven without a device; [voices] is what `getVoices` answers with.
_Recorder _mockTts({List<Map<String, String>> voices = const []}) {
  final recorder = _Recorder();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, (call) async {
        recorder.calls.add(call);
        switch (call.method) {
          case 'getVoices':
            return voices;
          case 'setLanguage':
            return 1;
          default:
            return 1;
        }
      });
  return recorder;
}

class _Recorder {
  final calls = <MethodCall>[];

  MethodCall? call(String method) {
    for (final entry in calls) {
      if (entry.method == method) return entry;
    }
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  group('VoiceService.init', () {
    test('selects the local en-US voice over an en-IN one', () async {
      final recorder = _mockTts(
        voices: const [
          {'name': 'en-in-local', 'locale': 'en-IN'},
          {'name': 'en-us-local', 'locale': 'en-US'},
        ],
      );
      final voice = VoiceService();

      final result = await voice.init();

      expect(result, isTrue);
      expect(voice.isAvailable, isTrue);
      expect(voice.voiceName, 'en-us-local');
      final setVoiceCall = recorder.call('setVoice');
      expect(setVoiceCall, isNotNull);
      expect(setVoiceCall!.arguments, {
        'name': 'en-us-local',
        'locale': 'en-US',
      });
    });

    test(
      'falls back to a network en-US voice when no local one exists',
      () async {
        _mockTts(
          voices: const [
            {'name': 'en-US-network', 'locale': 'en-US'},
          ],
        );
        final voice = VoiceService();

        await voice.init();

        expect(voice.voiceName, 'en-US-network');
      },
    );

    test('prefers a non-network en-US voice when both are offered', () async {
      _mockTts(
        voices: const [
          {'name': 'en-US-network', 'locale': 'en-US'},
          {'name': 'en-us-local', 'locale': 'en-us'},
        ],
      );
      final voice = VoiceService();

      await voice.init();

      expect(voice.voiceName, 'en-us-local');
    });

    test('leaves voiceName null when no en-US voice is offered', () async {
      final recorder = _mockTts(
        voices: const [
          {'name': 'en-in-local', 'locale': 'en-IN'},
        ],
      );
      final voice = VoiceService();

      final result = await voice.init();

      expect(result, isTrue);
      expect(voice.voiceName, isNull);
      expect(recorder.call('setVoice'), isNull);
    });

    test(
      'leaves voiceName null when getVoices returns nothing usable',
      () async {
        _mockTts();
        final voice = VoiceService();

        await voice.init();

        expect(voice.voiceName, isNull);
      },
    );

    test('stays available even when getVoices throws', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, (call) async {
            if (call.method == 'setLanguage') return 1;
            throw PlatformException(code: 'error');
          });
      final voice = VoiceService();

      final result = await voice.init();

      expect(result, isTrue);
      expect(voice.isAvailable, isTrue);
      expect(voice.voiceName, isNull);
    });

    test('isAvailable is false when setLanguage itself throws', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, (call) async {
            throw PlatformException(code: 'error');
          });
      final voice = VoiceService();

      final result = await voice.init();

      expect(result, isFalse);
      expect(voice.isAvailable, isFalse);
    });
  });

  group('VoiceService.sayTest', () {
    test('speaks the fixed line of boxing terms', () async {
      final recorder = _mockTts();
      final voice = VoiceService();
      await voice.init();

      final result = await voice.sayTest();

      expect(result, isTrue);
      final speakCall = recorder.call('speak');
      expect(speakCall, isNotNull);
      expect(
        speakCall!.arguments,
        'Round one. Jab, cross, lead hook, rear uppercut. '
        'Slip, roll, pivot. Thirty seconds.',
      );
    });
  });
}
