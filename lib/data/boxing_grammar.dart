import 'boxing_vocabulary.dart';

/// What may follow each punch inside a chain, head or body.
const Map<String, List<String>> allowedNext = {
  '1': ['1', '2', '3', '1b', '2b', '3b', '6'],
  '2': ['3', '5', '3b', '1', '2b'],
  '3': ['2', '4', '6', '2b'],
  '4': ['3', '5', '2'],
  '5': ['2', '4', '3'],
  '6': ['3', '5', '2'],
  '1b': ['2', '3', '1'],
  '2b': ['3', '5', '2'],
  '3b': ['3', '2', '6'],
};

/// The punches a defense opens up, thrown as the counter comes back.
const Map<String, List<String>> punchesAfterDefense = {
  'slip': ['1', '2', '3b', '6', '3'],
  'slip left': ['3', '3b'],
  'slip right': ['2', '2b', '6'],
  'roll': ['3', '3b', '2'],
  'pull': ['1', '2', '3'],
  'parry': ['2', '3'],
};

/// Openers weighted by how often a combination really starts there.
const List<String> openers = [
  '1',
  '1',
  '1',
  '1',
  '1',
  '1',
  '2',
  '3',
  '1b',
  '2b',
];

/// Movement that takes the boxer out of range once the punches are done.
const List<String> exits = [
  'exit',
  'pivot',
  'step back',
  'circle left',
  'circle right',
];

/// True when [to] may follow [from]: chained punches, or a defense's opening.
bool isAllowedTransition(String from, String to) {
  if (!isPunch(to)) return false;
  final afterDefense = punchesAfterDefense[from];
  if (afterDefense != null) return afterDefense.contains(to);
  if (isMovement(from)) return true;
  return allowedNext[from]?.contains(to) ?? false;
}

/// True when [punch] may extend [chain]: a legal transition, and no third jab.
bool canExtendChain(List<String> chain, String punch) {
  if (!isPunch(punch)) return false;
  if (chain.isEmpty) return true;
  if (!isAllowedTransition(chain.last, punch)) return false;
  // The double jab is the one repeat worth throwing, and only once.
  return !(punch == '1' &&
      chain.length >= 2 &&
      chain.last == '1' &&
      chain[chain.length - 2] == '1');
}

/// True when a finished punch chain ends on a punch worth ending on.
bool chainEndsLegally(List<String> chain) {
  if (chain.length < 2) return true;
  if (chain.last != '1b') return true;
  // The jab to the body is a setup, never the shot a longer chain lands on;
  // the high-low jab is its one exception, as the double jab is for repeats.
  return chain.length == 2 && chain.first == '1';
}

/// True when [moves] reads as boxing: legal transitions, one double jab at
/// most, and every punch chain ending where a chain should end.
bool isValidCombination(List<String> moves) {
  if (moves.isEmpty) return false;
  final chain = <String>[];
  String? broke;
  for (final move in moves) {
    if (!_isKnownMove(move)) return false;
    if (!isPunch(move)) {
      if (!chainEndsLegally(chain)) return false;
      chain.clear();
      broke = move;
      continue;
    }
    if (chain.isEmpty) {
      if (broke != null && !isAllowedTransition(broke, move)) return false;
    } else {
      if (!canExtendChain(chain, move)) return false;
    }
    chain.add(move);
  }
  return chainEndsLegally(chain);
}

bool _isKnownMove(String move) =>
    isPunch(move) || isMovement(move) || advancedDefense.contains(move);
