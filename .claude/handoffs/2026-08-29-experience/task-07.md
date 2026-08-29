# Task 07 - Grammar corrections (review of task-02)

- **Run:** `.claude/handoffs/2026-08-29-experience/`
- **Depends on:** task-06
- **Worker:** developer (Opus)
- **Tests:** yes (developer updates the grammar/generator tests that exist; the assistant writes the library tests afterwards)

## Goal
Five library combinations failed `isValidCombination` because three grammar rules in task-02
were too strict. The Architect's ruling: the combinations are correct boxing; fix the grammar.

## Context the worker needs
- `lib/data/boxing_grammar.dart`, `lib/utils/combination_generator.dart`,
  `lib/data/boxing_vocabulary.dart`, `lib/data/combination_library.dart` (read only),
  `test/utils/combination_generator_test.dart`, `test/data/boxing_grammar_test.dart` (if present).
- Another agent is only reading the tree (device walkthrough); no concurrent edits.

## Files
- `lib/data/boxing_grammar.dart` - modify.
- `lib/utils/combination_generator.dart` - modify - preferences replace the dropped rules.
- `lib/data/boxing_vocabulary.dart` - modify - remove the now-unused `advancedExits` (grammar `exits` is the source).
- `test/utils/combination_generator_test.dart`, `test/data/boxing_grammar_test.dart` - modify.
- `docs/architecture.md` - modify only if a row's description becomes wrong.

## Spec
1. `allowedNext['1']` gains `'1b'` (high-low jab). `punchesAfterDefense['pull']` gains `'3'`
   (pull counter with the lead hook). `punchesAfterDefense['slip']` gains `'1'`.
2. Ending rules in the validator become: a chain of 2+ punches may not end on `1b`; the
   double jab (`1-1`) stays the only adjacent repeat. Remove "may not end on `1`" and
   "3+ may not end on a body shot" from `chainEndsLegally` / `isValidCombination`.
3. Generator keeps the old endings as preferences: when picking the final punch of a chain,
   prefer candidates that are head shots and not `1`; fall back to any legal candidate only
   when the preferred set is empty. Everything the generator emits must still pass
   `isValidCombination`, and the distribution tests from task-02 (no `3-1`, no `6-1b`,
   distinct-notation thresholds) must still pass.
4. After the change all 60 library entries pass `isValidCombination` (verify with a throwaway
   test or a `flutter test` run of the existing library test if one exists; report the count).

## Out of scope
- Any UI. Any library entry edit.

## Acceptance criteria
- [ ] All 60 library entries valid; `combinationsWhere(difficulty: beginner).length == 15`.
- [ ] Generator tests green with the preference in place; 300 seeds per difficulty valid.
- [ ] `advancedExits` gone with no remaining references.
- [ ] `flutter analyze` 0 issues; full suite green.

## Verification
`flutter test`, `flutter analyze`.
