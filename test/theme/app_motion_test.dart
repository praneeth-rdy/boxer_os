import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/theme/app_motion.dart';

void main() {
  Widget wrap({required bool disableAnimations, required Widget child}) {
    return MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    );
  }

  group('AppMotion.reduced', () {
    testWidgets('is true when the system asks for reduced motion', (
      tester,
    ) async {
      late BuildContext captured;
      await tester.pumpWidget(
        wrap(
          disableAnimations: true,
          child: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(AppMotion.reduced(captured), isTrue);
    });

    testWidgets('is false when animations are not disabled', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        wrap(
          disableAnimations: false,
          child: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(AppMotion.reduced(captured), isFalse);
    });
  });

  group('AppMotion.of', () {
    testWidgets('returns Duration.zero when motion is reduced', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        wrap(
          disableAnimations: true,
          child: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(AppMotion.of(captured, AppMotion.base), Duration.zero);
    });

    testWidgets('returns the given duration unchanged otherwise', (
      tester,
    ) async {
      late BuildContext captured;
      await tester.pumpWidget(
        wrap(
          disableAnimations: false,
          child: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(AppMotion.of(captured, AppMotion.base), AppMotion.base);
    });
  });
}
