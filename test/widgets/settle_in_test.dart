import 'package:boxer_os/widgets/settle_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool disableAnimations = false,
  }) {
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Directionality(textDirection: TextDirection.ltr, child: child),
      ),
    );
  }

  double opacityOf(WidgetTester tester) =>
      tester.widget<Opacity>(find.byType(Opacity)).opacity;

  testWidgets('is instant when reduced motion is on', (tester) async {
    await pump(
      tester,
      const SettleIn(index: 2, child: Text('hello')),
      disableAnimations: true,
    );

    expect(opacityOf(tester), 1);
  });

  testWidgets('index 2 is still transparent at 50ms and opaque by 400ms', (
    tester,
  ) async {
    await pump(tester, const SettleIn(index: 2, child: Text('hello')));

    expect(opacityOf(tester), 0);

    await tester.pump(const Duration(milliseconds: 50));
    expect(opacityOf(tester), lessThan(1));

    await tester.pump(const Duration(milliseconds: 350));
    expect(opacityOf(tester), 1);
  });

  testWidgets('renders its child', (tester) async {
    await pump(tester, const SettleIn(child: Text('hello')));

    expect(find.text('hello'), findsOneWidget);
  });
}
