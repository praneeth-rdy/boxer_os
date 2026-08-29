import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/defense_zone.dart';
import 'package:boxer_os/models/reaction_direction.dart';
import 'package:boxer_os/models/reaction_format.dart';
import 'package:boxer_os/models/reaction_mode.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/providers/reaction_provider.dart';

const _step = Duration(milliseconds: 10);

/// Elapses in small steps so a timer boundary is never overshot mid-jump.
void _elapseUntil(
  FakeAsync async,
  ReactionProvider provider,
  ReactionPhase phase,
) {
  var budget = const Duration(seconds: 10);
  while (provider.phase != phase) {
    async.elapse(_step);
    budget -= _step;
    if (budget.isNegative) {
      fail('phase never reached $phase (stuck at ${provider.phase})');
    }
  }
}

void main() {
  group('ReactionProvider', () {
    test(
      'start counts down 3, 2, 1, waits, shows the stimulus and records a hit',
      () {
        fakeAsync((async) {
          var now = DateTime(2026, 1, 1);
          final provider = ReactionProvider(
            clock: () => now,
            random: Random(1),
          );

          provider.start(ReactionMode.tap);
          expect(provider.phase, ReactionPhase.countdown);
          expect(provider.countdownSeconds, 3);

          async.elapse(const Duration(seconds: 1));
          expect(provider.countdownSeconds, 2);
          async.elapse(const Duration(seconds: 1));
          expect(provider.countdownSeconds, 1);
          async.elapse(const Duration(seconds: 1));
          expect(provider.phase, ReactionPhase.waiting);

          _elapseUntil(async, provider, ReactionPhase.stimulus);

          now = now.add(const Duration(milliseconds: 230));
          provider.tap();
          expect(provider.phase, ReactionPhase.feedback);
          expect(provider.lastMillis, 230);
          expect(provider.feedback, '230 ms');

          async.elapse(const Duration(milliseconds: 700));
          expect(provider.phase, ReactionPhase.waiting);

          provider.dispose();
        });
      },
    );

    test(
      'finishing all ten trials builds a result with best and average millis',
      () {
        fakeAsync((async) {
          var now = DateTime(2026, 1, 1);
          final provider = ReactionProvider(
            clock: () => now,
            random: Random(1),
          );

          provider.start(ReactionMode.tap);
          async.elapse(const Duration(seconds: 3));

          final hitMillis = <int>[];
          for (var trial = 0; trial < ReactionProvider.trialCount; trial++) {
            _elapseUntil(async, provider, ReactionPhase.stimulus);
            final elapsed = 200 + trial * 10;
            now = now.add(Duration(milliseconds: elapsed));
            hitMillis.add(elapsed);
            provider.tap();
            expect(provider.phase, ReactionPhase.feedback);
            async.elapse(const Duration(milliseconds: 700));
          }

          expect(provider.phase, ReactionPhase.complete);
          final result = provider.result;
          expect(result, isNotNull);
          expect(result!.reactionMillis, hitMillis);
          expect(result.bestMillis, hitMillis.reduce(min));
          final expectedAverage =
              (hitMillis.reduce((a, b) => a + b) / hitMillis.length).round();
          expect(result.averageMillis, expectedAverage);
          expect(result.falseStarts, 0);
          expect(result.misses, 0);

          provider.dispose();
        });
      },
    );

    test(
      'a tap during waiting is a false start, shows Early! and does not consume the trial',
      () {
        fakeAsync((async) {
          var now = DateTime(2026, 1, 1);
          final provider = ReactionProvider(
            clock: () => now,
            random: Random(1),
          );

          provider.start(ReactionMode.tap);
          async.elapse(const Duration(seconds: 3));
          expect(provider.phase, ReactionPhase.waiting);

          final trialBefore = provider.trial;
          provider.tap();
          expect(provider.falseStarts, 1);
          expect(provider.feedback, 'Early!');
          expect(provider.phase, ReactionPhase.feedback);

          async.elapse(const Duration(milliseconds: 700));
          expect(provider.phase, ReactionPhase.waiting);
          expect(provider.trial, trialBefore);

          provider.dispose();
        });
      },
    );

    test('in direction mode a wrong zone counts as a miss', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final provider = ReactionProvider(clock: () => now, random: Random(1));

        provider.start(ReactionMode.direction);
        async.elapse(const Duration(seconds: 3));
        _elapseUntil(async, provider, ReactionPhase.stimulus);

        final correct = provider.direction!;
        final wrong = ReactionDirection.values.firstWhere(
          (direction) => direction != correct,
        );
        provider.tap(direction: wrong);

        expect(provider.misses, 1);
        expect(provider.feedback, 'Wrong side');
        expect(provider.phase, ReactionPhase.feedback);

        provider.dispose();
      });
    });

    test('in direction mode a matching zone records the reaction time', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final provider = ReactionProvider(clock: () => now, random: Random(1));

        provider.start(ReactionMode.direction);
        async.elapse(const Duration(seconds: 3));
        _elapseUntil(async, provider, ReactionPhase.stimulus);

        final correct = provider.direction!;
        now = now.add(const Duration(milliseconds: 180));
        provider.tap(direction: correct);

        expect(provider.misses, 0);
        expect(provider.lastMillis, 180);
        expect(provider.feedback, '180 ms');

        provider.dispose();
      });
    });

    test('no tap within 2s of the stimulus is a miss with Too slow', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final provider = ReactionProvider(clock: () => now, random: Random(1));

        provider.start(ReactionMode.tap);
        async.elapse(const Duration(seconds: 3));
        _elapseUntil(async, provider, ReactionPhase.stimulus);

        async.elapse(const Duration(milliseconds: 2000));
        expect(provider.misses, 1);
        expect(provider.feedback, 'Too slow');
        expect(provider.phase, ReactionPhase.feedback);

        provider.dispose();
      });
    });

    test(
      'cancel mid-trial returns to idle with no result and cancels pending timers',
      () {
        fakeAsync((async) {
          var now = DateTime(2026, 1, 1);
          final provider = ReactionProvider(
            clock: () => now,
            random: Random(1),
          );

          provider.start(ReactionMode.tap);
          async.elapse(const Duration(seconds: 1));

          provider.cancel();

          expect(provider.phase, ReactionPhase.idle);
          expect(provider.trial, 0);
          expect(provider.result, isNull);
          expect(async.pendingTimers, isEmpty);

          provider.dispose();
        });
      },
    );

    test('taps are ignored during countdown', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final provider = ReactionProvider(clock: () => now, random: Random(1));

        provider.start(ReactionMode.tap);
        expect(provider.phase, ReactionPhase.countdown);
        provider.tap();
        expect(provider.falseStarts, 0);
        expect(provider.misses, 0);
        expect(provider.phase, ReactionPhase.countdown);

        provider.dispose();
      });
    });

    test('taps are ignored while idle', () {
      fakeAsync((async) {
        final provider = ReactionProvider(random: Random(1));

        expect(provider.phase, ReactionPhase.idle);
        provider.tap();
        expect(provider.falseStarts, 0);
        expect(provider.misses, 0);

        provider.dispose();
      });
    });

    test('in defense mode a matching zone records the reaction time', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final provider = ReactionProvider(clock: () => now, random: Random(1));

        provider.start(ReactionMode.defense, stance: Stance.orthodox);
        async.elapse(const Duration(seconds: 3));
        _elapseUntil(async, provider, ReactionPhase.stimulus);

        final punch = provider.incomingPunch!;
        final correctDefense = defenseFor(punch, Stance.orthodox);
        now = now.add(const Duration(milliseconds: 210));
        provider.tap(defense: correctDefense);

        expect(provider.misses, 0);
        expect(provider.lastMillis, 210);
        expect(provider.feedback, '210 ms');

        provider.dispose();
      });
    });

    test('in defense mode a wrong zone is a miss with Wrong defense', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final provider = ReactionProvider(clock: () => now, random: Random(1));

        provider.start(ReactionMode.defense, stance: Stance.orthodox);
        async.elapse(const Duration(seconds: 3));
        _elapseUntil(async, provider, ReactionPhase.stimulus);

        final punch = provider.incomingPunch!;
        final correctDefense = defenseFor(punch, Stance.orthodox);
        final wrongDefense = DefenseZone.values.firstWhere(
          (zone) => zone != correctDefense,
        );
        provider.tap(defense: wrongDefense);

        expect(provider.misses, 1);
        expect(provider.feedback, 'Wrong defense');
        expect(provider.phase, ReactionPhase.feedback);

        provider.dispose();
      });
    });

    test(
      'in defense mode tapping with no defense chosen is a miss with Wrong defense',
      () {
        fakeAsync((async) {
          var now = DateTime(2026, 1, 1);
          final provider = ReactionProvider(
            clock: () => now,
            random: Random(1),
          );

          provider.start(ReactionMode.defense, stance: Stance.orthodox);
          async.elapse(const Duration(seconds: 3));
          _elapseUntil(async, provider, ReactionPhase.stimulus);

          provider.tap();

          expect(provider.misses, 1);
          expect(provider.feedback, 'Wrong defense');

          provider.dispose();
        });
      },
    );

    test('defenseFor mirrors the slips for a southpaw stance', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final provider = ReactionProvider(clock: () => now, random: Random(1));

        provider.start(ReactionMode.defense, stance: Stance.southpaw);
        async.elapse(const Duration(seconds: 3));
        _elapseUntil(async, provider, ReactionPhase.stimulus);

        final punch = provider.incomingPunch!;
        provider.tap(defense: defenseFor(punch, Stance.southpaw));

        expect(provider.misses, 0);
        expect(provider.stance, Stance.southpaw);

        provider.dispose();
      });
    });

    test('go / no-go: a go stimulus behaves like a tap and records time', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final provider = ReactionProvider(clock: () => now, random: Random(1));

        provider.start(ReactionMode.goNoGo);
        async.elapse(const Duration(seconds: 3));
        _elapseUntil(async, provider, ReactionPhase.stimulus);

        expect(provider.isGo, isTrue);
        now = now.add(const Duration(milliseconds: 190));
        provider.tap();

        expect(provider.lastMillis, 190);
        expect(provider.feedback, '190 ms');
        expect(provider.correctHolds, 0);
        expect(provider.falseAlarms, 0);

        provider.dispose();
      });
    });

    test(
      'go / no-go: a hold stimulus left alone becomes a correct hold after 1000 ms',
      () {
        fakeAsync((async) {
          var now = DateTime(2026, 1, 1);
          final provider = ReactionProvider(
            clock: () => now,
            random: Random(2),
          );

          provider.start(ReactionMode.goNoGo);
          async.elapse(const Duration(seconds: 3));
          _elapseUntil(async, provider, ReactionPhase.stimulus);

          expect(provider.isGo, isFalse);
          async.elapse(const Duration(milliseconds: 1000));

          expect(provider.correctHolds, 1);
          expect(provider.falseAlarms, 0);
          expect(provider.feedback, 'Good hold');
          expect(provider.phase, ReactionPhase.feedback);

          provider.dispose();
        });
      },
    );

    test('go / no-go: tapping during a hold stimulus is a false alarm', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final provider = ReactionProvider(clock: () => now, random: Random(2));

        provider.start(ReactionMode.goNoGo);
        async.elapse(const Duration(seconds: 3));
        _elapseUntil(async, provider, ReactionPhase.stimulus);

        expect(provider.isGo, isFalse);
        provider.tap();

        expect(provider.falseAlarms, 1);
        expect(provider.correctHolds, 0);
        expect(provider.feedback, 'Hold!');
        expect(provider.phase, ReactionPhase.feedback);

        provider.dispose();
      });
    });

    test(
      'endurance format completes once the elapsed time reaches 60 s, with a fixed duration',
      () {
        fakeAsync((async) {
          var now = DateTime(2026, 1, 1);
          final provider = ReactionProvider(
            clock: () => now,
            random: Random(1),
          );

          provider.start(ReactionMode.tap, format: ReactionFormat.endurance);
          expect(provider.format, ReactionFormat.endurance);
          async.elapse(const Duration(seconds: 3));

          var iterations = 0;
          while (provider.phase != ReactionPhase.complete) {
            _elapseUntil(async, provider, ReactionPhase.stimulus);
            now = now.add(const Duration(milliseconds: 4000));
            provider.tap();
            async.elapse(const Duration(milliseconds: 700));
            iterations++;
            if (iterations > 30) {
              fail('endurance run never completed');
            }
          }

          final result = provider.result;
          expect(result, isNotNull);
          expect(result!.format, ReactionFormat.endurance);
          expect(result.durationSeconds, ReactionProvider.enduranceSeconds);
          expect(result.reactionMillis.length, greaterThanOrEqualTo(4));
          expect(result.decayPercent, isNotNull);

          provider.dispose();
        });
      },
    );

    test('secondsLeft is 0 in the standard format', () {
      fakeAsync((async) {
        final provider = ReactionProvider(random: Random(1));
        provider.start(ReactionMode.tap);
        expect(provider.secondsLeft, 0);
        provider.dispose();
      });
    });

    test(
      'secondsLeft counts down from 60 once the first stimulus shows in endurance',
      () {
        fakeAsync((async) {
          var now = DateTime(2026, 1, 1);
          final provider = ReactionProvider(
            clock: () => now,
            random: Random(1),
          );

          provider.start(ReactionMode.tap, format: ReactionFormat.endurance);
          expect(provider.secondsLeft, ReactionProvider.enduranceSeconds);

          async.elapse(const Duration(seconds: 3));
          _elapseUntil(async, provider, ReactionPhase.stimulus);
          now = now.add(const Duration(seconds: 10));
          expect(provider.secondsLeft, ReactionProvider.enduranceSeconds - 10);

          provider.dispose();
        });
      },
    );

    test('cancel resets correct holds, false alarms and format', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final provider = ReactionProvider(clock: () => now, random: Random(2));

        provider.start(ReactionMode.goNoGo, format: ReactionFormat.endurance);
        async.elapse(const Duration(seconds: 3));
        _elapseUntil(async, provider, ReactionPhase.stimulus);
        async.elapse(const Duration(milliseconds: 1000));
        expect(provider.correctHolds, 1);

        provider.cancel();

        expect(provider.phase, ReactionPhase.idle);
        expect(provider.correctHolds, 0);
        expect(provider.falseAlarms, 0);
        expect(provider.result, isNull);
        expect(async.pendingTimers, isEmpty);

        provider.dispose();
      });
    });
  });
}
