# Boxer OS

A local-first boxing training companion for Android, built with Flutter. One app for the whole
loop: **plan** a session, **train** with round timers and guided cues (bells, haptics, big
high-contrast screens), **improve** with combination, reaction and footwork drills, **track** and
**analyze** rounds, minutes, streaks and records, and **reflect** in a training and sparring
journal. No account, no backend: everything works offline and lives on the device.
`docs/product.md` has the vision, the information architecture and the V1 scope.

Tagline: "Train. Fight. Improve. Repeat."

## Stack & environment

- Flutter 3.41.2 stable, Dart SDK `^3.11.0`. `flutter` is on PATH (`~/Developer/sdks/flutter`).
  Dart 3.11 allows dot shorthands (`.fromSeed(...)`); use them only where the surrounding code does.
- Android-only repository: the scaffold was created with `--platforms android`, so there is no
  `ios/ macos/ linux/ windows/ web/` (`flutter create .` regenerates them if ever wanted).
- Application id / Kotlin package: `com.prdy.boxer_os`. Native code lives in
  `android/app/src/main/kotlin/com/prdy/boxer_os/` (`MainActivity.kt`, currently the stock
  `FlutterActivity`). No MethodChannel exists yet; if one is added, name it `boxer_os/<area>` and
  document it in `docs/architecture.md`.
- App stack: `provider` (ChangeNotifier) for state, `shared_preferences` for preferences and
  history (JSON lists behind `HistoryStore`), `audioplayers` for the bundled bells, `flutter_tts`
  for spoken cues, `HapticFeedback` for haptics, `wakelock_plus` during sessions,
  `flutter_local_notifications` + `timezone` + `flutter_timezone` for reminders. New dependencies
  only through a handoff package that names the reason and version.
- Lints: `flutter_lints` via `analysis_options.yaml`.
- Version: `pubspec.yaml` `0.1.0+1`. Once an in-app version string exists it lives on
  `AppTheme.appVersion` and is kept in step with `pubspec.yaml`.
- Current state (2026-08-29, evening): V1 is built (runs 1 to 6 under `.claude/handoffs/`);
  `docs/backlog.md` lists what is done and what is left. Tests live under `test/` mirroring `lib/`.

## Commands

| Purpose | Command | Notes |
|---|---|---|
| Deps | `flutter pub get` | |
| Static analysis | `flutter analyze` | Baseline (2026-08-29): 0 issues on the scaffold. Don't add new issues. |
| Tests | `flutter test` | `test/` mirrors `lib/` (models, providers, services, pages, widgets). |
| Format | `dart format lib test` | |
| Smoke build | `flutter build apk --debug` | Release builds sign with `android/key.properties` when present, the debug key otherwise; `docs/release.md` has the steps. |
| Run | `flutter run` | Needs a connected Android device/emulator. Test bells and haptics on a physical device. |

## Architecture

Canonical description: `docs/architecture.md` (target layout, module map, data flow, persistence).
Short version: `main.dart` -> `MultiProvider(SettingsProvider, SessionProvider, HistoryProvider,
ReactionProvider, CombosProvider, ShellProvider, ...)` -> onboarding on first launch, then an app
shell with four tabs (Home, Train, Skills, Progress). Pages and
widgets talk to providers; providers hold state and orchestration; services talk to the platform
(storage, audio, haptics, wake lock); bundled workout and drill definitions live under `lib/data/`
as Dart constants. The session timer engine is a provider driven by one `Timer.periodic` and a
wall-clock deadline, never by widget rebuilds. The module map in `docs/architecture.md` lists
every file.

## Conventions

- Styling comes from `lib/theme/app_theme.dart` only: colours, spacing, radii and the named
  `TextStyle`s; motion tokens from `lib/theme/app_motion.dart`, always through `AppMotion.of`
  so reduce-motion is honoured. New UI references `AppTheme` tokens, never colour or size literals.
  Gym-friendly by principle: dark, high contrast, large tap targets (48 dp minimum, bigger on the
  session screen), numbers readable from arm's length.
- Use `.withValues(alpha: x)`; `withOpacity` is deprecated and must not appear in `lib/`.
- Platform and storage errors never reach the UI as exceptions: services return null/false or
  throw `Exception`, providers catch and expose `error`. Keep that boundary.
- The session screen is phone-down friendly: every state change the boxer needs during a round
  is also delivered by sound or haptics, and no control on that screen is smaller than 64 dp.
- Tests live under `test/` mirroring `lib/` paths; mock prefs with
  `SharedPreferences.setMockInitialValues`, platform channels with
  `TestDefaultBinaryMessengerBinding`, and drive timers with `FakeAsync` / `tester.pump`.
  Widget tests pump inside `MultiProvider` with the real providers.

## Code guidelines

These apply to every tier and every language in the repo (Dart, Kotlin, tests, docs).

### Naming
- Dart: `lowerCamelCase` for variables, functions, parameters; `UpperCamelCase` for types and
  enums; `snake_case.dart` for files. Kotlin follows the standard Kotlin conventions.
- **Local variables and parameters never start with `_`** (`final rounds = ...`, not `final _rounds`).
  A leading underscore is reserved for what Dart needs it for: library-private class members and
  private widget/state classes (`_activeSession`, `_SessionPageState`). Do not use it for anything else.
- Names say what the thing is, not its type: `workouts` not `workoutList`, `stance` not
  `stanceEnum`. No Hungarian prefixes, no abbreviations (`roundDuration`, not `rndDur`).
- Booleans read as predicates: `isRunning`, `hasHistory`, `showCues`. Functions read as verbs:
  `startSession()`, `recordRound()`. Getters are nouns.
- Single-letter names only for trivial loop indices and lambda params that are obvious in context.
- SharedPreferences keys live as `static const` on the provider that owns them, in `snake_case`.

### Structure
- One widget, provider, service, or model per file, named after the file.
- Functions do one thing and stay short (aim for under 40 lines). If a `build()` needs a
  section, extract a widget class, not a `_buildX()` method, whenever the piece is reused,
  has its own state, or is more than ~30 lines. Small one-off helpers may stay as methods.
- Widgets: `const` constructors wherever possible, `super.key`, prefer `StatelessWidget`.
  Scope `Consumer`/`Selector` to the smallest subtree that needs the rebuild.
- Providers hold state and orchestration only; they do not import widgets or `BuildContext`.
  Services talk to the platform; widgets talk to providers. Keep that layering.
- Models are immutable: `final` fields, `const` constructors, `copyWith` when mutation is needed.
- Dispose what you create: controllers, focus nodes, streams, timers. Use `Timer.periodic` +
  cancel in `dispose()` rather than a self-rescheduling `Future.delayed`.
- No magic numbers in widget trees: name spacing/opacity/radius constants that are reused.

### Error handling
- Never leave an empty `catch`. Either handle it, surface it (a provider's `error`), or write a
  one-line comment saying why ignoring is correct.
- No `print`. Use `debugPrint` if a message is truly needed, otherwise nothing.
- Don't throw across the UI boundary; the service/provider layer converts failures into state.
- Kotlin: no `!!`. Handle nulls explicitly; keep `MainActivity` a thin bridge.

### Comments and prose
- Comment the *why*, never the *what*. Delete comments that restate the code
  (`// Getters` above a block of getters, `// Start session` above `startSession()`).
- Comments are short: one line, two at most. No paragraph-length explanations, no banners,
  no section dividers. If the code needs a paragraph to explain, simplify the code.
- **Never write the user's request or conversation into comments** (`// User asked for a
  rest option`, `// As per the handoff package, ...`). Code carries no memory of who asked
  for it or why the task was assigned; that context lives in git history and handoff files.
- `///` doc comments on public API only, one sentence, no boilerplate.
- **Do not use em-dashes** in code comments, doc comments, user-facing strings, handoff
  packages, or reports. Use a comma, a colon, parentheses, or a new sentence instead. Same for
  en-dashes in prose; a plain hyphen is fine for ranges.
- No emoji in code, comments, or commit-ready text. Plain ASCII punctuation.
- `TODO` comments need context: `// TODO: replace debug signing before Play release`, not `// TODO`.

### Simplicity and robustness
- Prefer the simplest implementation that fully meets the acceptance criteria. No
  abstractions, config knobs, or extension points for needs that do not exist yet.
- Robust means handling the failure cases that can actually happen (null from the platform,
  empty lists, prefs missing, a session interrupted by a phone call) with a clear fallback, not
  wrapping everything in defensive checks. Every branch should be reachable.
- Do not add layers (extra classes, wrappers, indirection) to code that works fine flat.
- When in doubt between clever and obvious, pick obvious.

### Accuracy (no hallucinating)
- Only call APIs, packages, classes, and methods you have verified exist: read the file, check
  `pubspec.lock`, or look at the Flutter SDK source. Never invent a method because it sounds right.
- Read a file before editing it. Never edit from memory of what it "probably" contains.
- If a fact is unknown (a package version, whether a widget supports a property, what a
  native API returns), find out or say so. Workers return `BLOCKED` with the question rather
  than guessing; the Architect does not present unverified claims in reviews or reports.
- Report outcomes as they are: if `flutter analyze` or a test was not run, say so; do not
  claim a pass you did not observe.

### Formatting and hygiene
- Run `dart format` on every touched file. Trailing commas on multi-line argument lists.
- Imports: `dart:` then `package:` then relative, each group sorted, no unused imports.
  Use relative imports inside `lib/`.
- Never commit generated or environment files (`build/`, `.dart_tool/`, `android/local.properties`).
- No new dependencies unless a handoff package lists them with a reason.
- Match the surrounding code's style when editing an existing file; do not reformat code you
  were not asked to change.

### Tests
- Test names describe behaviour: `test('startSession begins round 1 in the work phase', ...)`.
- Arrange / act / assert, one behaviour per test, no logic in tests.
- Mock at the boundary (SharedPreferences, platform channels, clock), never by editing production code.

## Knowledge base (`docs/`)

`docs/` is the project's running memory. Read `docs/README.md` for the reading order and update
rules. In short:

- `docs/product.md` - what the app is for, the information architecture and the V1 scope. Read it before designing anything.
- `docs/architecture.md` - how the code is put together. Developer agents update it in the same
  task whenever they add or remove a file, prefs key, or channel method.
- `docs/backlog.md` - prioritised plan with status. Architect updates it at planning and review time.
- `docs/review-log.md` - every review finding ever raised, with status. Read it before reviewing;
  never re-report an item already there.
- `docs/decisions.md` - design decisions and why.
- `docs/release.md` - signing and the Play checklist.

Known gaps and open findings live in `docs/backlog.md` and `docs/review-log.md`, not here.

---

# Tiered model workflow - read before doing any work

This repo uses a strict three-tier split so that the expensive model never touches raw code or
build logs. The main session runs on **Claude Fable 5** (set in `~/.claude/settings.json`);
that session is the Architect. **Haiku is never used here - Sonnet is the floor.**

| Tier | Model | Runs as | Does | Never does |
|---|---|---|---|---|
| **Architect** | Fable 5 | this session | ingest the goal, plan, write handoff packages, dispatch workers, review the final diff, report | write/edit Dart or Kotlin, run builds/tests, read raw build output |
| **Developer** | Opus | `developer` agent (`.claude/agents/developer.md`) | implement one handoff package end-to-end, `flutter analyze` its own work, return a compact summary | expand scope, make design decisions, dump logs |
| **Assistant** | Sonnet | `assistant` agent (`.claude/agents/assistant.md`) | unit/widget tests, mocks & fixtures, `analyze`/`test`/`build` smoke runs, mechanical sweeps, log triage | non-trivial logic, design decisions |

### Git rules (all tiers)

- **Work directly on the currently checked-out branch.** Never create git worktrees
  (no `isolation: "worktree"` on Agent/Workflow calls, no `git worktree add`, no `EnterWorktree`),
  never create or switch branches.
- **Never commit, stage, stash, or push unless the user asks for it in that session.** By default
  the user reviews and commits themselves; leave changes as unstaged modifications in the working tree.
- **Commit messages carry no `Co-Authored-By` or `Claude-Session` trailers.** Plain message only,
  conventional prefix (`feat:`, `fix:`, `docs:`, `chore:`, `build:`), body only when the subject
  does not say it all.

### Routing rules for the Architect

1. **Any change under `lib/` or `android/` goes to the `developer` agent** with a handoff package - even one-liners. You may edit `.claude/`, docs, and `pubspec.yaml` metadata directly.
2. **Tests, mocks, smoke checks, deprecation sweeps, formatting, log triage -> `assistant` agent.**
3. **Goals needing >= 2 packages or an implement -> test -> fix loop:** the `tiered-build` workflow
   (`.claude/workflows/tiered-build.js`) does this deterministically, but the Workflow tool only
   runs when the user opts in - by typing `/build <goal>` or asking for a workflow in their own
   words. **If the user gave a plain request, do not ask them to re-type it as `/build`.** Run the
   same sequence yourself with Agent calls: write the handoff packages -> `developer` per package
   (in dependency order) -> `assistant` for tests -> `assistant` smoke (`analyze` + `test`) ->
   `developer` fix round if it fails (max 2) -> your review. Mention at the end that `/build` runs
   this pipeline automatically next time.
4. Workers return **summaries, not logs**. If one returns a wall of output, ask it for the 5-line
   version (SendMessage) instead of reading it.
5. **Final review is yours**: `git diff --stat`, then `git diff -- <changed files>`. Check against the
   package's acceptance criteria and the conventions above. Send findings back to a `developer`
   agent as a follow-up package - don't patch them yourself.
6. Keep your context small: open a source file only when the plan or the review depends on it.
   Never tail `flutter` output; that's what the `assistant` is for.

### Handoff packages

Template: `.claude/handoffs/TEMPLATE.md`. Write packages to
`.claude/handoffs/<YYYY-MM-DD>-<slug>/task-NN.md` (plus `plan.md`) and pass workers the **path**,
so the spec lives on disk and not in anyone's context twice. Be concrete - exact files, signatures
where they matter, acceptance criteria a test could check, and an explicit out-of-scope list.
