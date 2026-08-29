# Task 02 - README and release notes

- **Run:** `.claude/handoffs/2026-08-29-release/`
- **Depends on:** none (screenshots are taken from the current debug build)
- **Worker:** assistant (Sonnet)
- **Tests:** no

## Goal
A README a Gen Z boxer or a contributor would actually read: what the app is, six device
screenshots, install steps, the local-first promise, the tiered build workflow in one
paragraph, and a Play Console notes section in `docs/release.md`.

## Context the worker needs
- `docs/product.md` (one-liner, principles, V1 scope), `docs/release.md`, `.claude/CLAUDE.md`
  (commands, no em-dashes, no emoji).
- Screenshots: take fresh ones from the attached device after `flutter build apk --debug` and
  `adb install -r` (Home, Train, Session in the work phase, Combos library, Reaction mode picker,
  Progress). Onboarding may appear on a cleared install; complete it with any name first. Use
  `adb exec-out screencap -p > docs/screenshots/<name>.png`, then downscale each to 540 px
  wide with `python3 -c` and Pillow (installed) so the repo stays small. Names: `home.png`,
  `train.png`, `session.png`, `combos.png`, `reaction.png`, `progress.png`. If the display is off
  (`adb shell dumpsys power | grep mWakefulness` not Awake), report it and use the existing
  captures under the scratchpad `shots2/` directory instead.

## Files
- `README.md` - rewrite.
- `docs/screenshots/*.png` - create (6 files).
- `docs/release.md` - modify - add the "Play Console notes" section below.

## Spec

### README.md structure
1. Title "Boxer OS", tagline "Train. Fight. Improve. Repeat.", one paragraph from
   `docs/product.md` "One line".
2. A row of the six screenshots (an HTML `<p>` with six `<img width="150">` tags so they sit
   side by side on GitHub).
3. "What it does": six bullets (Plan, Train, Improve, Track, Analyze, Reflect) in one line each,
   taken from the concept's "Core product experience".
4. "Local-first": three sentences. No account, no backend, nothing leaves the phone; history
   and settings live in app storage; delete the app and the data is gone.
5. "Install": Flutter 3.41.2, `flutter pub get`, `flutter run` on a connected Android device,
   plus `flutter build apk --release` with a pointer to `docs/release.md` for signing.
6. "Develop": the four commands table from `CLAUDE.md`, and one paragraph on the knowledge
   base (`docs/`) and the tiered agent workflow (Architect plans, Opus implements, Sonnet
   tests; `/build <goal>` runs it).
7. "Status": V1 feature list with what is done (round timer and 12 guided workouts with bells,
   haptics and spoken cues; a 60-combination library with a boxing-grammar generator, bookmarks
   and practice sessions; reaction trainer with Tap, Direction, Defense and Go / No-go modes plus
   the Endurance 60 format; footwork drills; journal with ratings and sparring notes; Progress with
   streak, weekly chart, milestones; onboarding, quotes and did-you-know facts; daily reminder and
   streak nudge; settings with a voice test) and what is not (move animations, video, sync).
8. Fonts and audio credits: Bebas Neue and Inter under the SIL OFL (`assets/fonts/OFL-*.txt`),
   bells and beeps synthesised in-repo.

### docs/release.md addition
"## Play Console notes": data safety (no data collected or shared, all on device, no
analytics SDKs), permissions actually declared after the plugin manifests merge (run
`unzip -p build/app/outputs/flutter-apk/app-debug.apk AndroidManifest.xml` is binary; instead
use `aapt dump permissions` if available, otherwise list from the plugin docs: `WAKE_LOCK`
from wakelock_plus; state clearly which method you used), target audience (18+ fitness), and
the screenshot set location.

## Out of scope
- Any `lib/` or `android/` change. Do not edit `CLAUDE.md`.

## Acceptance criteria
- [ ] README renders the six images (paths relative to the repo root) and every section above.
- [ ] Screenshot files are 540 px wide PNGs under 300 KB each.
- [ ] `docs/release.md` has the Play Console notes with the method used for the permission list.
- [ ] No em-dashes or emoji in either file.

## Extra captures for the Architect (not for the README)
Into `/private/tmp/claude-501/-Users-praneeth-rdy-Developer-Opensource-boxer-os/d3e864f0-88dd-4ec8-90ea-a3644def066b/scratchpad/shots6/`:
`01_reaction_picker.png` (Skills > Reaction, showing the format toggle and four cards),
`02_defense_arena.png` (tap "Defense", wait 5 s, capture during WAIT or the punch word),
`03_gonogo.png` (Stop, tap "Go / No-go", wait 5 s, capture), `04_endurance_header.png`
(Stop, switch the toggle to "Endurance 60", tap "Tap", wait 5 s, capture the header),
`05_result.png` (let a Tap run finish by tapping when it says GO, ten times, or tap Stop and
skip if it takes too long), `06_progress_reaction.png` (Progress tab scrolled to the REACTION
section). Report any overflow or clipped text.
