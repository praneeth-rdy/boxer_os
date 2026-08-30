import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:boxer_os/data/posters.dart';
import 'package:boxer_os/models/poster.dart';
import 'package:boxer_os/pages/poster_page.dart';
import 'package:boxer_os/services/wallpaper_service.dart';
import 'package:boxer_os/widgets/pill_button.dart';

const _channel = MethodChannel('boxer_os/wallpaper');

void _mockChannel(Future<Object?> Function(MethodCall call) handler) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, handler);
}

/// PillButton uppercases its label, so match on the widget's own property.
Finder _pillButton(String label) => find.byWidgetPredicate(
  (widget) => widget is PillButton && widget.label == label,
);

Future<void> _pump(WidgetTester tester, Poster poster) async {
  // Tall enough that all three buttons sit inside the ListView's cache
  // extent, since the preview alone fills most of a phone-sized viewport.
  tester.view.physicalSize = const Size(360, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Provider<WallpaperService>.value(
        value: const WallpaperService(),
        child: PosterPage(poster: poster),
      ),
    ),
  );
  await tester.pump();
}

/// Taps [finder] and polls real time for [resultText] to land, since the
/// pending button's spinner animates forever and would hang pumpAndSettle.
Future<void> _tapAndAwaitResult(
  WidgetTester tester,
  Finder finder,
  String resultText,
) async {
  await tester.runAsync(() async {
    await tester.tap(finder);
    await tester.pump();
    for (var attempt = 0; attempt < 50; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await tester.pump();
      if (find.text(resultText).evaluate().isNotEmpty) {
        return;
      }
    }
  });
}

void main() {
  final poster = posters().firstWhere(
    (poster) => poster.kind == PosterKind.quote,
  );

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  testWidgets('shows the preview and the three set buttons', (tester) async {
    await _pump(tester, poster);

    expect(_pillButton('Set as home screen'), findsOneWidget);
    expect(_pillButton('Set as lock screen'), findsOneWidget);
    expect(_pillButton('Set both'), findsOneWidget);
  });

  testWidgets(
    "tapping 'Set as home screen' sends the home target and shows the success SnackBar",
    (tester) async {
      MethodCall? received;
      _mockChannel((call) async {
        received = call;
        return true;
      });
      await _pump(tester, poster);

      await _tapAndAwaitResult(
        tester,
        _pillButton('Set as home screen'),
        'Wallpaper set',
      );

      expect(received?.method, 'setWallpaper');
      expect((received?.arguments as Map)['target'], 'home');
      expect(find.text('Wallpaper set'), findsOneWidget);
    },
  );

  testWidgets('shows the failure SnackBar when the channel throws', (
    tester,
  ) async {
    _mockChannel(
      (call) async => throw PlatformException(code: 'wallpaper_failed'),
    );
    await _pump(tester, poster);

    await _tapAndAwaitResult(
      tester,
      _pillButton('Set both'),
      'Could not set wallpaper',
    );

    expect(find.text('Could not set wallpaper'), findsOneWidget);
  });
}
