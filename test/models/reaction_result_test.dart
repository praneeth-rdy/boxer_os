import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/reaction_format.dart';
import 'package:boxer_os/models/reaction_mode.dart';
import 'package:boxer_os/models/reaction_result.dart';

void main() {
  group('ReactionResult', () {
    test('trials counts hits and misses', () {
      final result = ReactionResult(
        mode: ReactionMode.tap,
        completedAt: DateTime(2026, 1, 1),
        reactionMillis: const [200, 300],
        falseStarts: 1,
        misses: 2,
      );
      expect(result.trials, 4);
    });

    test('bestMillis and averageMillis are null when there are no hits', () {
      final result = ReactionResult(
        mode: ReactionMode.tap,
        completedAt: DateTime(2026, 1, 1),
        reactionMillis: const [],
        falseStarts: 0,
        misses: 3,
      );
      expect(result.bestMillis, isNull);
      expect(result.averageMillis, isNull);
    });

    test(
      'bestMillis is the lowest reaction time and averageMillis is the rounded mean',
      () {
        final result = ReactionResult(
          mode: ReactionMode.direction,
          completedAt: DateTime(2026, 1, 1),
          reactionMillis: const [300, 200, 250],
          falseStarts: 0,
          misses: 0,
        );
        expect(result.bestMillis, 200);
        expect(result.averageMillis, 250);
      },
    );

    test('averageMillis rounds to the nearest millisecond', () {
      final result = ReactionResult(
        mode: ReactionMode.tap,
        completedAt: DateTime(2026, 1, 1),
        reactionMillis: const [100, 100, 101],
        falseStarts: 0,
        misses: 0,
      );
      expect(result.averageMillis, 100);
    });

    test('toJson then fromJson round-trips every field', () {
      final result = ReactionResult(
        mode: ReactionMode.direction,
        completedAt: DateTime(2026, 3, 4, 5, 6, 7),
        reactionMillis: const [210, 340],
        falseStarts: 2,
        misses: 1,
      );

      final restored = ReactionResult.fromJson(result.toJson());

      expect(restored, result);
    });

    test('fromJson falls back to tap mode for an unknown mode name', () {
      final restored = ReactionResult.fromJson(const {
        'mode': 'bogus',
        'completed_at': '2026-01-01T00:00:00.000',
        'reaction_millis': [100],
        'false_starts': 0,
        'misses': 0,
      });
      expect(restored.mode, ReactionMode.tap);
    });

    test('trials counts correct holds and false alarms too', () {
      final result = ReactionResult(
        mode: ReactionMode.goNoGo,
        completedAt: DateTime(2026, 1, 1),
        reactionMillis: const [200, 300],
        falseStarts: 0,
        misses: 1,
        correctHolds: 3,
        falseAlarms: 2,
      );
      expect(result.trials, 8);
    });

    test(
      'fromJson without the new keys falls back to standard format and zero counts',
      () {
        final restored = ReactionResult.fromJson(const {
          'mode': 'tap',
          'completed_at': '2026-01-01T00:00:00.000',
          'reaction_millis': [100, 200],
          'false_starts': 0,
          'misses': 1,
        });
        expect(restored.format, ReactionFormat.standard);
        expect(restored.correctHolds, 0);
        expect(restored.falseAlarms, 0);
        expect(restored.durationSeconds, 0);
      },
    );

    test('toJson then fromJson round-trips the new fields', () {
      final result = ReactionResult(
        mode: ReactionMode.goNoGo,
        format: ReactionFormat.endurance,
        completedAt: DateTime(2026, 3, 4, 5, 6, 7),
        reactionMillis: const [210, 340],
        falseStarts: 0,
        misses: 1,
        correctHolds: 4,
        falseAlarms: 2,
        durationSeconds: 60,
      );

      final restored = ReactionResult.fromJson(result.toJson());

      expect(restored, result);
    });

    test('firstHalfAverage and secondHalfAverage are null under four hits', () {
      final result = ReactionResult(
        mode: ReactionMode.tap,
        completedAt: DateTime(2026, 1, 1),
        reactionMillis: const [100, 200, 300],
        falseStarts: 0,
        misses: 0,
      );
      expect(result.firstHalfAverage, isNull);
      expect(result.secondHalfAverage, isNull);
      expect(result.decayPercent, isNull);
    });

    test(
      'firstHalfAverage, secondHalfAverage and decayPercent split four hits in half',
      () {
        final result = ReactionResult(
          mode: ReactionMode.tap,
          completedAt: DateTime(2026, 1, 1),
          reactionMillis: const [100, 200, 300, 400],
          falseStarts: 0,
          misses: 0,
        );
        expect(result.firstHalfAverage, 150);
        expect(result.secondHalfAverage, 350);
        expect(result.decayPercent, 133);
      },
    );

    test(
      'accuracy counts hits over hits, misses and false alarms, not correct holds',
      () {
        final result = ReactionResult(
          mode: ReactionMode.goNoGo,
          completedAt: DateTime(2026, 1, 1),
          reactionMillis: const [100, 200],
          falseStarts: 0,
          misses: 1,
          correctHolds: 5,
          falseAlarms: 1,
        );
        expect(result.accuracy, 0.5);
      },
    );

    test('accuracy is null when there are no hits, misses or false alarms', () {
      final result = ReactionResult(
        mode: ReactionMode.tap,
        completedAt: DateTime(2026, 1, 1),
        reactionMillis: const [],
        falseStarts: 0,
        misses: 0,
      );
      expect(result.accuracy, isNull);
    });
  });
}
