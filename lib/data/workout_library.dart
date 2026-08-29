import '../models/difficulty.dart';
import '../models/round_cue.dart';
import '../models/round_spec.dart';
import '../models/training_type.dart';
import '../models/workout.dart';

/// The bundled starter library: twelve workouts covering every training type.
const List<Workout> workoutLibrary = [
  Workout(
    id: 'shadow_foundations',
    name: 'Shadow Foundations',
    type: TrainingType.shadowBoxing,
    difficulty: Difficulty.beginner,
    description:
        'Three rounds on the basics: a clean jab, the straight right behind it '
        'and your first slip. Start here if boxing is new.',
    rounds: [
      RoundSpec(
        workSeconds: 120,
        restSeconds: 60,
        focus: 'Jab only',
        cues: [
          RoundCue(atSecond: 4, text: '1'),
          RoundCue(atSecond: 30, text: '1-1'),
          RoundCue(atSecond: 55, text: '1, step in'),
          RoundCue(atSecond: 80, text: '1, circle left'),
          RoundCue(atSecond: 105, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 60,
        focus: '1-2',
        cues: [
          RoundCue(atSecond: 4, text: '1-2'),
          RoundCue(atSecond: 30, text: '1-2, step back'),
          RoundCue(atSecond: 55, text: '1-1-2'),
          RoundCue(atSecond: 80, text: '1-2, circle right'),
          RoundCue(atSecond: 105, text: 'power'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 60,
        focus: 'Add the slip',
        cues: [
          RoundCue(atSecond: 4, text: '1-2'),
          RoundCue(atSecond: 30, text: '1-2, slip'),
          RoundCue(atSecond: 55, text: 'slip, 2'),
          RoundCue(atSecond: 80, text: '1-2, slip, exit'),
          RoundCue(atSecond: 105, text: 'breathe'),
        ],
      ),
    ],
  ),
  Workout(
    id: 'shadow_flow',
    name: 'Shadow Flow',
    type: TrainingType.shadowBoxing,
    difficulty: Difficulty.intermediate,
    description:
        'Five rounds linking combinations to movement, so every string of '
        'punches starts and ends on the move.',
    rounds: [
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Long range',
        cues: [
          RoundCue(atSecond: 4, text: '1-2'),
          RoundCue(atSecond: 35, text: '1, step in, 2'),
          RoundCue(atSecond: 65, text: '1-2, step back'),
          RoundCue(atSecond: 95, text: '1-1-2'),
          RoundCue(atSecond: 125, text: '1-2, pivot'),
          RoundCue(atSecond: 155, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Doubles and triples',
        cues: [
          RoundCue(atSecond: 4, text: '1-1'),
          RoundCue(atSecond: 35, text: '1-1-2'),
          RoundCue(atSecond: 65, text: '1-2-3'),
          RoundCue(atSecond: 95, text: '1-2-3-2'),
          RoundCue(atSecond: 125, text: '3-2, circle left'),
          RoundCue(atSecond: 155, text: 'speed'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Angles',
        cues: [
          RoundCue(atSecond: 4, text: '1-2, pivot'),
          RoundCue(atSecond: 35, text: 'pivot, 3'),
          RoundCue(atSecond: 65, text: '1-2, circle right'),
          RoundCue(atSecond: 95, text: 'slip, pivot, 2'),
          RoundCue(atSecond: 125, text: '1-2, exit'),
          RoundCue(atSecond: 155, text: 'light'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Body and head',
        cues: [
          RoundCue(atSecond: 4, text: '1-2b'),
          RoundCue(atSecond: 35, text: '2b-3'),
          RoundCue(atSecond: 65, text: '1-2b-2'),
          RoundCue(atSecond: 95, text: '3b-3'),
          RoundCue(atSecond: 125, text: '1-2, 3b'),
          RoundCue(atSecond: 155, text: 'power'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Free flow',
        cues: [
          RoundCue(atSecond: 4, text: '1-2, slip, pivot'),
          RoundCue(atSecond: 35, text: 'roll, 3-2'),
          RoundCue(atSecond: 65, text: '1-2-3, exit'),
          RoundCue(atSecond: 95, text: 'pull, 2'),
          RoundCue(atSecond: 125, text: '1-2, slip, pivot, exit'),
          RoundCue(atSecond: 155, text: 'breathe'),
        ],
      ),
    ],
  ),
  Workout(
    id: 'championship_rounds',
    name: 'Championship Rounds',
    type: TrainingType.shadowBoxing,
    difficulty: Difficulty.advanced,
    description:
        'Twelve rounds, fight simulation. Cues are sparse on purpose: pace, '
        'pressure and exits only, the rest of the round is yours.',
    rounds: [
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Feel it out',
        cues: [
          RoundCue(atSecond: 5, text: 'light'),
          RoundCue(atSecond: 70, text: '1, circle left'),
          RoundCue(atSecond: 140, text: '1-2, exit'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Find the jab',
        cues: [
          RoundCue(atSecond: 5, text: '1-1'),
          RoundCue(atSecond: 70, text: '1-2, step back'),
          RoundCue(atSecond: 140, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Behind the jab',
        cues: [
          RoundCue(atSecond: 5, text: '1-2'),
          RoundCue(atSecond: 70, text: '1-1-2'),
          RoundCue(atSecond: 140, text: '1-2, pivot'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Take the center',
        cues: [
          RoundCue(atSecond: 5, text: 'step in, 1-2'),
          RoundCue(atSecond: 70, text: '1-2-3'),
          RoundCue(atSecond: 140, text: 'power'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Body attack',
        cues: [
          RoundCue(atSecond: 5, text: '1-2b'),
          RoundCue(atSecond: 70, text: '2b-3'),
          RoundCue(atSecond: 140, text: '1-2b-2'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Half way',
        cues: [
          RoundCue(atSecond: 5, text: 'breathe'),
          RoundCue(atSecond: 70, text: '1-2, slip, 2'),
          RoundCue(atSecond: 140, text: 'speed'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Counter round',
        cues: [
          RoundCue(atSecond: 5, text: 'slip, 2'),
          RoundCue(atSecond: 70, text: 'pull, 1-2'),
          RoundCue(atSecond: 140, text: 'parry, 2'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Steal the round',
        cues: [
          RoundCue(atSecond: 5, text: '1-2-3-2'),
          RoundCue(atSecond: 70, text: 'sharp'),
          RoundCue(atSecond: 140, text: '1-2, circle right'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Deep water',
        cues: [
          RoundCue(atSecond: 5, text: 'breathe'),
          RoundCue(atSecond: 70, text: '1-2, exit'),
          RoundCue(atSecond: 140, text: '1-1-2'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Empty the tank',
        cues: [
          RoundCue(atSecond: 5, text: 'power'),
          RoundCue(atSecond: 70, text: '1-2-3-2'),
          RoundCue(atSecond: 140, text: 'speed'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Hold the lead',
        cues: [
          RoundCue(atSecond: 5, text: '1, circle left'),
          RoundCue(atSecond: 70, text: '1-2, step back'),
          RoundCue(atSecond: 140, text: 'light'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Last round',
        cues: [
          RoundCue(atSecond: 5, text: '1-2'),
          RoundCue(atSecond: 70, text: 'power'),
          RoundCue(atSecond: 140, text: '1-2-3, exit'),
        ],
      ),
    ],
  ),
  Workout(
    id: 'bag_basics',
    name: 'Bag Basics',
    type: TrainingType.heavyBag,
    difficulty: Difficulty.beginner,
    description:
        'Four rounds on the heavy bag: single punches first, then the 1-2, '
        'stepping off the bag after every string.',
    rounds: [
      RoundSpec(
        workSeconds: 120,
        restSeconds: 60,
        focus: 'Single jab',
        cues: [
          RoundCue(atSecond: 4, text: '1'),
          RoundCue(atSecond: 30, text: '1, step back'),
          RoundCue(atSecond: 55, text: '1-1'),
          RoundCue(atSecond: 80, text: '1, circle left'),
          RoundCue(atSecond: 105, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 60,
        focus: 'Jab and cross',
        cues: [
          RoundCue(atSecond: 4, text: '2'),
          RoundCue(atSecond: 30, text: '1-2'),
          RoundCue(atSecond: 55, text: '1-2, step back'),
          RoundCue(atSecond: 80, text: '1-2, pivot'),
          RoundCue(atSecond: 105, text: 'power'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 60,
        focus: 'Add the hook',
        cues: [
          RoundCue(atSecond: 4, text: '3'),
          RoundCue(atSecond: 30, text: '1-2-3'),
          RoundCue(atSecond: 55, text: '3-2'),
          RoundCue(atSecond: 80, text: '1-2-3, step back'),
          RoundCue(atSecond: 105, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 60,
        focus: 'Put it together',
        cues: [
          RoundCue(atSecond: 4, text: '1-2'),
          RoundCue(atSecond: 30, text: '1-2-3-2'),
          RoundCue(atSecond: 55, text: '1-2, pivot'),
          RoundCue(atSecond: 80, text: '1-1-2, exit'),
          RoundCue(atSecond: 105, text: 'power'),
        ],
      ),
    ],
  ),
  Workout(
    id: 'power_rounds',
    name: 'Power Rounds',
    type: TrainingType.heavyBag,
    difficulty: Difficulty.advanced,
    description:
        'Six heavy rounds of body-to-head combinations. Everything is thrown '
        'sharp, with real power on the last punch of each string.',
    rounds: [
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Body to head',
        cues: [
          RoundCue(atSecond: 4, text: '1-2b'),
          RoundCue(atSecond: 35, text: '2b-3'),
          RoundCue(atSecond: 65, text: '1-2b-2'),
          RoundCue(atSecond: 95, text: '3b-3'),
          RoundCue(atSecond: 125, text: '1-2, 3b'),
          RoundCue(atSecond: 155, text: 'power'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Double up',
        cues: [
          RoundCue(atSecond: 4, text: '1-1-2'),
          RoundCue(atSecond: 35, text: '2-2'),
          RoundCue(atSecond: 65, text: '3-3'),
          RoundCue(atSecond: 95, text: '1-2-2'),
          RoundCue(atSecond: 125, text: '1-1-2-3'),
          RoundCue(atSecond: 155, text: 'power'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Hook off the jab',
        cues: [
          RoundCue(atSecond: 4, text: '1-3'),
          RoundCue(atSecond: 35, text: '1-2-3'),
          RoundCue(atSecond: 65, text: '1-3-2'),
          RoundCue(atSecond: 95, text: '1-2-3-2'),
          RoundCue(atSecond: 125, text: '3-2-3'),
          RoundCue(atSecond: 155, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Uppercuts inside',
        cues: [
          RoundCue(atSecond: 4, text: '5-2'),
          RoundCue(atSecond: 35, text: '6-3'),
          RoundCue(atSecond: 65, text: '1-2-5'),
          RoundCue(atSecond: 95, text: '5-6-3'),
          RoundCue(atSecond: 125, text: '2b-5-2'),
          RoundCue(atSecond: 155, text: 'power'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Long strings',
        cues: [
          RoundCue(atSecond: 4, text: '1-2-3-2'),
          RoundCue(atSecond: 35, text: '1-2-5-2-3'),
          RoundCue(atSecond: 65, text: '1-2b-3-2'),
          RoundCue(atSecond: 95, text: '1-1-2-3-2'),
          RoundCue(atSecond: 125, text: '2-3-2, exit'),
          RoundCue(atSecond: 155, text: 'speed'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Finish strong',
        cues: [
          RoundCue(atSecond: 4, text: '1-2'),
          RoundCue(atSecond: 35, text: '1-2-3-2'),
          RoundCue(atSecond: 65, text: 'power'),
          RoundCue(atSecond: 95, text: '1-2b-2'),
          RoundCue(atSecond: 125, text: '1-2-3, exit'),
          RoundCue(atSecond: 155, text: 'breathe'),
        ],
      ),
    ],
  ),
  Workout(
    id: 'speed_bag_rhythm',
    name: 'Speed Bag Rhythm',
    type: TrainingType.speedBag,
    difficulty: Difficulty.intermediate,
    description:
        'Four rounds building speed bag timing: one hand, then alternating, '
        'then doubles at full speed.',
    rounds: [
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'One hand',
        cues: [
          RoundCue(atSecond: 4, text: 'lead hand only'),
          RoundCue(atSecond: 30, text: 'reset'),
          RoundCue(atSecond: 55, text: 'rear hand only'),
          RoundCue(atSecond: 80, text: 'speed'),
          RoundCue(atSecond: 105, text: 'reset'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Alternate hands',
        cues: [
          RoundCue(atSecond: 4, text: 'alternate hands'),
          RoundCue(atSecond: 30, text: 'speed'),
          RoundCue(atSecond: 55, text: 'reset'),
          RoundCue(atSecond: 80, text: 'alternate hands'),
          RoundCue(atSecond: 105, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Doubles',
        cues: [
          RoundCue(atSecond: 4, text: 'double lead'),
          RoundCue(atSecond: 30, text: 'double rear'),
          RoundCue(atSecond: 55, text: 'speed'),
          RoundCue(atSecond: 80, text: 'reset'),
          RoundCue(atSecond: 105, text: 'double both hands'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Full speed',
        cues: [
          RoundCue(atSecond: 4, text: 'alternate hands'),
          RoundCue(atSecond: 30, text: 'speed'),
          RoundCue(atSecond: 55, text: 'reset'),
          RoundCue(atSecond: 80, text: 'speed'),
          RoundCue(atSecond: 105, text: 'breathe'),
        ],
      ),
    ],
  ),
  Workout(
    id: 'mitt_partner',
    name: 'Mitt Work Partner',
    type: TrainingType.mittWork,
    difficulty: Difficulty.intermediate,
    description:
        'Five rounds of called combinations for a partner on the pads. The app '
        'calls the string, the holder feeds it.',
    rounds: [
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Straights',
        cues: [
          RoundCue(atSecond: 4, text: '1-2'),
          RoundCue(atSecond: 35, text: '1-1-2'),
          RoundCue(atSecond: 65, text: '1-2, step back'),
          RoundCue(atSecond: 95, text: '2-1-2'),
          RoundCue(atSecond: 125, text: '1-2, pivot'),
          RoundCue(atSecond: 155, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Add the hook',
        cues: [
          RoundCue(atSecond: 4, text: '1-2-3'),
          RoundCue(atSecond: 35, text: '3-2'),
          RoundCue(atSecond: 65, text: '1-2-3-2'),
          RoundCue(atSecond: 95, text: '1-3-2'),
          RoundCue(atSecond: 125, text: '3-2, exit'),
          RoundCue(atSecond: 155, text: 'power'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Body work',
        cues: [
          RoundCue(atSecond: 4, text: '1-2b'),
          RoundCue(atSecond: 35, text: '2b-3'),
          RoundCue(atSecond: 65, text: '1-2b-2'),
          RoundCue(atSecond: 95, text: '3b-2'),
          RoundCue(atSecond: 125, text: '1-2, 3b-3'),
          RoundCue(atSecond: 155, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Defense between',
        cues: [
          RoundCue(atSecond: 4, text: '1-2, slip, 2'),
          RoundCue(atSecond: 35, text: 'parry, 2'),
          RoundCue(atSecond: 65, text: 'roll, 3-2'),
          RoundCue(atSecond: 95, text: 'pull, 1-2'),
          RoundCue(atSecond: 125, text: 'block, 2-3'),
          RoundCue(atSecond: 155, text: 'light'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Long combinations',
        cues: [
          RoundCue(atSecond: 4, text: '1-2-3-2'),
          RoundCue(atSecond: 35, text: '1-2-5-2'),
          RoundCue(atSecond: 65, text: '1-2b-3-2'),
          RoundCue(atSecond: 95, text: '1-1-2-3'),
          RoundCue(atSecond: 125, text: '1-2, slip, pivot, exit'),
          RoundCue(atSecond: 155, text: 'breathe'),
        ],
      ),
    ],
  ),
  Workout(
    id: 'sparring_six',
    name: 'Sparring Six',
    type: TrainingType.sparring,
    difficulty: Difficulty.advanced,
    description:
        'Six sparring rounds. No combinations are called: three reminders a '
        'round so you keep breathing, keep moving and get out clean.',
    rounds: [
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Feel the range',
        cues: [
          RoundCue(atSecond: 5, text: 'breathe'),
          RoundCue(atSecond: 70, text: 'circle left'),
          RoundCue(atSecond: 140, text: 'exit'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Work the jab',
        cues: [
          RoundCue(atSecond: 5, text: '1, circle right'),
          RoundCue(atSecond: 70, text: 'breathe'),
          RoundCue(atSecond: 140, text: 'exit'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Head off the line',
        cues: [
          RoundCue(atSecond: 5, text: 'slip, exit'),
          RoundCue(atSecond: 70, text: 'breathe'),
          RoundCue(atSecond: 140, text: 'circle left'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Body attack',
        cues: [
          RoundCue(atSecond: 5, text: '1-2b'),
          RoundCue(atSecond: 70, text: 'breathe'),
          RoundCue(atSecond: 140, text: 'exit'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Counter and move',
        cues: [
          RoundCue(atSecond: 5, text: 'slip, 2, exit'),
          RoundCue(atSecond: 70, text: 'circle right'),
          RoundCue(atSecond: 140, text: 'breathe'),
        ],
      ),
      RoundSpec(
        workSeconds: 180,
        restSeconds: 60,
        focus: 'Finish clean',
        cues: [
          RoundCue(atSecond: 5, text: '1-2, exit'),
          RoundCue(atSecond: 70, text: 'breathe'),
          RoundCue(atSecond: 140, text: 'circle left'),
        ],
      ),
    ],
  ),
  Workout(
    id: 'footwork_ladder',
    name: 'Footwork Ladder',
    type: TrainingType.footwork,
    difficulty: Difficulty.beginner,
    description:
        'Four rounds of pure movement: in and out, circling, pivots. Punches '
        'only arrive in the last round, once the feet know where to go.',
    rounds: [
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'In and out',
        cues: [
          RoundCue(atSecond: 4, text: 'step in'),
          RoundCue(atSecond: 30, text: 'step back'),
          RoundCue(atSecond: 55, text: 'step in, step back'),
          RoundCue(atSecond: 80, text: 'reset'),
          RoundCue(atSecond: 105, text: 'light'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Circling',
        cues: [
          RoundCue(atSecond: 4, text: 'circle left'),
          RoundCue(atSecond: 30, text: 'circle right'),
          RoundCue(atSecond: 55, text: 'circle left'),
          RoundCue(atSecond: 80, text: 'reset'),
          RoundCue(atSecond: 105, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Pivots',
        cues: [
          RoundCue(atSecond: 4, text: 'pivot'),
          RoundCue(atSecond: 30, text: 'pivot, reset'),
          RoundCue(atSecond: 55, text: 'circle left, pivot'),
          RoundCue(atSecond: 80, text: 'pivot, exit'),
          RoundCue(atSecond: 105, text: 'light'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Move and punch',
        cues: [
          RoundCue(atSecond: 4, text: 'step in, 1'),
          RoundCue(atSecond: 30, text: '1, step back'),
          RoundCue(atSecond: 55, text: '1-2, pivot'),
          RoundCue(atSecond: 80, text: 'circle left, 1-2'),
          RoundCue(atSecond: 105, text: '1-2, slip, pivot, exit'),
        ],
      ),
    ],
  ),
  Workout(
    id: 'fight_conditioning',
    name: 'Fight Conditioning',
    type: TrainingType.conditioning,
    difficulty: Difficulty.intermediate,
    description:
        'Six one-minute efforts with thirty seconds between them. One exercise '
        'per round, all out from the bell.',
    rounds: [
      RoundSpec(
        workSeconds: 60,
        restSeconds: 30,
        focus: 'Burpees',
        cues: [
          RoundCue(atSecond: 5, text: 'burpees'),
          RoundCue(atSecond: 45, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 60,
        restSeconds: 30,
        focus: 'Squat jumps',
        cues: [
          RoundCue(atSecond: 5, text: 'squat jumps'),
          RoundCue(atSecond: 45, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 60,
        restSeconds: 30,
        focus: 'Mountain climbers',
        cues: [
          RoundCue(atSecond: 5, text: 'mountain climbers'),
          RoundCue(atSecond: 45, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 60,
        restSeconds: 30,
        focus: 'Shadow sprint',
        cues: [
          RoundCue(atSecond: 5, text: 'shadow sprint'),
          RoundCue(atSecond: 45, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 60,
        restSeconds: 30,
        focus: 'Push-ups',
        cues: [
          RoundCue(atSecond: 5, text: 'push-ups'),
          RoundCue(atSecond: 45, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 60,
        restSeconds: 30,
        focus: 'Plank',
        cues: [
          RoundCue(atSecond: 5, text: 'plank'),
          RoundCue(atSecond: 45, text: 'sharp'),
        ],
      ),
    ],
  ),
  Workout(
    id: 'fighter_strength',
    name: 'Fighter Strength',
    type: TrainingType.strength,
    difficulty: Difficulty.intermediate,
    description:
        'A five station circuit on the round timer: push, pull, legs, power '
        'and core, two minutes each.',
    rounds: [
      RoundSpec(
        workSeconds: 120,
        restSeconds: 60,
        focus: 'Push-ups',
        cues: [
          RoundCue(atSecond: 5, text: 'push-ups'),
          RoundCue(atSecond: 60, text: 'sharp'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 60,
        focus: 'Rows or pull-ups',
        cues: [
          RoundCue(atSecond: 5, text: 'rows or pull-ups'),
          RoundCue(atSecond: 60, text: 'power'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 60,
        focus: 'Split squats',
        cues: [
          RoundCue(atSecond: 5, text: 'split squats'),
          RoundCue(atSecond: 60, text: 'light'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 60,
        focus: 'Med-ball slams',
        cues: [
          RoundCue(atSecond: 5, text: 'med-ball slams'),
          RoundCue(atSecond: 60, text: 'power'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 60,
        focus: 'Core',
        cues: [
          RoundCue(atSecond: 5, text: 'core'),
          RoundCue(atSecond: 60, text: 'breathe'),
        ],
      ),
    ],
  ),
  Workout(
    id: 'footwork_combo_20',
    name: 'Footwork + Combination',
    type: TrainingType.footwork,
    difficulty: Difficulty.intermediate,
    description:
        'About twenty minutes alternating movement rounds with combination '
        'rounds, each combination round closing on 1-2, slip, pivot, exit.',
    rounds: [
      RoundSpec(
        workSeconds: 150,
        restSeconds: 45,
        focus: 'Range and angles',
        cues: [
          RoundCue(atSecond: 4, text: 'step in, step back'),
          RoundCue(atSecond: 35, text: 'circle left'),
          RoundCue(atSecond: 65, text: 'pivot'),
          RoundCue(atSecond: 95, text: 'circle right, pivot'),
          RoundCue(atSecond: 125, text: 'reset'),
        ],
      ),
      RoundSpec(
        workSeconds: 150,
        restSeconds: 45,
        focus: 'Straights',
        cues: [
          RoundCue(atSecond: 4, text: '1-2'),
          RoundCue(atSecond: 35, text: '1-1-2'),
          RoundCue(atSecond: 65, text: '1-2, step back'),
          RoundCue(atSecond: 95, text: '1-2-3-2'),
          RoundCue(atSecond: 125, text: '1-2, slip, pivot, exit'),
        ],
      ),
      RoundSpec(
        workSeconds: 150,
        restSeconds: 45,
        focus: 'Cut the ring',
        cues: [
          RoundCue(atSecond: 4, text: 'circle left'),
          RoundCue(atSecond: 35, text: 'pivot, exit'),
          RoundCue(atSecond: 65, text: 'step in, pivot'),
          RoundCue(atSecond: 95, text: 'circle right'),
          RoundCue(atSecond: 125, text: 'reset'),
        ],
      ),
      RoundSpec(
        workSeconds: 150,
        restSeconds: 45,
        focus: 'Hooks and body',
        cues: [
          RoundCue(atSecond: 4, text: '1-2-3'),
          RoundCue(atSecond: 35, text: '1-2b-2'),
          RoundCue(atSecond: 65, text: '3b-3'),
          RoundCue(atSecond: 95, text: '1-2-3-2'),
          RoundCue(atSecond: 125, text: '1-2, slip, pivot, exit'),
        ],
      ),
      RoundSpec(
        workSeconds: 150,
        restSeconds: 45,
        focus: 'Defensive movement',
        cues: [
          RoundCue(atSecond: 4, text: 'slip, step back'),
          RoundCue(atSecond: 35, text: 'roll, pivot'),
          RoundCue(atSecond: 65, text: 'pull, reset'),
          RoundCue(atSecond: 95, text: 'slip left'),
          RoundCue(atSecond: 125, text: 'slip right'),
        ],
      ),
      RoundSpec(
        workSeconds: 150,
        restSeconds: 45,
        focus: 'Put it together',
        cues: [
          RoundCue(atSecond: 4, text: '1-2, pivot'),
          RoundCue(atSecond: 35, text: '1-2-3, exit'),
          RoundCue(atSecond: 65, text: 'slip, 2, pivot'),
          RoundCue(atSecond: 95, text: '1-1-2, circle left'),
          RoundCue(atSecond: 125, text: '1-2, slip, pivot, exit'),
        ],
      ),
    ],
  ),
];

/// The library entry with this id, or null when nothing matches.
Workout? findWorkout(String id) {
  for (final workout in workoutLibrary) {
    if (workout.id == id) return workout;
  }
  return null;
}

List<Workout> workoutsOfType(TrainingType type) => workoutLibrary
    .where((workout) => workout.type == type)
    .toList(growable: false);
