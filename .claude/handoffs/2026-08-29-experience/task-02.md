# Task 02 - Combination library and the boxing-grammar generator

- **Run:** `.claude/handoffs/2026-08-29-experience/`
- **Depends on:** task-01
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
Sixty named, boxing-correct combinations as bundled data, and a generator that follows a real
boxing grammar (what naturally follows what, which counters follow which defense) instead of
just alternating hands. The owner flagged generated chains like `3-1` and `6-1b` as wrong;
after this task they cannot occur.

## Context the worker needs
- `lib/models/combination.dart`, `lib/utils/combination_generator.dart`,
  `lib/data/boxing_vocabulary.dart` (run 2), the cue notation (run 1 task-02).
- Existing tests in `test/utils/combination_generator_test.dart` and
  `test/models/combination_test.dart` will need updating; the assistant does that, you keep
  the public function names.

## Files
- `lib/models/combo_tag.dart` - create - `ComboTag`.
- `lib/models/combination.dart` - modify - identity and metadata fields.
- `lib/data/boxing_grammar.dart` - create - transition tables.
- `lib/data/combination_library.dart` - create - the sixty combinations.
- `lib/utils/combination_generator.dart` - rewrite - grammar-driven.
- `lib/data/boxing_vocabulary.dart` - modify - difficulty vocabularies (see below).
- `docs/architecture.md` - modify - rows.

## Spec

### `ComboTag`
`{ offense, counter, body, defense, movement }` with `label` ("Offense", "Counter", "Body",
"Defense", "Movement") and `fromName` (fallback offense).

### `Combination` changes
Add optional fields with defaults so run 2 call sites keep compiling:
`String id = ''` (library id, empty for generated), `String name = ''`, `String description = ''`,
`List<ComboTag> tags = const []`. `bool get isFromLibrary => id.isNotEmpty`. JSON includes
them (omit empty). Equality: two combinations are equal when both have the same non-empty `id`,
or when `id` is empty on both and `moves` and `difficulty` match; `seed` no longer takes part.
`hashCode` consistent with that.

### Grammar (`lib/data/boxing_grammar.dart`)
Top-level `const` maps of notation token -> list of allowed next punches (head or body):
```
'1'  -> ['1', '2', '3', '2b', '3b', '6']     // '1' again only once (double jab), enforced in code
'2'  -> ['3', '5', '3b', '1', '2b']
'3'  -> ['2', '4', '6', '2b']
'4'  -> ['3', '5', '2']
'5'  -> ['2', '4', '3']
'6'  -> ['3', '5', '2']
'1b' -> ['2', '3', '1']
'2b' -> ['3', '5', '2']
'3b' -> ['3', '2', '6']
```
`punchesAfterDefense`:
```
'slip'       -> ['2', '3b', '6', '3']
'slip left'  -> ['3', '3b']
'slip right' -> ['2', '2b', '6']
'roll'       -> ['3', '3b', '2']
'pull'       -> ['1', '2']
'parry'      -> ['2', '3']
```
`openers` (weighted): `'1'` x6, `'2'` x1, `'3'` x1, `'1b'` x1, `'2b'` x1 (a list with repeats).
`exits`: `['exit', 'pivot', 'step back', 'circle left', 'circle right']`.
`endingRules`: a chain of 2+ punches never ends on `1` or `1b` (except `1-1`), and a chain of
3+ never ends on a body shot. Provide `bool isAllowedTransition(String from, String to)` and
`bool isValidCombination(List<String> moves)` implementing all of the above (used by tests and
to assert the library).

### Vocabulary changes
`beginnerPunches = ['1', '2', '3', '2b']`, `beginnerDefense = ['slip', 'step back']`;
intermediate and advanced unchanged. Add `movementTokens = ['step in', 'step back', 'pivot',
'circle left', 'circle right', 'exit']` and `bool isMovement(String)`.

### Generator (rewrite, same signatures)
`generateCombination({difficulty, seed})` and `generateCombinationSet(...)`:
1. Pick an opener from `openers` restricted to the difficulty's punch list.
2. Grow the punch chain by picking uniformly among `allowedNext[last]` intersected with the
   difficulty's punches, honouring the double-jab-once and ending rules (retry the last pick
   up to 5 times, then drop to a shorter chain that ends legally).
3. Beginner: 2 to 3 punches; 30% chance of a trailing `slip` or `step back` after a 2-punch chain.
   Intermediate: 3 to 4 moves with exactly one defense inserted after the first chain of 1 to 2
   punches, followed by a chain that starts from `punchesAfterDefense[defense]`.
   Advanced: 4 to 6 moves, one or two defenses (never adjacent, never first or last), 50% chance
   of a trailing exit from `exits`.
4. Every result satisfies `isValidCombination`; the tests assert it over 300 seeds each.

### Library (`lib/data/combination_library.dart`)
`const List<Combination> combinationLibrary` (ids `c01`..`c60`, all `isFromLibrary`), plus
`Combination? findCombination(String id)` and `List<Combination> combinationsWhere({Difficulty? difficulty, ComboTag? tag})`.
Author exactly these (notation -> moves list; name; tags; write a one-sentence coaching
description each, e.g. "Return straight down the middle after the slip; keep the chin behind the shoulder."):

Beginner (c01-c15):
| id | notation | name | tags |
|---|---|---|---|
| c01 | `1` | Jab | offense |
| c02 | `1-1` | Double jab | offense |
| c03 | `1-2` | One-two | offense |
| c04 | `1-1-2` | Double jab, cross | offense |
| c05 | `1-2-3` | One-two-three | offense |
| c06 | `2-3` | Cross, hook | offense |
| c07 | `1-3` | Jab, hook | offense |
| c08 | `1-2-1` | One-two, jab out | offense |
| c09 | `1-1b` | High-low jab | body |
| c10 | `1-2b` | Jab, cross downstairs | body |
| c11 | `1, step back` | Jab and reset | movement |
| c12 | `1, slip, 2` | Slip and return | counter, defense |
| c13 | `1-2, step back` | One-two and out | movement |
| c14 | `1-2, slip` | One-two, slip | defense |
| c15 | `1, pivot` | Jab and pivot | movement |

Intermediate (c16-c40):
| id | notation | name | tags |
|---|---|---|---|
| c16 | `1-2-3-2` | One-two-three-two | offense |
| c17 | `1-2-5-2` | Uppercut in the middle | offense |
| c18 | `1-2-3b-3` | Body-head hook | body |
| c19 | `1-2b-3` | Downstairs, hook upstairs | body |
| c20 | `2b-3` | Body cross, lead hook | body |
| c21 | `3b-3` | Double hook, low high | body |
| c22 | `1-6-3` | Jab, uppercut, hook | offense |
| c23 | `1-2-3-2b` | Finish downstairs | body |
| c24 | `1-1-2-3` | Double jab, cross, hook | offense |
| c25 | `1-3-2` | Jab, hook, cross | offense |
| c26 | `1-2, slip, 2` | Slip and return | counter, defense |
| c27 | `1-2, roll, 3-2` | Roll under, hook cross | counter, defense |
| c28 | `1-2, pull, 2` | Pull counter | counter, defense |
| c29 | `slip, 2-3` | Slip inside, cross hook | counter |
| c30 | `parry, 2` | Parry and cross | counter |
| c31 | `1-2, pivot, 1-2` | Pivot and reset | movement |
| c32 | `1-2, step back, 1-2` | Draw and return | movement |
| c33 | `1-2-3, exit` | Hit and go | movement |
| c34 | `1, step in, 3b-3` | Close and dig | body, movement |
| c35 | `2-3-2` | Cross hook cross | offense |
| c36 | `1-2-1-2` | Straight punches | offense |
| c37 | `1-2, circle left` | One-two and circle | movement |
| c38 | `3-2-3` | Hook cross hook | offense |
| c39 | `5-2` | Lead uppercut, cross | offense |
| c40 | `1-2-5-3` | Uppercut, hook finish | offense |

Advanced (c41-c60):
| id | notation | name | tags |
|---|---|---|---|
| c41 | `1-2-3-2-3` | Five straight | offense |
| c42 | `1-2b-3-2` | Downstairs upstairs | body |
| c43 | `1-6-3-2` | Uppercut sandwich | offense |
| c44 | `1-2-3b-3-2` | Dig and finish | body |
| c45 | `2-3-6-3` | Inside four | offense |
| c46 | `1-2, slip, 3b-3` | Slip and dig | counter, body |
| c47 | `1-2, roll, 3-2, exit` | Roll off, fire, leave | counter, movement |
| c48 | `slip, 6-3` | Slip, uppercut hook | counter |
| c49 | `slip right, 2b-3` | Slip and bury | counter, body |
| c50 | `1-1-2b-3` | Double jab downstairs, hook | body |
| c51 | `1-2, pull, 3-2` | Pull, hook cross | counter, defense |
| c52 | `3b-3-2` | Body hook, hook, cross | body |
| c53 | `1-2-3, pivot, 2-3` | Pivot punish | movement |
| c54 | `parry, 2-3-2` | Parry and unload | counter |
| c55 | `1, slip, 1, slip, 2` | Slip drill | defense |
| c56 | `2-3b-3-2` | Cross, low high, cross | body |
| c57 | `1-2-5-2-3` | Five-punch | offense |
| c58 | `6-3-2` | Uppercut hook cross | offense |
| c59 | `1-2, step in, 5-2` | Close with the uppercut | movement |
| c60 | `1-2-3-2, pivot, exit` | Finish and vanish | movement |

Every library entry must pass `isValidCombination` (tests assert it). If one does not, the
grammar table is wrong, not the entry: report it in NOTES rather than editing the table.

## Out of scope
- UI (task-03). Bookmarks (task-03).
- Removing `seed` from `Combination`.

## Acceptance criteria
- [ ] 300 seeds per difficulty: every generated combination satisfies `isValidCombination`,
      lengths are in range, `3-1` and `6-1b` never appear, no chain of 2+ ends on `1` except `1-1`.
- [ ] Same seed and difficulty -> equal combination; distinct notations over 20 seeds >= 10
      (beginner) and >= 15 (others).
- [ ] `combinationLibrary.length == 60`, ids unique and in order, every entry valid, every
      entry has a name, a description and at least one tag; `combinationsWhere(difficulty:
      beginner).length == 15`.
- [ ] `Combination` JSON round-trips the new fields; library equality is by id.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: update `test/utils/combination_generator_test.dart`,
  `test/models/combination_test.dart`; create `test/data/boxing_grammar_test.dart`,
  `test/data/combination_library_test.dart`.
