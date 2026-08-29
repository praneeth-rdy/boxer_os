import 'package:boxer_os/widgets/count_up_text.dart';
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
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: child,
        ),
      ),
    );
  }

  testWidgets('is instant when reduced motion is on', (tester) async {
    await pump(
      tester,
      const CountUpText(value: 42, style: TextStyle()),
      disableAnimations: true,
    );

    expect(find.text('42'), findsOneWidget);
  });

  testWidgets(
    'counts up to a changed value, showing an intermediate at 200ms and the '
    'target by 400ms',
    (tester) async {
      await pump(tester, const CountUpText(value: 0, style: TextStyle()));
      expect(find.text('0'), findsOneWidget);

      await pump(tester, const CountUpText(value: 42, style: TextStyle()));

      await tester.pump(const Duration(milliseconds: 200));
      final shown = tester.widget<Text>(find.byType(Text)).data!;
      final intermediate = int.parse(shown);
      expect(intermediate, greaterThan(0));
      expect(intermediate, lessThan(42));

      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('42'), findsOneWidget);
    },
  );

  testWidgets('appends the suffix', (tester) async {
    await pump(
      tester,
      const CountUpText(value: 3, style: TextStyle(), suffix: '/6'),
      disableAnimations: true,
    );

    expect(find.text('3/6'), findsOneWidget);
  });
}
