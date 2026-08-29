import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/reaction_format.dart';
import 'package:boxer_os/models/reaction_mode.dart';
import 'package:boxer_os/models/reaction_result.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/utils/milestones.dart';
import 'package:boxer_os/utils/training_stats.dart';

TrainingStats _stats({
  int totalSessions = 0,
  int totalRounds = 0,
  int streakDays = 0,
  Map<TrainingType, DateTime> lastTrainedByType = const {},
}) => TrainingStats(
  weekRounds: 0,
  weekMinutes: 0,
  streakDays: streakDays,
  totalRounds: totalRounds,
  totalMinutes: 0,
  totalSessions: totalSessions,
  weekRoundsByType: const {},
  minutesByDay: const [0, 0, 0, 0, 0, 0, 0],
  lastTrainedByType: lastTrainedByType,
);

ReactionResult _reaction(
  int bestMillis, {
  ReactionFormat format = ReactionFormat.standard,
}) => ReactionResult(
  mode: ReactionMode.tap,
  format: format,
  completedAt: DateTime(2026, 8, 29),
  reactionMillis: [bestMillis],
  falseStarts: 0,
  misses: 0,
);

void main() {
  test(
    'returns eight entries in the fixed order, all unachieved for empty stats',
    () {
      final milestones = computeMilestones(_stats(), const []);

      expect(milestones.map((milestone) => milestone.id).toList(), [
        'first_session',
        'ten_sessions',
        'hundred_rounds',
        'five_hundred_rounds',
        'streak_seven',
        'reaction_250',
        'all_types',
        'endurance_first',
      ]);
      expect(milestones.every((milestone) => !milestone.achieved), isTrue);
    },
  );

  test('first_session flips at totalSessions >= 1', () {
    expect(
      computeMilestones(_stats(totalSessions: 0), const [])[0].achieved,
      isFalse,
    );
    expect(
      computeMilestones(_stats(totalSessions: 1), const [])[0].achieved,
      isTrue,
    );
  });

  test('ten_sessions flips at totalSessions >= 10', () {
    expect(
      computeMilestones(_stats(totalSessions: 9), const [])[1].achieved,
      isFalse,
    );
    expect(
      computeMilestones(_stats(totalSessions: 10), const [])[1].achieved,
      isTrue,
    );
  });

  test('hundred_rounds flips at totalRounds >= 100', () {
    expect(
      computeMilestones(_stats(totalRounds: 99), const [])[2].achieved,
      isFalse,
    );
    expect(
      computeMilestones(_stats(totalRounds: 100), const [])[2].achieved,
      isTrue,
    );
  });

  test('five_hundred_rounds flips at totalRounds >= 500', () {
    expect(
      computeMilestones(_stats(totalRounds: 499), const [])[3].achieved,
      isFalse,
    );
    expect(
      computeMilestones(_stats(totalRounds: 500), const [])[3].achieved,
      isTrue,
    );
  });

  test('streak_seven flips at streakDays >= 7', () {
    expect(
      computeMilestones(_stats(streakDays: 6), const [])[4].achieved,
      isFalse,
    );
    expect(
      computeMilestones(_stats(streakDays: 7), const [])[4].achieved,
      isTrue,
    );
  });

  test('reaction_250 achieves when any reaction bestMillis is under 250', () {
    expect(computeMilestones(_stats(), [_reaction(250)])[5].achieved, isFalse);
    expect(
      computeMilestones(_stats(), [_reaction(260), _reaction(249)])[5].achieved,
      isTrue,
    );
  });

  test('all_types achieves only once every arsenal type has trained', () {
    final almost = {
      TrainingType.shadowBoxing: DateTime(2026, 8, 1),
      TrainingType.heavyBag: DateTime(2026, 8, 1),
      TrainingType.footwork: DateTime(2026, 8, 1),
      TrainingType.conditioning: DateTime(2026, 8, 1),
    };
    final complete = {...almost, TrainingType.sparring: DateTime(2026, 8, 1)};

    expect(
      computeMilestones(
        _stats(lastTrainedByType: almost),
        const [],
      )[6].achieved,
      isFalse,
    );
    expect(
      computeMilestones(
        _stats(lastTrainedByType: complete),
        const [],
      )[6].achieved,
      isTrue,
    );
  });

  test(
    'endurance_first achieves only when a result used the endurance format',
    () {
      expect(
        computeMilestones(_stats(), [_reaction(500)])[7].achieved,
        isFalse,
      );
      expect(
        computeMilestones(_stats(), [
          _reaction(500, format: ReactionFormat.endurance),
        ])[7].achieved,
        isTrue,
      );
    },
  );
}
