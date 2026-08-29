import 'package:boxer_os/models/session_phase.dart';
import 'package:boxer_os/theme/app_theme.dart';
import 'package:boxer_os/widgets/round_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, RoundClock clock) {
    return tester.pumpWidget(MaterialApp(home: Scaffold(body: clock)));
  }

  testWidgets('formats seconds left as a clock', (tester) async {
    await pump(
      tester,
      const RoundClock(
        secondsLeft: 65,
        phaseSeconds: 120,
        phase: SessionPhase.work,
      ),
    );

    expect(find.text('1:05'), findsOneWidget);
  });

  testWidgets('colours the clock by phase', (tester) async {
    expect(RoundClock.colorFor(SessionPhase.prepare), AppTheme.warning);
    expect(RoundClock.colorFor(SessionPhase.work), AppTheme.accent);
    expect(RoundClock.colorFor(SessionPhase.rest), AppTheme.rest);
    expect(RoundClock.colorFor(SessionPhase.idle), AppTheme.chalk);
    expect(RoundClock.colorFor(SessionPhase.complete), AppTheme.chalk);
  });

  testWidgets('does not crash with a zero phase length', (tester) async {
    await pump(
      tester,
      const RoundClock(
        secondsLeft: 0,
        phaseSeconds: 0,
        phase: SessionPhase.idle,
      ),
    );

    expect(find.text('0:00'), findsOneWidget);
  });

  testWidgets(
    'pulses with a keyed builder in the last ten seconds of a work phase',
    (tester) async {
      await pump(
        tester,
        const RoundClock(
          secondsLeft: 10,
          phaseSeconds: 120,
          phase: SessionPhase.work,
        ),
      );

      expect(find.byKey(const ValueKey<int>(10)), findsOneWidget);
    },
  );

  testWidgets(
    'does not pulse outside the last ten seconds of a work phase',
    (tester) async {
      await pump(
        tester,
        const RoundClock(
          secondsLeft: 11,
          phaseSeconds: 120,
          phase: SessionPhase.work,
        ),
      );

      expect(find.byKey(const ValueKey<int>(11)), findsNothing);
    },
  );

  testWidgets('does not pulse during rest, even with time low', (
    tester,
  ) async {
    await pump(
      tester,
      const RoundClock(
        secondsLeft: 5,
        phaseSeconds: 60,
        phase: SessionPhase.rest,
      ),
    );

    expect(find.byKey(const ValueKey<int>(5)), findsNothing);
  });

  testWidgets('does not pulse when reduced motion is on', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: const MaterialApp(
          home: Scaffold(
            body: RoundClock(
              secondsLeft: 5,
              phaseSeconds: 120,
              phase: SessionPhase.work,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey<int>(5)), findsNothing);
    expect(find.text('0:05'), findsOneWidget);
  });
}
