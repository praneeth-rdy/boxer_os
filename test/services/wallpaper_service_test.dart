import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/services/wallpaper_service.dart';

const _channel = MethodChannel('boxer_os/wallpaper');

void _mockChannel(Future<Object?> Function(MethodCall call) handler) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, handler);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  group('WallpaperService.set', () {
    test('returns true when the channel answers true', () async {
      _mockChannel((call) async => true);
      const service = WallpaperService();

      final isSet = await service.set(
        Uint8List.fromList([1, 2, 3]),
        WallpaperTarget.home,
      );

      expect(isSet, isTrue);
    });

    test('returns false when the channel answers false', () async {
      _mockChannel((call) async => false);
      const service = WallpaperService();

      final isSet = await service.set(
        Uint8List.fromList([1, 2, 3]),
        WallpaperTarget.lock,
      );

      expect(isSet, isFalse);
    });

    test('returns false when the channel throws', () async {
      _mockChannel(
        (call) async => throw PlatformException(code: 'wallpaper_failed'),
      );
      const service = WallpaperService();

      final isSet = await service.set(
        Uint8List.fromList([1, 2, 3]),
        WallpaperTarget.both,
      );

      expect(isSet, isFalse);
    });

    test('sends the bytes and the target name as the call arguments', () async {
      MethodCall? received;
      _mockChannel((call) async {
        received = call;
        return true;
      });
      const service = WallpaperService();
      final bytes = Uint8List.fromList([9, 8, 7]);

      await service.set(bytes, WallpaperTarget.both);

      expect(received?.method, 'setWallpaper');
      final arguments = received?.arguments as Map<Object?, Object?>;
      expect(arguments['bytes'], bytes);
      expect(arguments['target'], 'both');
    });
  });

  group('WallpaperService.saveRotationFrame', () {
    test('returns true when the channel answers true', () async {
      _mockChannel((call) async => true);
      const service = WallpaperService();

      final isSaved = await service.saveRotationFrame(
        index: 0,
        count: 3,
        png: Uint8List.fromList([1, 2, 3]),
      );

      expect(isSaved, isTrue);
    });

    test('returns false when the channel answers false', () async {
      _mockChannel((call) async => false);
      const service = WallpaperService();

      final isSaved = await service.saveRotationFrame(
        index: 1,
        count: 3,
        png: Uint8List.fromList([1, 2, 3]),
      );

      expect(isSaved, isFalse);
    });

    test('returns false when the channel throws', () async {
      _mockChannel(
        (call) async => throw PlatformException(code: 'wallpaper_failed'),
      );
      const service = WallpaperService();

      final isSaved = await service.saveRotationFrame(
        index: 2,
        count: 3,
        png: Uint8List.fromList([1, 2, 3]),
      );

      expect(isSaved, isFalse);
    });

    test('sends the index, count and bytes as the call arguments', () async {
      MethodCall? received;
      _mockChannel((call) async {
        received = call;
        return true;
      });
      const service = WallpaperService();
      final bytes = Uint8List.fromList([4, 5, 6]);

      await service.saveRotationFrame(index: 2, count: 5, png: bytes);

      expect(received?.method, 'saveRotation');
      final arguments = received?.arguments as Map<Object?, Object?>;
      expect(arguments['index'], 2);
      expect(arguments['count'], 5);
      expect(arguments['bytes'], bytes);
    });
  });

  group('WallpaperService.openLivePicker', () {
    test('returns true when the channel answers true', () async {
      _mockChannel((call) async => true);
      const service = WallpaperService();

      expect(await service.openLivePicker(), isTrue);
    });

    test('returns false when the channel answers false', () async {
      _mockChannel((call) async => false);
      const service = WallpaperService();

      expect(await service.openLivePicker(), isFalse);
    });

    test('returns false when the channel throws', () async {
      _mockChannel((call) async => throw PlatformException(code: 'no_picker'));
      const service = WallpaperService();

      expect(await service.openLivePicker(), isFalse);
    });

    test('calls the openLiveWallpaperPicker method', () async {
      MethodCall? received;
      _mockChannel((call) async {
        received = call;
        return true;
      });
      const service = WallpaperService();

      await service.openLivePicker();

      expect(received?.method, 'openLiveWallpaperPicker');
    });
  });

  group('WallpaperService.isLiveActive', () {
    test('returns true when the channel answers true', () async {
      _mockChannel((call) async => true);
      const service = WallpaperService();

      expect(await service.isLiveActive(), isTrue);
    });

    test('returns false when the channel answers false', () async {
      _mockChannel((call) async => false);
      const service = WallpaperService();

      expect(await service.isLiveActive(), isFalse);
    });

    test('returns false when the channel throws', () async {
      _mockChannel((call) async => throw PlatformException(code: 'unknown'));
      const service = WallpaperService();

      expect(await service.isLiveActive(), isFalse);
    });

    test('calls the isLiveWallpaperActive method', () async {
      MethodCall? received;
      _mockChannel((call) async {
        received = call;
        return true;
      });
      const service = WallpaperService();

      await service.isLiveActive();

      expect(received?.method, 'isLiveWallpaperActive');
    });
  });
}
