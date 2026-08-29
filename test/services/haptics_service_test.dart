import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/services/haptics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter/platform', JSONMethodCodec());
  late List<String> calls;

  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.arguments as String);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('HapticsService', () {
    test('roundStart fires two heavy impacts', () async {
      final result = await HapticsService().roundStart();

      expect(result, isTrue);
      expect(calls, [
        'HapticFeedbackType.heavyImpact',
        'HapticFeedbackType.heavyImpact',
      ]);
    });

    test('roundEnd fires three heavy impacts', () async {
      final result = await HapticsService().roundEnd();

      expect(result, isTrue);
      expect(calls, [
        'HapticFeedbackType.heavyImpact',
        'HapticFeedbackType.heavyImpact',
        'HapticFeedbackType.heavyImpact',
      ]);
    });

    test('warning fires one medium impact', () async {
      final result = await HapticsService().warning();

      expect(result, isTrue);
      expect(calls, ['HapticFeedbackType.mediumImpact']);
    });

    test('finalThirty fires two medium impacts', () async {
      final result = await HapticsService().finalThirty();

      expect(result, isTrue);
      expect(calls, [
        'HapticFeedbackType.mediumImpact',
        'HapticFeedbackType.mediumImpact',
      ]);
    });

    test('cue fires one selection click', () async {
      final result = await HapticsService().cue();

      expect(result, isTrue);
      expect(calls, ['HapticFeedbackType.selectionClick']);
    });

    test(
      'returns false, not an exception, when the platform call fails',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              throw PlatformException(code: 'unavailable');
            });

        final result = await HapticsService().warning();

        expect(result, isFalse);
      },
    );
  });
}
