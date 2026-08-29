# Decisions

Newest first. One entry per decision that a later reader might want to revisit.

## 2026-08-29 Move animations dropped

Four attempts at an in-app animated boxer (tactical board, silhouette rig, shaded 3D mannequin,
flat-vector cut-out figure) did not reach the illustration quality the product owner wants, and
the owner chose to drop the idea rather than iterate further. If it returns, the route is
designer-authored Lottie or Rive clips (about 30 moves, mirrored for southpaw) played through a
`MoveAnimation` slot; no code-drawn figure. Nothing in the app depends on it.

## 2026-08-29 Logo: corner ropes

Five directions were reviewed with the product owner (B period, ring bell, corner ropes,
glove, one-two). The owner first chose the one-two notation mark, then settled on the corner
ropes: a red corner post and three chalk ropes, the corner being where the coach stands.
Source PNGs live in `assets/icon/`; run 4 wires them into the Android mipmaps.

## 2026-08-29 Bells on the media stream, voice forced to en-US

The test phone aliases `STREAM_SYSTEM` to the ring stream, so `assistanceSonification` ignored
the media volume and the bell was faint. Cue audio now uses `AndroidUsageType.media` with
transient-may-duck focus and full player volume; the WAVs were regenerated at 0.95 peak. The
phone's locale is en-IN and its default voice mispronounces "jab", so `VoiceService` selects a
local en-US voice by name and Settings gets a "Test voice" button. Bundled voice clips stay on
the table if that is not enough.

## 2026-08-29 One service in the widget tree: `Provider<VoiceService>`

Pages must not import services, with one exception: a plain `Provider<VoiceService>` (and
later `Provider<NotificationService>`) so Settings can trigger a one-off test or a permission
prompt. They are not `ChangeNotifier`s and carry no state the UI reads.

## 2026-08-29 Combinations follow a written boxing grammar

The first generator only alternated hands and produced legal-but-odd chains (`3-1`, `6-1b`).
`lib/data/boxing_grammar.dart` now states which punch may follow which, which counters follow
each defense, and how a chain may end; the 60-entry library and every generated combination
are validated against it in tests. Content is stance-neutral (lead/rear), so orthodox and
southpaw read the same notation.

## 2026-08-29 Quotes and facts are a fixed, attributed list

Motivational copy is limited to a curated list of quotations with author and sport, and a list
of boxing records with the boxer or event named. Workers may not add or reword entries; the
Architect owns the list so every line stays verifiable. No em-dashes, per house style.

## 2026-08-29 Reminders are inexact local notifications

Daily reminder and streak nudge use `flutter_local_notifications` with inexact scheduling, so
the app never asks for the exact-alarm permission. The nudge is re-planned from history: it is
moved to tomorrow as soon as a session is logged today.

## 2026-08-29 Product answers: all levels, spoken cues, streak-only gamification

Settled with the product owner before the first build. V1 serves beginners, competitive
amateurs and pros together (library carries all three difficulties, drills get a picker).
Combination prompts are spoken by the phone's on-device TTS engine (`flutter_tts`) so a boxer
never has to read the screen mid-round; bells and beeps are bundled WAVs synthesised in-repo
(`assets/audio/`, no licensing). Gamification is a streak plus a handful of milestone badges;
XP and levels are out. Full list in `product.md`, "Answered questions".

## 2026-08-29 Look: blackout + one hot accent, Bebas Neue + Inter

Near-black surfaces, off-white type, one hot red for live state and primary CTAs, mint for rest
and positive stats, amber for "get ready" and warnings. Bebas Neue (display, numbers) and Inter
(text), bundled under `assets/fonts/` with their OFL licences so the app never fetches a font.
Chosen over "fight-night neon" (louder, less classy) and "vintage poster" (lower contrast in a
dark gym).

## 2026-08-29 Session engine counts down from a wall-clock deadline

`SessionProvider` ticks on one `Timer.periodic(1 s)` but derives `secondsLeft` from a phase
deadline (`clock()` minus the phase start), not by decrementing a counter. A stalled isolate
(phone call, heavy GC) then loses no time. The clock is injectable for `FakeAsync` tests.
Warnings and cues fire on "crossed the mark and not yet fired", so a skipped second cannot
swallow them.

## 2026-08-29 Providers read `shared_preferences` directly; only history gets a service

`SharedPreferences` is already the storage abstraction and is mocked with
`setMockInitialValues`; wrapping it in a `PreferencesService` would be a layer with one caller.
Session history is different (it will outgrow prefs), so it sits behind `HistoryStore` (run 3).
Audio, haptics, wake lock and TTS are services because they are platform plugins.

## 2026-08-29 Cue services are plain objects wired in `main()`, not widgets

`CueController` subscribes to `SessionProvider.events` and `SettingsProvider` and drives the
audio, haptics, voice and wake-lock services. Building it in `main()` before `runApp` keeps it
free of `BuildContext`, testable with fakes, and alive for the app's whole life.

## 2026-08-29 Build order: training screen first

The concept document's own advice: prototype the session screen before anything else, because
"a boxer at the gym at 6:00 AM finishing a 45-minute session without looking at the phone" is
the scenario the whole product is judged on. The backlog therefore runs foundation -> models and
library -> session engine -> Train tab, and only then Home, Skills, Progress and Journal.

## 2026-08-29 Local-first, no backend in V1

From the product concept: workouts bundled, history and preferences on the device, analytics
computed locally, no account. Cloud sync is an ecosystem idea, not a V1 constraint. Nothing in
the data model should assume a server, but the models are plain immutable Dart with `toJson`
so a sync layer can be added later without a rewrite.

## 2026-08-29 Same stack as Optum Launcher: `provider` + `shared_preferences`

The sibling project (`../optum_launcher`) settled on `provider` (ChangeNotifier) for state and
`shared_preferences` for preferences, with services as the platform boundary. Boxer OS keeps the
same layering so the conventions, test patterns and agent instructions carry over unchanged.
The history store is a separate decision (backlog D-01) because session records outgrow prefs.

## 2026-08-29 Android-only repository

The scaffold was created for Android only. Boxer OS is Android-first; iOS is not ruled out, but
no platform folder is kept for it until someone builds on it (`flutter create .` regenerates).

## 2026-08-29 Knowledge base lives in `docs/`, conventions stay in `.claude/CLAUDE.md`

`CLAUDE.md` is loaded into every session and holds only what every task needs: commands,
conventions, the tiered workflow. Everything that describes the state of the code (architecture,
findings, plan) lives in `docs/` so it can grow without bloating every prompt, and is updated by
the task that changes it. Copied from Optum Launcher.

## 2026-08-29 Three-tier agent workflow

Architect (Fable 5) plans and reviews; `developer` (Opus) writes all Dart/Kotlin; `assistant`
(Sonnet) writes tests and runs checks. Haiku is not used. Work happens on the checked-out branch,
no worktrees, the user commits, commit messages carry no trailers. See `.claude/CLAUDE.md`.
