import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/reaction_direction.dart';
import 'package:boxer_os/widgets/sequence_pad.dart';

Future<void> _pump(
  WidgetTester tester, {
  required void Function(ReactionDirection) onDirection,
  Widget centre = const SizedBox.shrink(),
  List<ReactionDirection> sequence = const [],
  bool isShowingSequence = false,
  int entered = 0,
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 300,
        height: 300,
        child: SequencePad(
          onDirection: onDirection,
          centre: centre,
          sequence: sequence,
          isShowingSequence: isShowingSequence,
          entered: entered,
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('with an empty sequence it shows the given centre', (
    tester,
  ) async {
    await _pump(tester, onDirection: (_) {}, centre: const Text('WAIT'));

    expect(find.text('WAIT'), findsOneWidget);
  });

  testWidgets('tapping each edge calls onDirection with the matching edge', (
    tester,
  ) async {
    final tapped = <ReactionDirection>[];
    await _pump(tester, onDirection: tapped.add);

    await tester.tapAt(const Offset(150, 20));
    await tester.tapAt(const Offset(20, 150));
    await tester.tapAt(const Offset(280, 150));
    await tester.tapAt(const Offset(150, 280));

    expect(tapped, [
      ReactionDirection.up,
      ReactionDirection.left,
      ReactionDirection.right,
      ReactionDirection.down,
    ]);
  });

  testWidgets('while showing the sequence, one arrow icon renders per arrow', (
    tester,
  ) async {
    await _pump(
      tester,
      onDirection: (_) {},
      sequence: const [
        ReactionDirection.up,
        ReactionDirection.left,
        ReactionDirection.down,
      ],
      isShowingSequence: true,
    );

    expect(find.byIcon(ReactionDirection.up.icon), findsOneWidget);
    expect(find.byIcon(ReactionDirection.left.icon), findsOneWidget);
    expect(find.byIcon(ReactionDirection.down.icon), findsOneWidget);
    expect(find.byIcon(ReactionDirection.right.icon), findsNothing);
  });

  testWidgets(
    'once the sequence is hidden it shows one progress dot per arrow',
    (tester) async {
      await _pump(
        tester,
        onDirection: (_) {},
        sequence: const [
          ReactionDirection.up,
          ReactionDirection.left,
          ReactionDirection.down,
        ],
        isShowingSequence: false,
        entered: 0,
      );

      expect(find.byIcon(ReactionDirection.up.icon), findsNothing);
      final dots = tester.widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(Row).last,
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(dots, hasLength(3));
    },
  );

  testWidgets('progress dots fill up to match how many arrows are entered', (
    tester,
  ) async {
    await _pump(
      tester,
      onDirection: (_) {},
      sequence: const [ReactionDirection.up, ReactionDirection.left],
      isShowingSequence: false,
      entered: 1,
    );

    final decorations = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(Row).last,
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((box) => box.decoration as BoxDecoration)
        .toList();

    expect(decorations, hasLength(2));
    expect(decorations[0].color, isNot(Colors.transparent));
    expect(decorations[1].color, Colors.transparent);
  });
}
