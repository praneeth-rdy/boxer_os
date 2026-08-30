import '../models/combination.dart';
import '../models/combo_tag.dart';
import '../models/difficulty.dart';

/// The bundled combination library: sixty named combinations to drill.
const List<Combination> combinationLibrary = [
  Combination(
    id: 'c01',
    moves: ['1'],
    difficulty: Difficulty.beginner,
    seed: 0,
    name: 'Jab',
    description:
        'Snap it out and back on the same line with the shoulder up to '
        'protect the chin.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c02',
    moves: ['1', '1'],
    difficulty: Difficulty.beginner,
    seed: 0,
    name: 'Double jab',
    description:
        'Push the second jab off the front foot so it lands harder than '
        'the first.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c03',
    moves: ['1', '2'],
    difficulty: Difficulty.beginner,
    seed: 0,
    name: 'One-two',
    description:
        'Turn the rear hip into the cross and land it the moment the jab '
        'returns.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c04',
    moves: ['1', '1', '2'],
    difficulty: Difficulty.beginner,
    seed: 0,
    name: 'Double jab, cross',
    description:
        'Use the double jab to close the gap, then sit down on the cross.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c05',
    moves: ['1', '2', '3'],
    difficulty: Difficulty.beginner,
    seed: 0,
    name: 'One-two-three',
    description:
        'Pivot the lead foot on the hook and keep the elbow level with '
        'the fist.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c06',
    moves: ['2', '3'],
    difficulty: Difficulty.beginner,
    seed: 0,
    name: 'Cross, hook',
    description:
        'Lead with the rear hand and let the recoil turn you into the '
        'hook.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c07',
    moves: ['1', '3'],
    difficulty: Difficulty.beginner,
    seed: 0,
    name: 'Jab, hook',
    description:
        'Same hand twice, so hide the hook behind the return of the jab.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c08',
    moves: ['1', '2', '1'],
    difficulty: Difficulty.beginner,
    seed: 0,
    name: 'One-two, jab out',
    description:
        'Finish on the jab to break the exchange and step out on the same '
        'beat.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c09',
    moves: ['1', '1b'],
    difficulty: Difficulty.beginner,
    seed: 0,
    name: 'High-low jab',
    description:
        'Show the jab upstairs, then bend the knees and dig the second '
        'one to the ribs.',
    tags: [ComboTag.body],
  ),
  Combination(
    id: 'c10',
    moves: ['1', '2b'],
    difficulty: Difficulty.beginner,
    seed: 0,
    name: 'Jab, cross downstairs',
    description:
        'Change levels with your legs, not your back, and keep the lead '
        'hand home.',
    tags: [ComboTag.body],
  ),
  Combination(
    id: 'c11',
    moves: ['1', 'step back'],
    difficulty: Difficulty.beginner,
    seed: 0,
    name: 'Jab and reset',
    description:
        'Touch and leave, so the counter lands where you were standing.',
    tags: [ComboTag.movement],
  ),
  Combination(
    id: 'c12',
    moves: ['1', 'slip', '2'],
    difficulty: Difficulty.beginner,
    seed: 0,
    name: 'Slip and return',
    description:
        'Return straight down the middle after the slip and keep the chin '
        'behind the shoulder.',
    tags: [ComboTag.counter, ComboTag.defense],
  ),
  Combination(
    id: 'c13',
    moves: ['1', '2', 'step back'],
    difficulty: Difficulty.beginner,
    seed: 0,
    name: 'One-two and out',
    description:
        'Land both, then take one clean step back before the answer '
        'comes.',
    tags: [ComboTag.movement],
  ),
  Combination(
    id: 'c14',
    moves: ['1', '2', 'slip'],
    difficulty: Difficulty.beginner,
    seed: 0,
    name: 'One-two, slip',
    description:
        'Expect the cross coming back and slip outside it as your rear '
        'hand returns.',
    tags: [ComboTag.defense],
  ),
  Combination(
    id: 'c15',
    moves: ['1', 'pivot'],
    difficulty: Difficulty.beginner,
    seed: 0,
    name: 'Jab and pivot',
    description:
        'Jab to freeze them, then pivot off the lead foot to change the '
        'angle.',
    tags: [ComboTag.movement],
  ),
  Combination(
    id: 'c16',
    moves: ['1', '2', '3', '2'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'One-two-three-two',
    description:
        'Keep the feet under you so the second cross lands as hard as the '
        'first.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c17',
    moves: ['1', '2', '5', '2'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Uppercut in the middle',
    description:
        'Drop the lead uppercut in between the straights without dipping '
        'the head.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c18',
    moves: ['1', '2', '3b', '3'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Body-head hook',
    description:
        'Dig the hook into the ribs, then bring the same hand straight '
        'back upstairs.',
    tags: [ComboTag.body],
  ),
  Combination(
    id: 'c19',
    moves: ['1', '2b', '3'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Downstairs, hook upstairs',
    description:
        'The body cross pulls the guard down and the hook follows where '
        'it left.',
    tags: [ComboTag.body],
  ),
  Combination(
    id: 'c20',
    moves: ['2b', '3'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Body cross, lead hook',
    description:
        'Start downstairs to open the head, then hook over the dropping '
        'elbow.',
    tags: [ComboTag.body],
  ),
  Combination(
    id: 'c21',
    moves: ['3b', '3'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Double hook, low high',
    description:
        'Same hand at two levels, so reset the pivot between the hooks.',
    tags: [ComboTag.body],
  ),
  Combination(
    id: 'c22',
    moves: ['1', '6', '3'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Jab, uppercut, hook',
    description:
        'The uppercut lifts the chin and the hook takes it as it comes '
        'back down.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c23',
    moves: ['1', '2', '3', '2b'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Finish downstairs',
    description:
        'Three upstairs to raise the guard, then bury the last one in the '
        'body.',
    tags: [ComboTag.body],
  ),
  Combination(
    id: 'c24',
    moves: ['1', '1', '2', '3'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Double jab, cross, hook',
    description:
        'Walk in behind the jabs and finish with your feet already set.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c25',
    moves: ['1', '3', '2'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Jab, hook, cross',
    description: 'Hook off the jab and let the shoulder turn feed the cross.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c26',
    moves: ['1', '2', 'slip', '2'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Slip and return',
    description:
        'Slip outside their cross and answer with your own before they '
        'reset.',
    tags: [ComboTag.counter, ComboTag.defense],
  ),
  Combination(
    id: 'c27',
    moves: ['1', '2', 'roll', '3', '2'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Roll under, hook cross',
    description: 'Roll under the hook and come up already loaded on your own.',
    tags: [ComboTag.counter, ComboTag.defense],
  ),
  Combination(
    id: 'c28',
    moves: ['1', '2', 'pull', '2'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Pull counter',
    description:
        'Pull the head straight back off the line, then fire the cross '
        'into the gap.',
    tags: [ComboTag.counter, ComboTag.defense],
  ),
  Combination(
    id: 'c29',
    moves: ['slip', '2', '3'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Slip inside, cross hook',
    description:
        'Slip inside first, then take the space they gave you with two.',
    tags: [ComboTag.counter],
  ),
  Combination(
    id: 'c30',
    moves: ['parry', '2'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Parry and cross',
    description:
        'Parry with a small hand rather than a big reach and answer on '
        'the same beat.',
    tags: [ComboTag.counter],
  ),
  Combination(
    id: 'c31',
    moves: ['1', '2', 'pivot', '1', '2'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Pivot and reset',
    description:
        'Pivot out after the cross and throw the same two from the new '
        'angle.',
    tags: [ComboTag.movement],
  ),
  Combination(
    id: 'c32',
    moves: ['1', '2', 'step back', '1', '2'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Draw and return',
    description: 'Step back to draw the counter, then step in on the same two.',
    tags: [ComboTag.movement],
  ),
  Combination(
    id: 'c33',
    moves: ['1', '2', '3', 'exit'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Hit and go',
    description:
        'Three punches and then leave, because nobody trades with you '
        'standing still.',
    tags: [ComboTag.movement],
  ),
  Combination(
    id: 'c34',
    moves: ['1', 'step in', '3b', '3'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Close and dig',
    description:
        'Use the jab to cover the step in, then work the ribs before the '
        'head.',
    tags: [ComboTag.body, ComboTag.movement],
  ),
  Combination(
    id: 'c35',
    moves: ['2', '3', '2'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Cross hook cross',
    description:
        'Start with the rear hand to break the rhythm and finish where '
        'you started.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c36',
    moves: ['1', '2', '1', '2'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Straight punches',
    description:
        'Straight punches on one line, with the feet keeping the range '
        'instead of the hands.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c37',
    moves: ['1', '2', 'circle left'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'One-two and circle',
    description: 'Land the two, then step off the line before they can answer.',
    tags: [ComboTag.movement],
  ),
  Combination(
    id: 'c38',
    moves: ['3', '2', '3'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Hook cross hook',
    description:
        'Pivot on both hooks so the cross has something to turn against.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c39',
    moves: ['5', '2'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Lead uppercut, cross',
    description:
        'Sneak the uppercut up the middle and follow it with the cross.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c40',
    moves: ['1', '2', '5', '3'],
    difficulty: Difficulty.intermediate,
    seed: 0,
    name: 'Uppercut, hook finish',
    description:
        'The uppercut straightens them up so the hook finds an open chin.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c41',
    moves: ['1', '2', '3', '2', '3'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Five-punch flurry',
    description:
        'Five punches without losing your stance, breathing out on every '
        'one.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c42',
    moves: ['1', '2b', '3', '2'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Downstairs upstairs',
    description:
        'Change levels once, then stay upstairs while the guard is still '
        'low.',
    tags: [ComboTag.body],
  ),
  Combination(
    id: 'c43',
    moves: ['1', '6', '3', '2'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Uppercut sandwich',
    description:
        'Lift with the uppercut, turn with the hook, finish with the '
        'cross.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c44',
    moves: ['1', '2', '3b', '3', '2'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Dig and finish',
    description:
        'Work the ribs in the middle, then bring the same hand back '
        'upstairs and close with the cross.',
    tags: [ComboTag.body],
  ),
  Combination(
    id: 'c45',
    moves: ['2', '3', '6', '3'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Inside four',
    description:
        'Short punches on the inside, elbows in, letting the hips do the '
        'turning.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c46',
    moves: ['1', '2', 'slip', '3b', '3'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Slip and dig',
    description:
        'Slip their cross and take the body first while the arm is still '
        'out.',
    tags: [ComboTag.counter, ComboTag.body],
  ),
  Combination(
    id: 'c47',
    moves: ['1', '2', 'roll', '3', '2', 'exit'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Roll off, fire, leave',
    description:
        'Roll, answer with two, and be gone before the third one comes '
        'back.',
    tags: [ComboTag.counter, ComboTag.movement],
  ),
  Combination(
    id: 'c48',
    moves: ['slip', '6', '3'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Slip, uppercut hook',
    description:
        'Slip inside and the uppercut is already in range, with the hook '
        'right behind it.',
    tags: [ComboTag.counter],
  ),
  Combination(
    id: 'c49',
    moves: ['slip right', '2b', '3'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Slip and bury',
    description:
        'Slip to your right and bury the cross in the ribs before hooking '
        'upstairs.',
    tags: [ComboTag.counter, ComboTag.body],
  ),
  Combination(
    id: 'c50',
    moves: ['1', '1', '2b', '3'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Double jab downstairs, hook',
    description:
        'Two jabs high pull the guard up so the cross can go under it.',
    tags: [ComboTag.body],
  ),
  Combination(
    id: 'c51',
    moves: ['1', '2', 'pull', '3', '2'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Pull, hook cross',
    description: 'Pull off their return, then step back in with the hook.',
    tags: [ComboTag.counter, ComboTag.defense],
  ),
  Combination(
    id: 'c52',
    moves: ['3b', '3', '2'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Body hook, hook, cross',
    description:
        'Start on the ribs and climb, so the cross lands as the guard '
        'chases the hook.',
    tags: [ComboTag.body],
  ),
  Combination(
    id: 'c53',
    moves: ['1', '2', '3', 'pivot', '2', '3'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Pivot punish',
    description:
        'Punch, pivot, and punch again from where they are no longer '
        'looking.',
    tags: [ComboTag.movement],
  ),
  Combination(
    id: 'c54',
    moves: ['parry', '2', '3', '2'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Parry and unload',
    description:
        'One parry buys three punches, so take all of them before you '
        'move.',
    tags: [ComboTag.counter],
  ),
  Combination(
    id: 'c55',
    moves: ['1', 'slip', '1', 'slip', '2'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Slip drill',
    description:
        'Jab and slip on every beat, then let the cross go once the '
        'rhythm is yours.',
    tags: [ComboTag.defense],
  ),
  Combination(
    id: 'c56',
    moves: ['2', '3b', '3', '2'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Cross, low high, cross',
    description:
        'Open with the rear hand, work the lead hand low then high, and '
        'close with the cross.',
    tags: [ComboTag.body],
  ),
  Combination(
    id: 'c57',
    moves: ['1', '2', '5', '2', '3'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Uppercut five',
    description:
        'Keep the uppercut short in the middle so the last two still '
        'carry your weight.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c58',
    moves: ['6', '3', '2'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Uppercut hook cross',
    description: 'Inside work: lift, turn, and finish before they tie you up.',
    tags: [ComboTag.offense],
  ),
  Combination(
    id: 'c59',
    moves: ['1', '2', 'step in', '5', '2'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Close with the uppercut',
    description:
        'Step in behind the two and the uppercut is the only punch that '
        'fits.',
    tags: [ComboTag.movement],
  ),
  Combination(
    id: 'c60',
    moves: ['1', '2', '3', '2', 'pivot', 'exit'],
    difficulty: Difficulty.advanced,
    seed: 0,
    name: 'Finish and vanish',
    description:
        'Four clean punches, pivot off the line, and leave the exchange '
        'first.',
    tags: [ComboTag.movement],
  ),
];

/// The library combination with this id, or null when nothing matches.
Combination? findCombination(String id) {
  for (final combination in combinationLibrary) {
    if (combination.id == id) return combination;
  }
  return null;
}

/// The library entries matching every filter given; all sixty when none is.
List<Combination> combinationsWhere({Difficulty? difficulty, ComboTag? tag}) =>
    combinationLibrary
        .where(
          (combination) =>
              (difficulty == null || combination.difficulty == difficulty) &&
              (tag == null || combination.tags.contains(tag)),
        )
        .toList(growable: false);
