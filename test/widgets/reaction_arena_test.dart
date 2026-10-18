import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:boxer_os/models/defense_zone.dart';
import 'package:boxer_os/models/incoming_punch.dart';
import 'package:boxer_os/models/reaction_colour.dart';
import 'package:boxer_os/models/reaction_direction.dart';
import 'package:boxer_os/models/reaction_mode.dart';
import 'package:boxer_os/providers/reaction_provider.dart';
import 'package:boxer_os/widgets/colour_grid.dart';
import 'package:boxer_os/widgets/defense_grid.dart';
import 'package:boxer_os/widgets/reaction_arena.dart';
import 'package:boxer_os/widgets/sequence_pad.dart';

/// A Random that always answers the same values, so a stimulus is predictable.
class _FixedRandom implements Random {
  _FixedRandom({this.doubleValue = 0.0});

  final double doubleValue;

  @override
  double nextDouble() => doubleValue;

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => false;
}

/// One call recorded against the [ReactionTap] signature.
class _TapCall {
  const _TapCall({this.direction, this.defense, this.at, this.colour});

  final ReactionDirection? direction;
  final DefenseZone? defense;
  final Offset? at;
  final ReactionColour? colour;
}

/// Records every call the arena makes and forwards it to the real provider,
/// the way `reaction_page.dart` wires `onTap: reaction.tap` in the app.
class _TapRecorder {
  _TapRecorder(this.reaction);

  final ReactionProvider reaction;
  final List<_TapCall> calls = [];

  void call({
    ReactionDirection? direction,
    DefenseZone? defense,
    Offset? at,
    ReactionColour? colour,
  }) {
    calls.add(
      _TapCall(direction: direction, defense: defense, at: at, colour: colour),
    );
    reaction.tap(
      direction: direction,
      defense: defense,
      at: at,
      colour: colour,
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  ReactionProvider reaction,
  _TapRecorder recorder, {
  Size size = const Size(400, 800),
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<ReactionProvider>.value(
        value: reaction,
        child: Scaffold(
          body: SizedBox(
            width: size.width,
            height: size.height,
            child: Consumer<ReactionProvider>(
              builder: (context, reaction, _) =>
                  ReactionArena(reaction: reaction, onTap: recorder.call),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _elapseToPhase(
  WidgetTester tester,
  ReactionProvider reaction,
  ReactionPhase phase,
) async {
  var budget = const Duration(seconds: 10);
  const step = Duration(milliseconds: 10);
  while (reaction.phase != phase) {
    await tester.pump(step);
    budget -= step;
    if (budget.isNegative) {
      fail('phase never reached $phase (stuck at ${reaction.phase})');
    }
  }
}

/// Grows the test surface past the default 800x600 so a tall [Size] passed
/// to [_pump] is not clamped down by the viewport.
void _growViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Runs the countdown and lands on the stimulus of a just-started trial.
Future<void> _toStimulus(WidgetTester tester, ReactionProvider reaction) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 3));
  await _elapseToPhase(tester, reaction, ReactionPhase.stimulus);
}

void main() {
  testWidgets('tap mode shows a plain hit area and reports a bare tap', (
    tester,
  ) async {
    var now = DateTime(2026, 1, 1);
    final reaction = ReactionProvider(clock: () => now);
    final recorder = _TapRecorder(reaction);
    await _pump(tester, reaction, recorder);

    reaction.start(ReactionMode.tap);
    await _toStimulus(tester, reaction);

    expect(find.byType(SequencePad), findsNothing);
    expect(find.byType(DefenseGrid), findsNothing);
    expect(find.byType(ColourGrid), findsNothing);
    expect(find.text('GO'), findsOneWidget);

    now = now.add(const Duration(milliseconds: 150));
    await tester.tap(find.byType(ReactionArena));
    await tester.pump();

    expect(recorder.calls, hasLength(1));
    final call = recorder.calls.single;
    expect(call.direction, isNull);
    expect(call.defense, isNull);
    expect(call.at, isNull);
    expect(call.colour, isNull);
    expect(reaction.feedback, '150 ms');

    reaction.dispose();
  });

  testWidgets('a tap outside the arena bounds does not invoke onTap', (
    tester,
  ) async {
    final reaction = ReactionProvider(clock: () => DateTime(2026, 1, 1));
    final recorder = _TapRecorder(reaction);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ReactionProvider>.value(
          value: reaction,
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 200,
                height: 200,
                child: Consumer<ReactionProvider>(
                  builder: (context, reaction, _) =>
                      ReactionArena(reaction: reaction, onTap: recorder.call),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    reaction.start(ReactionMode.tap);
    await _toStimulus(tester, reaction);

    // Well clear of the 200x200 arena pinned to the top-left corner.
    await tester.tapAt(const Offset(700, 500));
    await tester.pump();
    expect(recorder.calls, isEmpty);

    await tester.tapAt(const Offset(50, 50));
    await tester.pump();
    expect(recorder.calls, hasLength(1));

    reaction.dispose();
  });

  testWidgets(
    'direction mode shows the sequence pad and reports the tapped edge',
    (tester) async {
      final reaction = ReactionProvider(
        clock: () => DateTime(2026, 1, 1),
        random: _FixedRandom(),
      );
      final recorder = _TapRecorder(reaction);
      await _pump(tester, reaction, recorder);

      reaction.start(ReactionMode.direction);
      await _toStimulus(tester, reaction);

      expect(find.byType(SequencePad), findsOneWidget);
      expect(find.byType(DefenseGrid), findsNothing);
      expect(find.byType(ColourGrid), findsNothing);
      expect(reaction.direction, ReactionDirection.up);

      final arena = tester.getTopLeft(find.byType(ReactionArena));
      final size = tester.getSize(find.byType(ReactionArena));
      await tester.tapAt(
        Offset(arena.dx + size.width * 0.5, arena.dy + size.height * 0.1),
      );
      await tester.pump();

      expect(recorder.calls, hasLength(1));
      expect(recorder.calls.single.direction, ReactionDirection.up);

      reaction.dispose();
    },
  );

  testWidgets(
    'defense mode shows the defense grid and reports the tapped zone',
    (tester) async {
      final reaction = ReactionProvider(
        clock: () => DateTime(2026, 1, 1),
        random: _FixedRandom(),
      );
      final recorder = _TapRecorder(reaction);
      await _pump(tester, reaction, recorder);

      reaction.start(ReactionMode.defense);
      await _toStimulus(tester, reaction);

      expect(find.byType(DefenseGrid), findsOneWidget);
      expect(find.byType(SequencePad), findsNothing);
      expect(find.byType(ColourGrid), findsNothing);
      expect(reaction.incomingPunch, IncomingPunch.jab);

      // Orthodox beats a jab with a slip right.
      await tester.tap(find.text('SLIP RIGHT'));
      await tester.pump();

      expect(recorder.calls, hasLength(1));
      expect(recorder.calls.single.defense, DefenseZone.slipRight);

      reaction.dispose();
    },
  );

  testWidgets(
    'colour mode shows the colour grid and reports the tapped colour',
    (tester) async {
      final reaction = ReactionProvider(
        clock: () => DateTime(2026, 1, 1),
        random: _FixedRandom(),
      );
      final recorder = _TapRecorder(reaction);
      await _pump(tester, reaction, recorder);

      reaction.start(ReactionMode.colour);
      await _toStimulus(tester, reaction);

      expect(find.byType(ColourGrid), findsOneWidget);
      expect(find.byType(SequencePad), findsNothing);
      expect(find.byType(DefenseGrid), findsNothing);
      expect(reaction.inkColour, ReactionColour.red);

      await tester.tap(find.text('RED'));
      await tester.pump();

      expect(recorder.calls, hasLength(1));
      expect(recorder.calls.single.colour, ReactionColour.red);

      reaction.dispose();
    },
  );

  testWidgets(
    'go / no-go mode shows a plain hit area; a go target records a hit',
    (tester) async {
      var now = DateTime(2026, 1, 1);
      final reaction = ReactionProvider(
        clock: () => now,
        random: _FixedRandom(),
      );
      final recorder = _TapRecorder(reaction);
      await _pump(tester, reaction, recorder);

      reaction.start(ReactionMode.goNoGo);
      await _toStimulus(tester, reaction);

      expect(find.byType(SequencePad), findsNothing);
      expect(find.byType(DefenseGrid), findsNothing);
      expect(find.byType(ColourGrid), findsNothing);
      expect(reaction.isGo, isTrue);
      expect(find.text('GO'), findsOneWidget);

      now = now.add(const Duration(milliseconds: 150));
      await tester.tap(find.byType(ReactionArena));
      await tester.pump();

      expect(recorder.calls, hasLength(1));
      expect(reaction.feedback, '150 ms');

      reaction.dispose();
    },
  );

  testWidgets(
    'go / no-go mode reports a tapped no-go target as a hold, not a hit',
    (tester) async {
      final reaction = ReactionProvider(
        clock: () => DateTime(2026, 1, 1),
        random: _FixedRandom(doubleValue: 0.9),
      );
      final recorder = _TapRecorder(reaction);
      await _pump(tester, reaction, recorder);

      reaction.start(ReactionMode.goNoGo);
      await _toStimulus(tester, reaction);

      expect(reaction.isGo, isFalse);
      expect(find.text('HOLD'), findsOneWidget);

      await tester.tap(find.byType(ReactionArena));
      await tester.pump();

      expect(recorder.calls, hasLength(1));
      expect(reaction.feedback, 'Hold!');
      expect(reaction.feedback, isNot(endsWith('ms')));

      reaction.dispose();
    },
  );

  testWidgets(
    'peripheral mode positions its dot from the provider offset, not the '
    'centre, and reports a tap there',
    (tester) async {
      _growViewport(tester);
      var now = DateTime(2026, 1, 1);
      final reaction = ReactionProvider(
        clock: () => now,
        random: _FixedRandom(doubleValue: 0.25),
      );
      final recorder = _TapRecorder(reaction);
      const size = Size(400, 800);
      await _pump(tester, reaction, recorder, size: size);

      reaction.start(ReactionMode.peripheral);
      await _toStimulus(tester, reaction);

      expect(find.byType(SequencePad), findsNothing);
      expect(find.byType(DefenseGrid), findsNothing);
      expect(find.byType(ColourGrid), findsNothing);

      final dot = reaction.dotPosition!;
      expect(dot.dx, closeTo(0.3, 1e-9));
      expect(dot.dy, closeTo(0.3, 1e-9));

      // _PeripheralField is private; the dot is its sole Positioned child,
      // 44dp square (_dotSize), centred on the provider's fractional offset.
      const dotRadius = 22.0;
      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      final expectedLeft = dot.dx * size.width - dotRadius;
      final expectedTop = dot.dy * size.height - dotRadius;
      final centreLeft = size.width / 2 - dotRadius;
      final centreTop = size.height / 2 - dotRadius;
      expect(positioned.left, closeTo(expectedLeft, 0.5));
      expect(positioned.top, closeTo(expectedTop, 0.5));
      expect(positioned.left, isNot(closeTo(centreLeft, 0.5)));
      expect(positioned.top, isNot(closeTo(centreTop, 0.5)));

      final arena = tester.getTopLeft(find.byType(ReactionArena));
      now = now.add(const Duration(milliseconds: 210));
      await tester.tapAt(
        Offset(arena.dx + dot.dx * size.width, arena.dy + dot.dy * size.height),
      );
      await tester.pump();

      expect(recorder.calls, hasLength(1));
      final at = recorder.calls.single.at!;
      expect(at.dx, closeTo(dot.dx, 0.01));
      expect(at.dy, closeTo(dot.dy, 0.01));
      expect(reaction.feedback, '210 ms');

      reaction.dispose();
    },
  );

  testWidgets(
    'sequence mode shows the sequence pad and accepts the shown sequence '
    'tapped back',
    (tester) async {
      var now = DateTime(2026, 1, 1);
      final reaction = ReactionProvider(
        clock: () => now,
        random: _FixedRandom(),
      );
      final recorder = _TapRecorder(reaction);
      await _pump(tester, reaction, recorder);

      reaction.start(ReactionMode.sequence);
      await _toStimulus(tester, reaction);

      expect(find.byType(SequencePad), findsOneWidget);
      expect(find.byType(DefenseGrid), findsNothing);
      expect(find.byType(ColourGrid), findsNothing);

      final sequence = reaction.sequence;
      expect(reaction.isShowingSequence, isTrue);
      // A fixed random always answers index 0, so every arrow is up.
      expect(sequence, everyElement(ReactionDirection.up));

      await tester.pump(Duration(milliseconds: 600 * sequence.length));
      expect(reaction.isShowingSequence, isFalse);

      final arena = tester.getTopLeft(find.byType(ReactionArena));
      final size = tester.getSize(find.byType(ReactionArena));
      for (var i = 0; i < sequence.length; i++) {
        now = now.add(const Duration(milliseconds: 100));
        await tester.tapAt(
          Offset(arena.dx + size.width * 0.5, arena.dy + size.height * 0.1),
        );
        await tester.pump();
      }

      expect(reaction.misses, 0);
      expect(recorder.calls, hasLength(sequence.length));

      reaction.dispose();
    },
  );

  testWidgets('sound mode shows a plain hit area with no visual stimulus', (
    tester,
  ) async {
    final reaction = ReactionProvider(
      clock: () => DateTime(2026, 1, 1),
      random: _FixedRandom(),
    );
    final recorder = _TapRecorder(reaction);
    await _pump(tester, reaction, recorder);

    reaction.start(ReactionMode.sound);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(reaction.phase, ReactionPhase.waiting);
    expect(find.byType(SequencePad), findsNothing);
    expect(find.byType(DefenseGrid), findsNothing);
    expect(find.byType(ColourGrid), findsNothing);

    await _elapseToPhase(tester, reaction, ReactionPhase.stimulus);

    await tester.tap(find.byType(ReactionArena));
    await tester.pump();

    expect(recorder.calls, hasLength(1));
    expect(reaction.phase, ReactionPhase.feedback);

    reaction.dispose();
  });

  testWidgets('renders and still reports taps with reduce motion on', (
    tester,
  ) async {
    var now = DateTime(2026, 1, 1);
    final reaction = ReactionProvider(clock: () => now);
    final recorder = _TapRecorder(reaction);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: ChangeNotifierProvider<ReactionProvider>.value(
            value: reaction,
            child: Scaffold(
              body: SizedBox(
                width: 400,
                height: 800,
                child: Consumer<ReactionProvider>(
                  builder: (context, reaction, _) =>
                      ReactionArena(reaction: reaction, onTap: recorder.call),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    reaction.start(ReactionMode.tap);
    await _toStimulus(tester, reaction);

    expect(find.byType(ReactionArena), findsOneWidget);
    expect(find.text('GO'), findsOneWidget);

    now = now.add(const Duration(milliseconds: 100));
    await tester.tap(find.byType(ReactionArena));
    await tester.pump();

    expect(recorder.calls, hasLength(1));
    expect(reaction.feedback, '100 ms');

    reaction.dispose();
  });
}
