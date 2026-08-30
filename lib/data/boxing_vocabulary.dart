/// Punches thrown with the lead hand, in cue notation.
const List<String> leadPunches = ['1', '3', '5'];

/// Punches thrown with the rear hand, in cue notation.
const List<String> rearPunches = ['2', '4', '6'];

/// Punches aimed at the body, in cue notation.
const List<String> bodyPunches = ['1b', '2b', '3b'];

const List<String> beginnerPunches = ['1', '2', '3', '2b'];
const List<String> beginnerDefense = ['slip', 'step back'];

const List<String> intermediatePunches = [
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '2b',
  '3b',
];
const List<String> intermediateDefense = [
  'slip',
  'roll',
  'pull',
  'pivot',
  'step back',
];

const List<String> advancedPunches = [...intermediatePunches, '1b'];
const List<String> advancedDefense = [
  ...intermediateDefense,
  'parry',
  'slip left',
  'slip right',
];

/// Footwork tokens: the steps and exits that break a punch chain.
const List<String> movementTokens = [
  'step in',
  'step back',
  'pivot',
  'circle left',
  'circle right',
  'cut left',
  'cut right',
  'pendulum',
  'exit',
];

const List<String> _leadHandPunches = [...leadPunches, '1b', '3b'];

final RegExp _punchPattern = RegExp(r'^[1-6]b?$');

/// True for punch notation: a digit 1 to 6 with an optional body suffix.
bool isPunch(String token) => _punchPattern.hasMatch(token);

/// True for punches thrown with the lead hand, whatever the stance.
bool isLeadHand(String token) => _leadHandPunches.contains(token);

/// True for footwork tokens rather than punches or defense.
bool isMovement(String token) => movementTokens.contains(token);

/// True for punches aimed at the body.
bool isBodyShot(String token) => isPunch(token) && token.endsWith('b');
