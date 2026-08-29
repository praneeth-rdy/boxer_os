import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/defense_zone.dart';
import 'package:boxer_os/theme/app_theme.dart';
import 'package:boxer_os/widgets/defense_grid.dart';

Future<void> _pump(
  WidgetTester tester, {
  required bool isArmed,
  required void Function(DefenseZone) onZone,
  Widget? centre,
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 300,
        height: 300,
        child: DefenseGrid(onZone: onZone, isArmed: isArmed, centre: centre),
      ),
    ),
  ),
);

void main() {
  testWidgets('shows all four zone labels', (tester) async {
    await _pump(tester, isArmed: false, onZone: (_) {});

    expect(find.text('SLIP LEFT'), findsOneWidget);
    expect(find.text('SLIP RIGHT'), findsOneWidget);
    expect(find.text('ROLL'), findsOneWidget);
    expect(find.text('BLOCK'), findsOneWidget);
  });

  testWidgets('tapping each zone calls onZone with the matching DefenseZone', (
    tester,
  ) async {
    final tapped = <DefenseZone>[];
    await _pump(tester, isArmed: true, onZone: tapped.add);

    await tester.tap(find.text('SLIP LEFT'));
    await tester.tap(find.text('SLIP RIGHT'));
    await tester.tap(find.text('ROLL'));
    await tester.tap(find.text('BLOCK'));

    expect(tapped, [
      DefenseZone.slipLeft,
      DefenseZone.slipRight,
      DefenseZone.roll,
      DefenseZone.block,
    ]);
  });

  testWidgets('labels are brighter when armed than when resting', (
    tester,
  ) async {
    await _pump(tester, isArmed: true, onZone: (_) {});
    final armed = tester.widget<Text>(find.text('SLIP LEFT'));
    expect(armed.style?.color, AppTheme.chalkMuted);

    await _pump(tester, isArmed: false, onZone: (_) {});
    final resting = tester.widget<Text>(find.text('SLIP LEFT'));
    expect(resting.style?.color, AppTheme.chalkFaint);
  });

  testWidgets('centre widget is shown but ignores taps', (tester) async {
    var tapped = false;
    await _pump(
      tester,
      isArmed: true,
      onZone: (_) => tapped = true,
      centre: const Text('JAB'),
    );

    expect(find.text('JAB'), findsOneWidget);

    // A tap that lands on the centre overlay falls through to the zone below it;
    // IgnorePointer means the tap does not "hit" the text itself.
    await tester.tap(find.text('JAB'), warnIfMissed: false);
    expect(tapped, isTrue);
  });
}
