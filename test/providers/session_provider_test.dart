import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/round_cue.dart';
import 'package:boxer_os/models/round_spec.dart';
import 'package:boxer_os/models/session_event.dart';
import 'package:boxer_os/models/session_phase.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/models/workout.dart';
import 'package:boxer_os/providers/session_provider.dart';

Workout _workout({int prepareSeconds = 0, required List<RoundSpec> rounds}) =>
    Workout(
      id: 'test',
      name: 'Test workout',
      type: TrainingType.shadowBoxing,
      difficulty: Difficulty.beginner,
      rounds: rounds,
      prepareSeconds: prepareSeconds,
    );

void main() {
  group('SessionProvider', () {
    test(
      'start runs prepare, work and rest through to sessionCompleted in order',
      () {
        fakeAsync((async) {
          var now = DateTime(2026, 1, 1);
          final provider = SessionProvider(clock: () => now);
          final events = <SessionEventType>[];
          provider.events.listen((event) => events.add(event.type));

          final workout = _workout(
            prepareSeconds: 2,
            rounds: [
              const RoundSpec(workSeconds: 5, restSeconds: 3),
              const RoundSpec(workSeconds: 5, restSeconds: 3),
            ],
          );
          provider.start(
            workout,
            stance: Stance.orthodox,
            difficulty: Difficulty.beginner,
          );

          for (var i = 0; i < 16; i++) {
            now = now.add(const Duration(seconds: 1));
            async.elapse(const Duration(seconds: 1));
          }

          expect(events, [
            SessionEventType.prepareStarted,
            SessionEventType.roundStarted,
            SessionEventType.restStarted,
            SessionEventType.roundStarted,
            SessionEventType.sessionCompleted,
          ]);
          expect(provider.roundsCompleted, 2);
          expect(provider.record?.completed, isTrue);

          provider.dispose();
        });
      },
    );

    test('a 60 s work round emits finalThirty once at 30 s left and '
        'tenSecondWarning once at 10 s left', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final provider = SessionProvider(clock: () => now);
        final events = <SessionEventType>[];
        provider.events.listen((event) => events.add(event.type));

        provider.start(
          _workout(rounds: [const RoundSpec(workSeconds: 60, restSeconds: 0)]),
          stance: Stance.orthodox,
          difficulty: Difficulty.beginner,
        );

        for (var i = 0; i < 60; i++) {
          now = now.add(const Duration(seconds: 1));
          async.elapse(const Duration(seconds: 1));
        }

        expect(
          events.where((type) => type == SessionEventType.finalThirty).length,
          1,
        );
        expect(
          events
              .where((type) => type == SessionEventType.tenSecondWarning)
              .length,
          1,
        );

        provider.dispose();
      });
    });

    test('a 15 s round emits neither finalThirty nor tenSecondWarning', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final provider = SessionProvider(clock: () => now);
        final events = <SessionEventType>[];
        provider.events.listen((event) => events.add(event.type));

        provider.start(
          _workout(rounds: [const RoundSpec(workSeconds: 15, restSeconds: 0)]),
          stance: Stance.orthodox,
          difficulty: Difficulty.beginner,
        );

        for (var i = 0; i < 15; i++) {
          now = now.add(const Duration(seconds: 1));
          async.elapse(const Duration(seconds: 1));
        }

        expect(events, isNot(contains(SessionEventType.finalThirty)));
        expect(events, isNot(contains(SessionEventType.tenSecondWarning)));

        provider.dispose();
      });
    });

    test('cues fire with their text at the elapsed second and currentCue '
        'tracks the latest, clearing on rest', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final provider = SessionProvider(clock: () => now);
        final cueEvents = <SessionEvent>[];
        provider.events
            .where((event) => event.type == SessionEventType.cue)
            .listen(cueEvents.add);

        final workout = _workout(
          rounds: [
            const RoundSpec(
              workSeconds: 60,
              restSeconds: 5,
              cues: [
                RoundCue(atSecond: 3, text: 'jab'),
                RoundCue(atSecond: 20, text: 'cross'),
              ],
            ),
            const RoundSpec(workSeconds: 5, restSeconds: 0),
          ],
        );
        provider.start(
          workout,
          stance: Stance.orthodox,
          difficulty: Difficulty.beginner,
        );

        for (var i = 0; i < 25; i++) {
          now = now.add(const Duration(seconds: 1));
          async.elapse(const Duration(seconds: 1));
        }

        expect(cueEvents.map((e) => e.cueText), ['jab', 'cross']);
        expect(provider.currentCue, 'cross');

        for (var i = 0; i < 35; i++) {
          now = now.add(const Duration(seconds: 1));
          async.elapse(const Duration(seconds: 1));
        }

        expect(provider.phase, SessionPhase.rest);
        expect(provider.currentCue, isNull);

        provider.dispose();
      });
    });

    test(
      'both cues in a 25 s clock jump fire once, in order, on the next tick',
      () {
        fakeAsync((async) {
          var now = DateTime(2026, 1, 1);
          final provider = SessionProvider(clock: () => now);
          final cueEvents = <SessionEvent>[];
          provider.events
              .where((event) => event.type == SessionEventType.cue)
              .listen(cueEvents.add);

          provider.start(
            _workout(
              rounds: [
                const RoundSpec(
                  workSeconds: 60,
                  restSeconds: 0,
                  cues: [
                    RoundCue(atSecond: 3, text: 'jab'),
                    RoundCue(atSecond: 20, text: 'cross'),
                  ],
                ),
              ],
            ),
            stance: Stance.orthodox,
            difficulty: Difficulty.beginner,
          );

          now = now.add(const Duration(seconds: 25));
          async.elapse(const Duration(seconds: 1));

          expect(cueEvents.map((e) => e.cueText), ['jab', 'cross']);
          expect(provider.currentCue, 'cross');

          provider.dispose();
        });
      },
    );

    test(
      'pause freezes secondsLeft for any elapsed wall time; resume continues from it',
      () {
        fakeAsync((async) {
          var now = DateTime(2026, 1, 1);
          final provider = SessionProvider(clock: () => now);

          provider.start(
            _workout(
              rounds: [const RoundSpec(workSeconds: 30, restSeconds: 0)],
            ),
            stance: Stance.orthodox,
            difficulty: Difficulty.beginner,
          );

          for (var i = 0; i < 5; i++) {
            now = now.add(const Duration(seconds: 1));
            async.elapse(const Duration(seconds: 1));
          }
          expect(provider.secondsLeft, 25);

          provider.pause();
          expect(provider.isPaused, isTrue);

          for (var i = 0; i < 5; i++) {
            now = now.add(const Duration(seconds: 1));
            async.elapse(const Duration(seconds: 1));
          }
          expect(provider.secondsLeft, 25);

          provider.resume();
          expect(provider.isPaused, isFalse);

          for (var i = 0; i < 5; i++) {
            now = now.add(const Duration(seconds: 1));
            async.elapse(const Duration(seconds: 1));
          }
          expect(provider.secondsLeft, 20);

          provider.dispose();
        });
      },
    );

    test('resume keeps the phase length so progress does not snap back', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final provider = SessionProvider(clock: () => now);

        provider.start(
          _workout(rounds: [const RoundSpec(workSeconds: 60, restSeconds: 0)]),
          stance: Stance.orthodox,
          difficulty: Difficulty.beginner,
        );

        for (var i = 0; i < 20; i++) {
          now = now.add(const Duration(seconds: 1));
          async.elapse(const Duration(seconds: 1));
        }
        provider.pause();
        expect(provider.secondsLeft, 40);

        provider.resume();
        expect(provider.phaseSeconds, 60);
        expect(provider.secondsLeft, 40);

        now = now.add(const Duration(seconds: 1));
        async.elapse(const Duration(seconds: 1));
        expect(provider.phaseSeconds, 60);
        expect(provider.secondsLeft, 39);

        provider.dispose();
      });
    });

    test(
      'skipPhase in work moves to rest without incrementing roundsCompleted',
      () {
        fakeAsync((async) {
          var now = DateTime(2026, 1, 1);
          final provider = SessionProvider(clock: () => now);

          provider.start(
            _workout(
              rounds: [
                const RoundSpec(workSeconds: 10, restSeconds: 5),
                const RoundSpec(workSeconds: 10, restSeconds: 0),
              ],
            ),
            stance: Stance.orthodox,
            difficulty: Difficulty.beginner,
          );

          for (var i = 0; i < 3; i++) {
            now = now.add(const Duration(seconds: 1));
            async.elapse(const Duration(seconds: 1));
          }

          provider.skipPhase();

          expect(provider.phase, SessionPhase.rest);
          expect(provider.roundsCompleted, 0);

          provider.dispose();
        });
      },
    );

    test('skipping the last round yields a record that is not completed', () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1);
        final provider = SessionProvider(clock: () => now);

        provider.start(
          _workout(
            rounds: [
              const RoundSpec(workSeconds: 5, restSeconds: 0),
              const RoundSpec(workSeconds: 10, restSeconds: 0),
            ],
          ),
          stance: Stance.orthodox,
          difficulty: Difficulty.beginner,
        );

        for (var i = 0; i < 6; i++) {
          now = now.add(const Duration(seconds: 1));
          async.elapse(const Duration(seconds: 1));
        }
        expect(provider.roundsCompleted, 1);

        provider.skipPhase();

        expect(provider.phase, SessionPhase.complete);
        expect(provider.record?.completed, isFalse);
        expect(provider.record?.roundsCompleted, 1);

        provider.dispose();
      });
    });

    test(
      'end mid-round yields an incomplete record with rounds completed so far',
      () {
        fakeAsync((async) {
          var now = DateTime(2026, 1, 1);
          final provider = SessionProvider(clock: () => now);

          provider.start(
            _workout(
              rounds: [
                const RoundSpec(workSeconds: 5, restSeconds: 0),
                const RoundSpec(workSeconds: 10, restSeconds: 0),
              ],
            ),
            stance: Stance.orthodox,
            difficulty: Difficulty.beginner,
          );

          for (var i = 0; i < 8; i++) {
            now = now.add(const Duration(seconds: 1));
            async.elapse(const Duration(seconds: 1));
          }
          expect(provider.roundsCompleted, 1);

          provider.end();

          expect(provider.phase, SessionPhase.complete);
          expect(provider.record?.completed, isFalse);
          expect(provider.record?.roundsCompleted, 1);

          provider.dispose();
        });
      },
    );
  });
}
