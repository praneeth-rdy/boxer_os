import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/footwork_drills.dart';
import 'package:boxer_os/data/workout_library.dart';
import 'package:boxer_os/models/training_type.dart';

void main() {
  test('footworkDrills has five drills', () {
    expect(footworkDrills.length, 5);
  });

  test('every id is unique, prefixed fw_ and not in workoutLibrary', () {
    final ids = footworkDrills.map((drill) => drill.id).toList();
    final libraryIds = workoutLibrary.map((workout) => workout.id).toSet();

    expect(ids.toSet().length, ids.length, reason: 'duplicate drill id found');
    for (final id in ids) {
      expect(id.startsWith('fw_'), true, reason: '$id is not prefixed fw_');
      expect(
        libraryIds.contains(id),
        false,
        reason: '$id collides with a workoutLibrary id',
      );
    }
  });

  test('every drill is type footwork and not custom', () {
    for (final drill in footworkDrills) {
      expect(drill.type, TrainingType.footwork, reason: drill.id);
      expect(drill.isCustom, false, reason: drill.id);
    }
  });

  test('every drill has rounds', () {
    for (final drill in footworkDrills) {
      expect(drill.rounds, isNotEmpty, reason: '${drill.id} has no rounds');
    }
  });

  test('every round has 4 to 8 cues, strictly increasing and in range', () {
    for (final drill in footworkDrills) {
      for (final round in drill.rounds) {
        expect(
          round.cues.length,
          inInclusiveRange(4, 8),
          reason: '${drill.id} round has an out-of-range cue count',
        );

        var previousAtSecond = -1;
        for (final cue in round.cues) {
          expect(
            cue.atSecond,
            greaterThan(previousAtSecond),
            reason: '${drill.id} cues are not strictly increasing',
          );
          expect(
            cue.atSecond,
            greaterThan(0),
            reason: '${drill.id} has a cue at or before second 0',
          );
          expect(
            cue.atSecond,
            lessThan(round.workSeconds - 4),
            reason: '${drill.id} has a cue too close to the end of the round',
          );
          expect(
            cue.text.length,
            lessThanOrEqualTo(30),
            reason:
                '${drill.id} cue "${cue.text}" is longer than 30 characters',
          );
          previousAtSecond = cue.atSecond;
        }
      }
    }
  });

  test('the first cue in every round lands between 3 and 5 seconds', () {
    for (final drill in footworkDrills) {
      for (final round in drill.rounds) {
        expect(
          round.cues.first.atSecond,
          inInclusiveRange(3, 5),
          reason: '${drill.id} first cue is outside the 3-5s window',
        );
      }
    }
  });

  group('findFootworkDrill', () {
    test('returns the matching drill by id', () {
      final drill = findFootworkDrill('fw_cut_the_ring');

      expect(drill, isNotNull);
      expect(drill!.name, 'Cut the Ring');
    });

    test('returns null for an unknown id', () {
      expect(findFootworkDrill('not_a_real_drill'), isNull);
    });

    test('returns null for a workoutLibrary id', () {
      expect(findFootworkDrill('footwork_ladder'), isNull);
    });
  });
}
