import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/data/posters.dart';
import 'package:boxer_os/pages/live_wallpaper_page.dart';
import 'package:boxer_os/providers/wall_provider.dart';
import 'package:boxer_os/services/wallpaper_service.dart';
import 'package:boxer_os/widgets/phone_preview.dart';
import 'package:boxer_os/widgets/pill_button.dart';

const _channel = MethodChannel('boxer_os/wallpaper');

void _mockChannel(Future<Object?> Function(MethodCall call) handler) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, handler);
}

void _setPhoneSize(WidgetTester tester) {
  // Tall enough that the grid sits inside the CustomScrollView's cache
  // extent below the header, filters and explanation text.
  tester.view.physicalSize = const Size(360, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _harness(WallProvider wall) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<WallProvider>.value(value: wall),
      Provider<WallpaperService>.value(value: const WallpaperService()),
    ],
    child: const MaterialApp(home: LiveWallpaperPage()),
  );
}

PillButton _renderButton(WidgetTester tester) => tester.widget<PillButton>(
  find.widgetWithText(PillButton, 'RENDER AND SET'),
);

/// Drives the binding through inactive and back so observers see a resume.
Future<void> _resume(WidgetTester tester) async {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final state in [AppLifecycleState.inactive, AppLifecycleState.resumed]) {
    await messenger.handlePlatformMessage(
      'flutter/lifecycle',
      const StringCodec().encodeMessage(state.toString()),
      (_) {},
    );
  }
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _mockChannel(
      (call) async => call.method == 'isLiveWallpaperActive' ? false : true,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  testWidgets('starts on Everything with the whole gallery selected', (
    tester,
  ) async {
    final wall = WallProvider();
    await wall.load();

    await tester.pumpWidget(_harness(wall));
    await tester.pumpAndSettle();

    expect(
      find.text('All ${posters().length} posters, in a random order.'),
      findsOneWidget,
    );
    expect(_renderButton(tester).onPressed, isNotNull);
  });

  testWidgets(
    'switching to Pick a few shows the grid and disables the button with nothing selected',
    (tester) async {
      _setPhoneSize(tester);
      final wall = WallProvider();
      await wall.load();

      await tester.pumpWidget(_harness(wall));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pick a few'));
      await tester.pumpAndSettle();

      expect(find.text('0 selected'), findsOneWidget);
      expect(_renderButton(tester).onPressed, isNull);
    },
  );

  testWidgets(
    'selecting a poster enables the render button and updates the count',
    (tester) async {
      _setPhoneSize(tester);
      final wall = WallProvider();
      await wall.load();

      await tester.pumpWidget(_harness(wall));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pick a few'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PhonePreview).first);
      await tester.pumpAndSettle();

      expect(find.text('1 selected'), findsOneWidget);
      expect(_renderButton(tester).onPressed, isNotNull);
    },
  );

  testWidgets(
    'shows progress and a cancel pill while rendering, then hides it',
    (tester) async {
      final wall = WallProvider();
      await wall.load();
      await wall.setShuffleAll(false);
      await wall.toggle(posters()[0].id);
      await wall.toggle(posters()[1].id);

      await tester.pumpWidget(_harness(wall));
      await tester.pumpAndSettle();

      final gate = Completer<void>();
      Future<Uint8List> slowRender(poster) async {
        await gate.future;
        return Uint8List.fromList([1]);
      }

      final applied = wall.applyRotation(slowRender, const WallpaperService());
      await tester.pump();

      expect(find.text('Cancel'.toUpperCase()), findsOneWidget);
      expect(find.textContaining('of 2 rendered'), findsOneWidget);

      gate.complete();
      await applied;
      await tester.pumpAndSettle();

      expect(find.text('Cancel'.toUpperCase()), findsNothing);
    },
  );

  testWidgets('shows the live wallpaper status from the platform', (
    tester,
  ) async {
    _mockChannel(
      (call) async => call.method == 'isLiveWallpaperActive' ? true : true,
    );
    final wall = WallProvider();
    await wall.load();

    await tester.pumpWidget(_harness(wall));
    await tester.pumpAndSettle();

    expect(find.text('Live wallpaper: on'), findsOneWidget);
  });

  testWidgets('re-checks the live wallpaper status when the app resumes', (
    tester,
  ) async {
    var isLive = false;
    _mockChannel(
      (call) async => call.method == 'isLiveWallpaperActive' ? isLive : true,
    );
    final wall = WallProvider();
    await wall.load();

    await tester.pumpWidget(_harness(wall));
    await tester.pumpAndSettle();
    expect(find.text('Live wallpaper: off'), findsOneWidget);

    isLive = true;
    await _resume(tester);

    expect(find.text('Live wallpaper: on'), findsOneWidget);
  });
}
