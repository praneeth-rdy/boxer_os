import 'package:boxer_os/widgets/cue_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, CueBanner banner) {
    return tester.pumpWidget(MaterialApp(home: Scaffold(body: banner)));
  }

  testWidgets('shows the fallback when there is no cue', (tester) async {
    await pump(tester, const CueBanner(cue: null, fallback: 'Free round'));

    expect(find.text('Free round'), findsOneWidget);
  });

  testWidgets('shows the cue when one is set', (tester) async {
    await pump(
      tester,
      const CueBanner(cue: '1-2, slip', fallback: 'Free round'),
    );

    expect(find.text('1-2, slip'), findsOneWidget);
    expect(find.text('Free round'), findsNothing);
  });

  testWidgets('switches text when the cue changes', (tester) async {
    await pump(tester, const CueBanner(cue: '1-2', fallback: 'Free round'));
    expect(find.text('1-2'), findsOneWidget);

    await pump(tester, const CueBanner(cue: 'slip, 2', fallback: 'Free round'));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('slip, 2'), findsOneWidget);
  });

  testWidgets('switches instantly when reduced motion is on', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: const MaterialApp(
          home: Scaffold(
            body: CueBanner(cue: '1-2', fallback: 'Free round'),
          ),
        ),
      ),
    );
    expect(find.text('1-2'), findsOneWidget);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: const MaterialApp(
          home: Scaffold(
            body: CueBanner(cue: 'slip, 2', fallback: 'Free round'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('slip, 2'), findsOneWidget);
    expect(find.text('1-2'), findsNothing);
  });
}
