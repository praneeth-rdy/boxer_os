import '../models/difficulty.dart';
import '../models/round_cue.dart';
import '../models/round_spec.dart';
import '../models/training_type.dart';
import '../models/workout.dart';

/// The bundled footwork catalogue, run from the Skills hub rather than the Train tab.
const List<Workout> footworkDrills = [
  Workout(
    id: 'fw_step_reset',
    name: 'Step and Reset',
    type: TrainingType.footwork,
    difficulty: Difficulty.beginner,
    description:
        'The first drill: cover ground in every direction and come back to '
        'your stance every time.',
    rounds: [
      RoundSpec(
        workSeconds: 90,
        restSeconds: 30,
        focus: 'In and out',
        cues: [
          RoundCue(atSecond: 4, text: 'step in'),
          RoundCue(atSecond: 20, text: 'step out'),
          RoundCue(atSecond: 38, text: 'reset'),
          RoundCue(atSecond: 56, text: 'step in, step out'),
          RoundCue(atSecond: 74, text: 'reset'),
        ],
      ),
      RoundSpec(
        workSeconds: 90,
        restSeconds: 30,
        focus: 'Add the step back',
        cues: [
          RoundCue(atSecond: 4, text: 'step back'),
          RoundCue(atSecond: 20, text: 'step in'),
          RoundCue(atSecond: 38, text: 'step back, reset'),
          RoundCue(atSecond: 56, text: 'step in, step out'),
          RoundCue(atSecond: 74, text: 'reset'),
        ],
      ),
      RoundSpec(
        workSeconds: 90,
        restSeconds: 30,
        focus: 'All four directions',
        cues: [
          RoundCue(atSecond: 4, text: 'step in, reset'),
          RoundCue(atSecond: 20, text: 'step back, reset'),
          RoundCue(atSecond: 38, text: 'step left, reset'),
          RoundCue(atSecond: 56, text: 'step right, reset'),
          RoundCue(atSecond: 74, text: 'hold'),
        ],
      ),
    ],
  ),
  Workout(
    id: 'fw_pivot_circuit',
    name: 'Pivot Circuit',
    type: TrainingType.footwork,
    difficulty: Difficulty.beginner,
    description:
        'Turn on the lead foot and keep circling. Three rounds of pivots both '
        'ways, holding the new angle each time.',
    rounds: [
      RoundSpec(
        workSeconds: 90,
        restSeconds: 30,
        focus: 'Pivot left',
        cues: [
          RoundCue(atSecond: 4, text: 'pivot left'),
          RoundCue(atSecond: 20, text: 'pivot left, reset'),
          RoundCue(atSecond: 38, text: 'circle left'),
          RoundCue(atSecond: 56, text: 'pivot left, hold'),
          RoundCue(atSecond: 74, text: 'reset'),
        ],
      ),
      RoundSpec(
        workSeconds: 90,
        restSeconds: 30,
        focus: 'Pivot right',
        cues: [
          RoundCue(atSecond: 4, text: 'pivot right'),
          RoundCue(atSecond: 20, text: 'pivot right, reset'),
          RoundCue(atSecond: 38, text: 'circle right'),
          RoundCue(atSecond: 56, text: 'pivot right, hold'),
          RoundCue(atSecond: 74, text: 'reset'),
        ],
      ),
      RoundSpec(
        workSeconds: 90,
        restSeconds: 30,
        focus: 'Circle and pivot',
        cues: [
          RoundCue(atSecond: 4, text: 'circle left'),
          RoundCue(atSecond: 20, text: 'pivot'),
          RoundCue(atSecond: 38, text: 'circle right'),
          RoundCue(atSecond: 56, text: 'pivot, hold'),
          RoundCue(atSecond: 74, text: 'reset'),
        ],
      ),
    ],
  ),
  Workout(
    id: 'fw_angles',
    name: 'Angles Off the Jab',
    type: TrainingType.footwork,
    difficulty: Difficulty.intermediate,
    description:
        'Every jab buys a new angle. Four rounds of stepping and pivoting off '
        'the lead hand, finishing with the L-step.',
    rounds: [
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Jab and pivot',
        cues: [
          RoundCue(atSecond: 4, text: '1'),
          RoundCue(atSecond: 30, text: '1, pivot'),
          RoundCue(atSecond: 55, text: '1, pivot left'),
          RoundCue(atSecond: 80, text: '1, pivot right'),
          RoundCue(atSecond: 105, text: 'reset'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Step off the jab',
        cues: [
          RoundCue(atSecond: 4, text: '1, step left'),
          RoundCue(atSecond: 30, text: '1, step right'),
          RoundCue(atSecond: 55, text: '1-1, step left'),
          RoundCue(atSecond: 80, text: '1, step back'),
          RoundCue(atSecond: 105, text: 'reset'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'The L-step',
        cues: [
          RoundCue(atSecond: 4, text: 'L-step'),
          RoundCue(atSecond: 30, text: '1, L-step'),
          RoundCue(atSecond: 55, text: '1-2, L-step'),
          RoundCue(atSecond: 80, text: 'L-step, pivot'),
          RoundCue(atSecond: 105, text: 'hold'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Put it together',
        cues: [
          RoundCue(atSecond: 4, text: '1, pivot'),
          RoundCue(atSecond: 30, text: '1-2, L-step'),
          RoundCue(atSecond: 55, text: '1, step left, 2'),
          RoundCue(atSecond: 80, text: '1-2, pivot, exit'),
          RoundCue(atSecond: 105, text: 'reset'),
        ],
      ),
    ],
  ),
  Workout(
    id: 'fw_box_step',
    name: 'Box Step Shuffle',
    type: TrainingType.footwork,
    difficulty: Difficulty.intermediate,
    description:
        'Four corners on the balls of your feet. Stay light, keep the bounce '
        'and switch stance without crossing your feet.',
    rounds: [
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Box the corners',
        cues: [
          RoundCue(atSecond: 4, text: 'bounce'),
          RoundCue(atSecond: 28, text: 'step in'),
          RoundCue(atSecond: 52, text: 'step left'),
          RoundCue(atSecond: 76, text: 'step back'),
          RoundCue(atSecond: 100, text: 'step right'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Corners on the bounce',
        cues: [
          RoundCue(atSecond: 4, text: 'bounce'),
          RoundCue(atSecond: 30, text: 'step in, step out'),
          RoundCue(atSecond: 55, text: 'step left, step right'),
          RoundCue(atSecond: 80, text: 'bounce, reset'),
          RoundCue(atSecond: 105, text: 'hold'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Switch the lead',
        cues: [
          RoundCue(atSecond: 4, text: 'switch'),
          RoundCue(atSecond: 30, text: 'switch, reset'),
          RoundCue(atSecond: 55, text: 'step in, switch'),
          RoundCue(atSecond: 80, text: 'switch, step back'),
          RoundCue(atSecond: 105, text: 'bounce'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Box and switch',
        cues: [
          RoundCue(atSecond: 4, text: 'bounce'),
          RoundCue(atSecond: 30, text: 'step left, switch'),
          RoundCue(atSecond: 55, text: 'step right, switch'),
          RoundCue(atSecond: 80, text: 'step in, step back'),
          RoundCue(atSecond: 105, text: 'reset'),
        ],
      ),
    ],
  ),
  Workout(
    id: 'fw_cut_the_ring',
    name: 'Cut the Ring',
    type: TrainingType.footwork,
    difficulty: Difficulty.advanced,
    description:
        'Pressure footwork: close the distance, cut off the escape route, then '
        'get out clean. Five hard rounds with punches on the way in.',
    rounds: [
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Close the distance',
        cues: [
          RoundCue(atSecond: 4, text: 'step in'),
          RoundCue(atSecond: 30, text: 'step in, hold'),
          RoundCue(atSecond: 55, text: 'step in, step in'),
          RoundCue(atSecond: 80, text: 'circle left, step in'),
          RoundCue(atSecond: 105, text: 'reset'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Cut left',
        cues: [
          RoundCue(atSecond: 4, text: 'circle left'),
          RoundCue(atSecond: 30, text: 'step in, circle left'),
          RoundCue(atSecond: 55, text: 'circle left, pivot'),
          RoundCue(atSecond: 80, text: '1, step in'),
          RoundCue(atSecond: 105, text: 'exit'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Cut right',
        cues: [
          RoundCue(atSecond: 4, text: 'circle right'),
          RoundCue(atSecond: 30, text: 'step in, circle right'),
          RoundCue(atSecond: 55, text: 'circle right, pivot'),
          RoundCue(atSecond: 80, text: '1-2, step in'),
          RoundCue(atSecond: 105, text: 'exit'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Trap and exit',
        cues: [
          RoundCue(atSecond: 4, text: 'step in'),
          RoundCue(atSecond: 30, text: '1-2, step in'),
          RoundCue(atSecond: 55, text: 'pivot, exit'),
          RoundCue(atSecond: 80, text: 'circle left, 1-2'),
          RoundCue(atSecond: 105, text: 'exit'),
        ],
      ),
      RoundSpec(
        workSeconds: 120,
        restSeconds: 45,
        focus: 'Full pressure',
        cues: [
          RoundCue(atSecond: 4, text: 'step in, 1-2'),
          RoundCue(atSecond: 30, text: 'circle left, 1-2'),
          RoundCue(atSecond: 55, text: '1-2, step in'),
          RoundCue(atSecond: 80, text: 'pivot, exit'),
          RoundCue(atSecond: 105, text: 'reset'),
        ],
      ),
    ],
  ),
];

/// The footwork drill with this id, or null when nothing matches.
Workout? findFootworkDrill(String id) {
  for (final drill in footworkDrills) {
    if (drill.id == id) return drill;
  }
  return null;
}
