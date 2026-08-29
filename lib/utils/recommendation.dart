import '../data/workout_library.dart';
import '../models/difficulty.dart';
import '../models/training_type.dart';
import '../models/workout.dart';
import 'training_stats.dart';

/// Recommendable types, first one wins a tie. Sparring is out: it needs a partner.
const List<TrainingType> _candidateTypes = [
  TrainingType.shadowBoxing,
  TrainingType.heavyBag,
  TrainingType.footwork,
  TrainingType.conditioning,
  TrainingType.mittWork,
  TrainingType.speedBag,
  TrainingType.strength,
];

/// Today's session: the least recently trained type, at or nearest [difficulty].
Workout recommendWorkout(
  TrainingStats stats,
  Difficulty difficulty, {
  required DateTime now,
}) {
  var chosenType = _candidateTypes.first;
  var longest = _daysSinceTrained(stats, chosenType, now);
  for (final type in _candidateTypes.skip(1)) {
    final days = _daysSinceTrained(stats, type, now);
    if (days > longest) {
      chosenType = type;
      longest = days;
    }
  }

  final candidates = workoutsOfType(chosenType);
  var chosen = candidates.first;
  var closest = _levelDistance(chosen.difficulty, difficulty);
  for (final workout in candidates.skip(1)) {
    final distance = _levelDistance(workout.difficulty, difficulty);
    if (distance < closest) {
      chosen = workout;
      closest = distance;
    }
  }
  return chosen;
}

/// Infinite for a type never trained, so it always sorts as the oldest.
double _daysSinceTrained(TrainingStats stats, TrainingType type, DateTime now) {
  final last = stats.lastTrainedByType[type];
  if (last == null) {
    return double.infinity;
  }
  return now.difference(last).inSeconds / Duration.secondsPerDay;
}

int _levelDistance(Difficulty of, Difficulty to) => (of.index - to.index).abs();
