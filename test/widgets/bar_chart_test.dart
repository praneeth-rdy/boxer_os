import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/theme/app_theme.dart';
import 'package:boxer_os/widgets/bar_chart.dart';

void main() {
  testWidgets('all-zero values render without error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BarChart(values: [0, 0, 0], labels: ['a', 'b', 'c']),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(BarChart), findsOneWidget);
  });

  testWidgets('the last bar is the accent color, earlier bars a faded accent', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BarChart(values: [1, 2, 3], labels: ['a', 'b', 'c']),
        ),
      ),
    );

    final barColors = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((box) => (box.decoration as BoxDecoration).color)
        .where((color) => color != null && color != AppTheme.line)
        .toList();

    expect(barColors, contains(AppTheme.accent));
    expect(barColors.where((color) => color == AppTheme.accent).length, 1);
    expect(
      barColors
          .where((color) => color == AppTheme.accent.withValues(alpha: 0.55))
          .length,
      2,
    );
  });

  testWidgets('empty values renders an empty chart with no bars', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BarChart(values: [], labels: []),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
