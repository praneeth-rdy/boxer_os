import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/services/wake_lock_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The pigeon-generated channel wakelock_plus_platform_interface uses for
  // WakelockPlusApi.toggle, with no message channel suffix.
  const channel =
      'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle';

  /// Replies the way the pigeon host API does: an empty list on success, or
  /// a [code, message, details] triple to signal a platform failure.
  void answerWith({required bool succeeds}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel, (message) async {
          final reply = succeeds
              ? const <Object?>[]
              : const <Object?>['unavailable', 'wakelock failed', null];
          return const StandardMessageCodec().encodeMessage(reply);
        });
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel, null);
  });

  group('WakeLockService.enable', () {
    test('returns true on a successful platform call', () async {
      answerWith(succeeds: true);

      expect(await WakeLockService().enable(), isTrue);
    });

    test('returns false, not an exception, when the platform throws', () async {
      answerWith(succeeds: false);

      expect(await WakeLockService().enable(), isFalse);
    });
  });

  group('WakeLockService.disable', () {
    test('returns true on a successful platform call', () async {
      answerWith(succeeds: true);

      expect(await WakeLockService().disable(), isTrue);
    });

    test('returns false, not an exception, when the platform throws', () async {
      answerWith(succeeds: false);

      expect(await WakeLockService().disable(), isFalse);
    });
  });
}
