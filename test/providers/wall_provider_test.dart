import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/data/posters.dart';
import 'package:boxer_os/models/poster.dart';
import 'package:boxer_os/providers/wall_provider.dart';
import 'package:boxer_os/services/wallpaper_service.dart';

const _channel = MethodChannel('boxer_os/wallpaper');

void _mockChannel(Future<Object?> Function(MethodCall call) handler) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, handler);
}

Future<Uint8List> _fakeRender(Poster poster) async =>
    Uint8List.fromList([1, 2, 3]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _mockChannel((call) async => true);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  group('load', () {
    test('defaults to shuffling everything with no selection', () async {
      final wall = WallProvider();

      await wall.load();

      expect(wall.shuffleAll, isTrue);
      expect(wall.selectedIds, isEmpty);
    });

    test('restores a saved selection', () async {
      final firstId = posters()[0].id;
      final secondId = posters()[1].id;
      SharedPreferences.setMockInitialValues({
        WallProvider.wallShuffleAllKey: false,
        WallProvider.wallShuffleIdsKey: [firstId, secondId],
      });
      final wall = WallProvider();

      await wall.load();

      expect(wall.shuffleAll, isFalse);
      expect(wall.selectedIds, {firstId, secondId});
    });
  });

  group('rotation', () {
    test('is every poster when shuffleAll is true', () async {
      final wall = WallProvider();
      await wall.load();

      expect(wall.rotation.length, posters().length);
    });

    test('is only the selected posters, in gallery order, otherwise', () async {
      final wall = WallProvider();
      await wall.load();
      await wall.setShuffleAll(false);
      final first = posters()[0];
      final third = posters()[2];
      await wall.toggle(third.id);
      await wall.toggle(first.id);

      expect(wall.rotation.map((poster) => poster.id), [first.id, third.id]);
    });
  });

  group('toggle', () {
    test('adds an id that is not selected and removes one that is', () async {
      final wall = WallProvider();
      await wall.load();
      final id = posters()[0].id;

      await wall.toggle(id);
      expect(wall.selectedIds, {id});

      await wall.toggle(id);
      expect(wall.selectedIds, isEmpty);
    });

    test('persists the selection', () async {
      final wall = WallProvider();
      await wall.load();
      final id = posters()[0].id;

      await wall.toggle(id);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(WallProvider.wallShuffleIdsKey), [id]);
    });
  });

  group('clearSelection', () {
    test('empties a non-empty selection', () async {
      final wall = WallProvider();
      await wall.load();
      await wall.toggle(posters()[0].id);

      await wall.clearSelection();

      expect(wall.selectedIds, isEmpty);
    });
  });

  group('applyRotation', () {
    test('returns false with nothing to render', () async {
      final wall = WallProvider();
      await wall.load();
      await wall.setShuffleAll(false);
      const service = WallpaperService();

      final isDone = await wall.applyRotation(_fakeRender, service);

      expect(isDone, isFalse);
    });

    test(
      'renders and saves each poster of the rotation with a sequential index',
      () async {
        final calls = <MethodCall>[];
        _mockChannel((call) async {
          calls.add(call);
          return true;
        });
        final wall = WallProvider();
        await wall.load();
        await wall.setShuffleAll(false);
        final ids = posters().take(3).map((poster) => poster.id).toList();
        for (final id in ids) {
          await wall.toggle(id);
        }
        const service = WallpaperService();

        final isDone = await wall.applyRotation(_fakeRender, service);

        expect(isDone, isTrue);
        expect(wall.isRendering, isFalse);
        expect(wall.renderedCount, 3);
        expect(wall.error, isNull);
        expect(calls.length, 3);
        final indices = calls
            .map((call) => (call.arguments as Map)['index'] as int)
            .toList();
        expect(indices, [0, 1, 2]);
        for (final call in calls) {
          expect((call.arguments as Map)['count'], 3);
        }
      },
    );

    test('reports progress as each frame is saved', () async {
      final wall = WallProvider();
      await wall.load();
      await wall.setShuffleAll(false);
      final ids = posters().take(2).map((poster) => poster.id).toList();
      for (final id in ids) {
        await wall.toggle(id);
      }
      const service = WallpaperService();
      final seen = <int>[];
      wall.addListener(() => seen.add(wall.renderedCount));

      await wall.applyRotation(_fakeRender, service);

      expect(seen, contains(1));
      expect(seen, contains(2));
    });

    test('stops and returns false when cancelled mid-render', () async {
      final wall = WallProvider();
      await wall.load();
      await wall.setShuffleAll(false);
      final ids = posters().take(3).map((poster) => poster.id).toList();
      for (final id in ids) {
        await wall.toggle(id);
      }
      const service = WallpaperService();
      var renderCalls = 0;
      Future<Uint8List> render(poster) async {
        renderCalls++;
        if (renderCalls == 1) {
          wall.cancelRender();
        }
        return Uint8List.fromList([1]);
      }

      final isDone = await wall.applyRotation(render, service);

      expect(isDone, isFalse);
      expect(wall.isRendering, isFalse);
      expect(renderCalls, 1);
    });

    test('sets an error and stops when the render fails', () async {
      final wall = WallProvider();
      await wall.load();
      await wall.setShuffleAll(false);
      await wall.toggle(posters()[0].id);
      const service = WallpaperService();
      Future<Uint8List> render(poster) async => throw Exception('boom');

      final isDone = await wall.applyRotation(render, service);

      expect(isDone, isFalse);
      expect(wall.isRendering, isFalse);
      expect(wall.error, isNotNull);
    });

    test('sets an error and stops when the platform refuses to save', () async {
      _mockChannel((call) async => false);
      final wall = WallProvider();
      await wall.load();
      await wall.setShuffleAll(false);
      await wall.toggle(posters()[0].id);
      const service = WallpaperService();

      final isDone = await wall.applyRotation(_fakeRender, service);

      expect(isDone, isFalse);
      expect(wall.isRendering, isFalse);
      expect(wall.error, isNotNull);
    });

    test('refuses to start a second render while one is in flight', () async {
      final wall = WallProvider();
      await wall.load();
      await wall.setShuffleAll(false);
      await wall.toggle(posters()[0].id);
      const service = WallpaperService();
      final gate = Completer<void>();
      Future<Uint8List> slowRender(poster) async {
        await gate.future;
        return Uint8List.fromList([1]);
      }

      final firstRun = wall.applyRotation(slowRender, service);
      final secondResult = await wall.applyRotation(_fakeRender, service);

      expect(secondResult, isFalse);
      gate.complete();
      final firstResult = await firstRun;
      expect(firstResult, isTrue);
    });
  });
}
