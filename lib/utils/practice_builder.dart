import '../models/combination.dart';
import '../models/difficulty.dart';
import '../models/round_cue.dart';
import '../models/round_spec.dart';
import '../models/training_type.dart';
import '../models/workout.dart';

/// Seconds between two called combinations inside a practice round.
const int practiceCueInterval = 20;

const int _restSeconds = 45;
const int _firstCueSecond = 3;
const int _cueTailSeconds = 5;

/// How many combinations a practice round of [roundSeconds] calls.
int practiceCuesPerRound(int roundSeconds) {
  var count = 0;
  for (
    var second = _firstCueSecond;
    second < roundSeconds - _cueTailSeconds;
    second += practiceCueInterval
  ) {
    count++;
  }
  return count;
}

/// A shadow boxing drill that calls [combinations] in order, round after round.
Workout buildPracticeWorkout({
  required List<Combination> combinations,
  required int rounds,
  required int roundSeconds,
  required Difficulty difficulty,
  String name = 'Combo practice',
}) {
  var called = 0;
  final specs = <RoundSpec>[];
  for (var round = 0; round < rounds; round++) {
    final cues = <RoundCue>[];
    for (
      var second = _firstCueSecond;
      combinations.isNotEmpty && second < roundSeconds - _cueTailSeconds;
      second += practiceCueInterval
    ) {
      final combination = combinations[called % combinations.length];
      cues.add(RoundCue(atSecond: second, text: combination.notation));
      called++;
    }
    specs.add(
      RoundSpec(
        workSeconds: roundSeconds,
        restSeconds: _restSeconds,
        focus: 'Combo round ${round + 1}',
        cues: cues,
      ),
    );
  }
  return Workout(
    id: 'combo_practice',
    name: name,
    type: TrainingType.shadowBoxing,
    difficulty: difficulty,
    isCustom: true,
    rounds: specs,
  );
}
