import 'package:boxer_os/widgets/pill_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, PillButton button) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: button)),
      ),
    );
  }

  testWidgets('renders the label in uppercase', (tester) async {
    await pump(tester, PillButton(label: 'start round', onPressed: () {}));

    expect(find.text('START ROUND'), findsOneWidget);
  });

  testWidgets('tapping calls onPressed', (tester) async {
    var tapped = false;
    await pump(
      tester,
      PillButton(label: 'Start', onPressed: () => tapped = true),
    );

    await tester.tap(find.text('START'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('a disabled button ignores taps', (tester) async {
    await pump(
      tester,
      const PillButton(
        label: 'Start',
        onPressed: null,
        style: PillStyle.outlined,
      ),
    );

    final button = tester.widget<PillButton>(find.byType(PillButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('fills the height it is given', (tester) async {
    await pump(
      tester,
      PillButton(label: 'Start', onPressed: () {}, height: 72),
    );

    final size = tester.getSize(find.byType(PillButton));
    expect(size.height, 72);
  });
}
