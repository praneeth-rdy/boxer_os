# Architecture

Local-first boxing training companion in Flutter, Android-only. Five tabs (Home, Train, Skills,
Corner, Progress), a session screen that runs round timers with bells and haptics, and local storage for
preferences and training history.

Last verified against the code: 2026-08-30. Update this file in the same change that makes it wrong.

## Stack

- Flutter 3.41.2 stable, Dart SDK `^3.11.0`.
- Android only (created with `--platforms android`). `flutter create .` regenerates the other
  platform folders if ever needed.
- Application id and Kotlin package: `com.prdy.boxer_os`. `minSdk`/`targetSdk`/`compileSdk` come
  from the Flutter defaults (`flutter.minSdkVersion` etc. in `android/app/build.gradle.kts`). That
  file also enables core library desugaring (`desugar_jdk_libs` 2.1.4) and multidex, both required
  by `flutter_local_notifications`; without them `assembleDebug` fails on its AAR metadata check.
- Release builds sign with the upload key when `android/key.properties` exists and fall back to
  the debug key when it does not, so a fresh checkout or CI without secrets still builds
  (`build.gradle.kts` reads the file into a `release` signing config). `key.properties` and any
  keystore are gitignored; `android/key.properties.example` is the template. See `docs/release.md`.
- Dependencies today: `provider` ^6.1.5, `shared_preferences` ^2.5.5, `audioplayers` ^6.7.1
  (6.8 requires Flutter 3.44), `flutter_tts` ^4.2.5, `wakelock_plus` ^1.7.0,
  `flutter_local_notifications` ^22.3.0 with `timezone` ^0.11.1 and `flutter_timezone` ^5.1.0
  (the reminder trio), `url_launcher` ^6.3.2 (the About screen's outbound links), `flutter_lints`,
  `flutter_test`, `fake_async`, `shared_preferences_platform_interface` (dev only, for the
  in-memory prefs store the settings tests subclass). Training history rides on
  `shared_preferences` too, behind `HistoryStore`, so no store package was added.
- Assets: `assets/fonts/` (BebasNeue, Inter in four weights), `assets/audio/` (bells and beeps played by
  `AudioService`), `assets/legends/` (one photo per bundled legend, `<id>.jpg`), `assets/legends/gallery/`
  (the archive photos, `<id>_<n>.jpg`), `assets/wall/` (the fourteen Gym Wall atmosphere photos,
  `<id>.jpg`) and the single file
  `assets/icon/ic_launcher_1024.png` (the About screen's logo; the rest of `assets/icon/` stays out of
  the bundle), all declared in `pubspec.yaml`.

## Layers (target)

```
pages/widgets  ->  providers  ->  services  ->  platform (prefs, history store, audio, haptics, wake lock)
                       |
                     data/  (bundled workouts, drills, combination vocabulary)
```

Rules: widgets talk to providers, providers talk to services and read `data/`, services talk to
the platform. Four services are exposed to the page layer as plain `Provider<T>.value`s in
`main.dart`, each only so a page can fire a one-off call: `VoiceService` for Settings' "Test voice",
`NotificationService` for the notification permission prompt, `AudioService` for the beep the
reaction trainer's sound mode reacts to and `WallpaperService` for the Gym Wall's "set as
wallpaper"; every other use of them stays behind
`CueController` or `ReminderScheduler`. Providers never
import widgets or `BuildContext`; `utils/session_launcher.dart` is the one helper that takes a
`BuildContext`, because it serves the page layer rather than the provider layer. The session
engine (`SessionProvider`) advances on one `Timer.periodic` and exposes plain state (phase, round,
seconds left); widgets only render it and cue services react to its transitions.

Session engine: `SessionProvider` runs one `Timer.periodic(1 s)` and derives `secondsLeft` from a
wall-clock deadline (the phase start plus its length, read through an injectable clock), so a
stalled tick loses no time and `FakeAsync` can drive it. Phase changes, warnings and cues are
published on a broadcast `Stream<SessionEvent>` alongside `notifyListeners()`: the
`CueController` listens for bells, haptics and voice, and the session screen renders the state and
reacts to the same events. Marks and cues fire on "crossed the mark, not yet fired this round", so
a skipped second cannot swallow them.

Bundled data: the workout library is `const` Dart under `lib/data/`, not JSON assets, so it is
available synchronously with no loading step. `boxing_vocabulary.dart` holds the punch, defense
and movement tokens the combination generator draws from, one set per difficulty, and
`boxing_grammar.dart` holds what may follow what: the generator grows a chain through those
tables rather than alternating hands, and `isValidCombination` is the one rule the generated
and the bundled combinations are both held to (all sixty bundled entries pass it). Two shapes
are carved out by name: the double jab is the only adjacent repeat, and the high-low jab
(`1-1b`) the only chain that lands on the body jab. `combination_library.dart` is the sixty bundled
combinations. `legends.dart` is the twelve legend stories, each pointing at its photo under
`assets/legends/` and at its pull quotes by position in `quotes`, so the copy and the quote
library stay in one place each. The notation is
stance-independent, so `1` is the lead hand for orthodox and southpaw alike. `footwork_drills.dart`
is the Skills hub's own catalogue and is deliberately not part of `workoutLibrary`, so the Train
tab does not list it.

Reminders: `ReminderScheduler` is the second orchestrator alongside `CueController`. It listens to
`SettingsProvider` and `HistoryProvider`, coalesces bursts with a 300 ms timer, and rewrites the three
reminders through `NotificationService`: the daily one repeats at the chosen time with the quote of
the day as its body, the streak nudge is a single 8 pm notification skipped to tomorrow once a
session with a completed round is logged today, and the boxing-day note is a single 9 am
notification on the next date in `boxingCalendar` (today when the morning has not yet passed). Scheduling is inexact (`inexactAllowWhileIdle`), so
no exact-alarm permission is needed, and every failure is swallowed: reminders are best effort.

Recommendation: `recommendWorkout` is a pure rule over `TrainingStats`, the least recently trained
type (never sparring, it needs a partner) at or nearest the boxer's difficulty, so Home proposes a
session with no stored state of its own.

Reaction trainer: `ReactionProvider` is a second timer-driven engine, independent of the session
one. It holds one timer at a time (countdown, wait, stimulus timeout, feedback), takes an
injectable clock and `Random`, and measures a hit as `clock()` at the tap minus `clock()` at the
stimulus. The page picks the mode and the format and reports taps;
`ReactionArena` owns the hit zones and the `DefenseGrid`, `ColourGrid` and `SequencePad`.
Eight modes, grouped in the picker by `ReactionMode.isBoxing`. Tap and direction ask for a hit
anywhere or on one edge, defense calls an
`IncomingPunch` and asks for `defenseFor(punch, stance)` (the stance comes in on `start`, so the
engine reads no provider), and go / no-go shows a go stimulus 70 percent of the time and scores a
left-alone hold stimulus as a correct hold after 1000 ms, a tapped one as a false alarm.
Peripheral drops a dot at fractions 0.1 to 0.9 of the arena and takes a tap within
`dotHitRadius` (0.09) of it, colour prints one colour name in another colour's ink and takes the
ink, sequence flashes two to four arrows for 600 ms each and then takes them back in order (its
clock starts only once the arrows are hidden, and it times out at 2 s per arrow), and sound leaves
the screen dark and is answered off the beep the page plays on the stimulus. Two
formats: standard runs ten consumed trials, endurance runs until the first trial that ends past
`enduranceSeconds` (60), so a run finishes within one trial of the minute and `secondsLeft` is
computed on read rather than from a timer.

## Target layout (`lib/`)

| Folder | Holds |
|---|---|
| `main.dart` | `BoxerOsApp`: `MultiProvider` -> `MaterialApp` with `AppTheme.dark` -> the app shell. |
| `theme/` | `app_theme.dart`: `AppTheme`, the single source of colours, spacing, radii, type and `appVersion`; `app_motion.dart`: `AppMotion`, the same for durations and curves. |
| `models/` | Immutable value types: workout, round spec, session record, combination, drill, reaction result, journal entry, fighter profile. |
| `data/` | Bundled definitions: the workout library, drill catalogue, punch and defense vocabulary used by the combination generator. Dart constants or JSON under `assets/`. |
| `services/` | Platform and storage boundaries: preferences, history store, audio cues, haptics, wake lock. Static or single-instance, return null/false or throw `Exception`, never leak platform errors. |
| `providers/` | `ChangeNotifier`s: settings, session engine, history, progress, skills. State and orchestration only. |
| `pages/` | One file per screen: app shell, home, train, session, skills, reaction trainer, corner, progress, history, settings. |
| `widgets/` | Reusable pieces: round clock, cue banner, big pill buttons, stat tiles, streak strip, rating input. |
| `utils/` | Pure helpers: duration formatting, date helpers, streak maths. |

## Module map (`lib/`)

| File | Role |
|---|---|
| `main.dart` | `main()` (portrait lock, system overlay style, loads `SettingsProvider`, `HistoryProvider` and `CombosProvider`, creates `SessionProvider`, builds the cue services and holds the `CueController` in the top-level `cues`, initialises `NotificationService` and holds the `ReminderScheduler` in the top-level `reminders`) and `BoxerOsApp`: `MultiProvider` (settings, session, history, `CombosProvider`, `ReactionProvider`, `ShellProvider`, `WallProvider`, `Provider<AudioService>`, `Provider<VoiceService>`, `Provider<NotificationService>`, `Provider<WallpaperService>`) -> `MaterialApp` with `AppTheme.dark` -> `AppShell`, or `OnboardingPage` while `onboardingDone` is false. |
| `theme/app_theme.dart` | `AppTheme`: colours, spacing, radii, sizes, text styles, `appVersion` and the dark `ThemeData` (including the Android `FadeForwardsPageTransitionsBuilder`). |
| `theme/app_motion.dart` | `AppMotion`: the animation durations (`fast`, `base`, `slow`, `flash`, `stagger`), the `enter` and `change` curves, and `reduced` / `of` for the system's reduce-motion setting. |
| `models/stance.dart` | `Stance` enum (orthodox, southpaw) with `label` and `fromName`. |
| `models/difficulty.dart` | `Difficulty` enum (beginner, intermediate, advanced) with `label` and `fromName`. |
| `models/training_type.dart` | `TrainingType` enum (shadow boxing through custom) with `label` and `fromName` (falls back to `custom`). |
| `models/round_cue.dart` | `RoundCue`: cue text and the second inside the work phase it fires at, with JSON and equality. |
| `models/round_spec.dart` | `RoundSpec`: one round's work and rest seconds, focus title and cues, with JSON and equality. |
| `models/workout.dart` | `Workout`: id, name, type, difficulty, rounds, totals (`totalSeconds`, `estimatedMinutes`), `copyWith`, JSON, and the `Workout.quick` round-timer factory. |
| `models/session_record.dart` | `SessionRecord`: one finished or abandoned session (type, stance, duration, rounds) plus the journal (rating, what worked, what needs work, opponent and opponent stance), with `copyWith` and JSON. |
| `models/session_phase.dart` | `SessionPhase` enum (idle, prepare, work, rest, complete). |
| `models/session_event.dart` | `SessionEventType` enum and `SessionEvent`: one engine announcement (type, round, optional cue text) with equality. |
| `models/combination.dart` | `Combination`: a combination's moves, level and seed, plus the library identity (`id`, `name`, `description`, `tags`, `isFromLibrary`), with `notation`, `spoken`, `punchCount`, JSON and equality (by id when it has one, otherwise moves and level). |
| `models/combo_tag.dart` | `ComboTag` enum (offense, counter, body, defense, movement) with `label` and `fromName` (falls back to offense). |
| `models/reaction_mode.dart` | `ReactionMode` enum (tap, direction, defense, goNoGo, peripheral, colour, sequence, sound) with `label`, `description`, `isBoxing` (the picker's grouping) and `fromName`. |
| `models/reaction_format.dart` | `ReactionFormat` enum (standard, endurance) with `label` and `fromName`. |
| `models/reaction_colour.dart` | `ReactionColour` enum (red, mint, amber, chalk) with `label`, the `swatch` it paints in and the `onSwatch` a label stays readable in. |
| `models/reaction_direction.dart` | `ReactionDirection` enum (up, down, left, right) with the arrow `icon`. |
| `models/incoming_punch.dart` | `IncomingPunch` enum (jab, cross, leadHook, rearHook, body) with `label`, the punch a defense trial calls. |
| `models/defense_zone.dart` | `DefenseZone` enum (slipLeft, slipRight, roll, block) with `label`, plus `defenseFor(punch, stance)`, the answer that beats a punch. |
| `models/reaction_result.dart` | `ReactionResult`: one finished reaction test (mode, format, hits, false starts, misses, correct holds, false alarms, duration) with `trials`, `bestMillis`, `averageMillis`, the half averages and `decayPercent`, `accuracy`, JSON and equality. |
| `models/milestone.dart` | `Milestone`: one progress badge (id, title, description, icon) and whether it is achieved. |
| `models/quote.dart` | `Quote`: one attributed quotation (text, author, sport). |
| `models/boxing_fact.dart` | `BoxingFact`: one piece of boxing history and the boxer or event it names. |
| `models/boxing_event.dart` | `BoxingEvent` and `EventKind` (anniversary, birthday, memorial, international day): one dated moment in boxing, with its `subtitle` (kind and year) and the optional `legendId` of the bundled legend it belongs to. |
| `models/legend.dart` | `Legend`, `StorySection`, `PhotoCredit` and `GalleryPhoto`: one boxer's story (identity, hook, four sections, pull quotes by position in `quotes`, takeaways, the portrait with its credit and `photoFocus` crop, and the archive `gallery`). |
| `models/poster.dart` | `PosterKind` enum (tagline, legend, moment, inspiration, quote) with its filter `label`, and `Poster`: one Gym Wall wallpaper (id, kind, title, and the tagline variant, legend, archive `gallery` photo, wall `photo` or quote it paints). |
| `models/wall_photo.dart` | `WallPhoto`: one Gym Wall atmosphere photograph (id, asset, the `line` its poster paints, caption and `PhotoCredit`). |
| `data/workout_library.dart` | `workoutLibrary`: the twelve bundled workouts with per-round cues, plus `findWorkout` and `workoutsOfType`. |
| `data/boxing_vocabulary.dart` | The punch, defense and movement tokens per difficulty (the exits live in `boxing_grammar.dart`), plus `isPunch`, `isLeadHand`, `isMovement` and `isBodyShot`. |
| `data/boxing_grammar.dart` | The boxing grammar: `allowedNext` (what follows each punch), `punchesAfterDefense`, weighted `openers`, `exits`, and `isAllowedTransition`, `canExtendChain`, `chainEndsLegally`, `isValidCombination`. |
| `data/combination_library.dart` | `combinationLibrary`: the sixty named combinations (`c01`..`c60`) with coaching notes and tags, plus `findCombination` and `combinationsWhere`. |
| `data/footwork_drills.dart` | `footworkDrills`: the ten bundled footwork drills (movement cues only, `fw_` ids, outside `workoutLibrary`), plus `findFootworkDrill`. |
| `data/app_identity.dart` | `AppIdentity`: the developer, brand, copyright, licence name and the source, licence, privacy policy and contact urls, in one place. |
| `data/quotes.dart` | `quotes`: the eighty-four bundled quotations (fifty-five from boxing), plus `QuoteSurface`, `quoteFor` (a fixed shuffle read at `day of year * 7` plus a per-surface offset, so Home, Progress, onboarding and the reminder never coincide), `quoteAfter` (the next one in that order, wrapping) and `quoteForSession` (by record id). |
| `data/boxing_facts.dart` | `boxingFacts`: the forty bundled facts, plus `FactSurface`, `factFor` (the same shuffled rotation as the quotes, with its own seed and per-surface offsets for Home and Progress), `factAfter` and `factForSession`. |
| `data/legends.dart` | `legends`: the twelve bundled legends in fixed order (each with two or three archive photos and pull quotes of its own), plus `findLegend` and `legendOfTheWeek` (the list stepped by the week of the year, so a legend holds for a week). |
| `data/boxing_calendar.dart` | `boxingCalendar`: the thirty-nine bundled boxing days in date order (thirty-five carry a `legendId`), plus `eventsOn` (a day's entries, by kind), `nextEvents` (the next ones, wrapping the year) and `monthName` / `monthAbbreviation`. |
| `data/posters.dart` | `posters()`: the hundred and forty-eight Gym Wall posters (four taglines, twelve legends, thirty-four archive moments, fourteen inspiration photos, eighty-four quotes, in that order), the `taglineLines` each tagline paints with `markPosterVariant`, and `posterPhotoAsset` / `posterPhotoFocus` / `posterCredit` (Pacquiao's poster takes his first archive photo because his portrait is too small for a wallpaper). |
| `data/wall_photos.dart` | `wallPhotos`: the fourteen atmosphere photographs the inspiration posters are built on, each with its line, caption and credit. |
| `services/audio_service.dart` | `AudioService`: two `AudioPlayer`s (bells, beeps) over the bundled WAVs at volume 1.0, plus `audioContextForCues()`, the media-usage sonification context so the bells follow the media volume and music ducks instead of stopping. |
| `services/haptics_service.dart` | `HapticsService`: `HapticFeedback` patterns (120 ms gaps) for round start and end, warnings and cues. |
| `services/voice_service.dart` | `VoiceService`: `flutter_tts` wrapper (en-US, rate 0.5, an explicit local en-US voice picked from `getVoices` because the device locale is en-IN) with `isAvailable`, `voiceName`, `speak`, `sayTest` and `stop`. |
| `services/history_store.dart` | `HistoryStore`: session records and reaction results as JSON lists in `shared_preferences`, with an injectable `SharedPreferences`; unreadable JSON loads as an empty list and a single bad entry is skipped. |
| `services/wake_lock_service.dart` | `WakeLockService`: `WakelockPlus.enable` / `disable`. |
| `services/notification_service.dart` | `NotificationService`: `flutter_local_notifications` over the `reminders` channel, with `init` (timezone database plus the device zone, UTC on failure), `requestPermission` (falls back to `areNotificationsEnabled` when the request returns false, null or throws), `scheduleDaily`, `scheduleOnce`, `cancel`, `cancelAll` and the `dailyReminderId` / `streakNudgeId` / `eventReminderId` ids; inexact scheduling, every call false on failure, now read through an injectable clock. |
| `services/reminder_scheduler.dart` | `ReminderScheduler`: keeps the daily reminder, the 8 pm streak nudge and the 9 am boxing-day note in step with `SettingsProvider` and `HistoryProvider`, debounced by 300 ms, over an injectable clock. |
| `services/cue_controller.dart` | `CueController`: maps `SessionEvent`s and `isActive` onto the cue services and the wake lock, each gated by the matching `SettingsProvider` flag. |
| `services/wallpaper_service.dart` | `WallpaperTarget` enum (home, lock, both) and `WallpaperService`: sends a rendered poster over the `boxer_os/wallpaper` channel (`set`), stores one poster of the live wallpaper rotation (`saveRotationFrame`), opens Android's live wallpaper screen (`openLivePicker`) and asks whether Gym Wall is the wallpaper in use (`isLiveActive`); false on any platform failure. |
| `providers/settings_provider.dart` | `SettingsProvider`: stance, difficulty, the fighter name, the onboarding-done flag, the sound/haptics/voice/keep-screen-on flags and the reminder settings (daily on/off, hour, minute, streak nudge on/off, boxing-day reminders on/off), persisted in `shared_preferences`. |
| `providers/session_provider.dart` | `SessionProvider`: the session state machine (phase, round, seconds left, cues, elapsed) on one timer, with start/pause/resume/skip/end/reset, a `SessionEvent` stream and the finished `SessionRecord`. |
| `providers/history_provider.dart` | `HistoryProvider`: the training history in memory (sessions and reaction results, newest first) over `HistoryStore`, with `load`, `addSession`, `updateSession`, `deleteSession`, `addReaction`, `clearAll` and `findSession`. |
| `providers/combos_provider.dart` | `CombosProvider`: the bookmarked combinations in memory (insertion order) over `shared_preferences`, with `load`, `isSaved`, `toggleSaved` and `remove`. |
| `providers/reaction_provider.dart` | `ReactionPhase` enum and `ReactionProvider`: the reaction test (countdown, wait, stimulus, feedback) on one timer, over eight modes and two formats, with `start`, `tap` (direction, defense, `at` or colour), `cancel`, `secondsLeft`, the per-mode stimulus (`dotPosition`, `inkColour` / `wordColour`, `sequence` / `entered` / `isShowingSequence`, `isSoundMode`) and the finished `ReactionResult`. |
| `providers/shell_provider.dart` | `ShellProvider`: which of the five shell tabs is showing (`tabIndex`, `showTab`, Home 0 to Progress 4), so a page can send the boxer to another tab. |
| `providers/wall_provider.dart` | `WallProvider`: which posters the Gym Wall live wallpaper cycles through (everything or a picked few, persisted) and the render that stores them, with `load`, `setShuffleAll`, `toggle`, `clearSelection`, `rotation`, `applyRotation` (shuffled, one frame at a time, progress on `renderedCount` / `renderTotal`) and `cancelRender`. |
| `pages/app_shell.dart` | `AppShell`: `IndexedStack` of the five tabs (Home, Train, Skills, Corner, Progress) behind a `NavigationBar`, both driven by `ShellProvider`. |
| `pages/onboarding_page.dart` | `OnboardingPage`: the three first-launch steps (fighter name over the quote of the day, stance, level) with Back/Next and a Skip that finishes on the defaults. |
| `pages/home_page.dart` | `HomePage` (an injectable `clock` so a test can pick the date): the greeting by name and settings gear, the two-row streak strip, the TODAY IN BOXING card on a day the calendar names (an `EventCard`, tapping it opens the event sheet), the quote of the day, the legend of the week as a featured `LegendCard` over a "More in Corner" link that switches the shell to the Corner tab, today's recommended session with Start (first-session copy while there is no history), three `QuickAction`s, the fact of the day and the last session. |
| `pages/train_page.dart` | `TrainPage`: the quick timer card and the library, grouped by training type; tapping a tile opens `WorkoutDetailPage`. |
| `pages/workout_detail_page.dart` | `WorkoutDetailPage`: one workout's description, stats and per-round breakdown, with the "Start workout" button. |
| `pages/session_page.dart` | `SessionPage`: the phone-down session screen (eyebrow, phase word, `RoundClock`, `CueBanner`, pause/skip/end), guarded by a `PopScope` end-session dialog; it listens to `SessionProvider.events` to wash the screen in the phase colour when a round or a rest starts. |
| `pages/session_complete_page.dart` | `SessionCompletePage`: the notes sheet (stats, the session's quote, rating, what worked, what needs work, opponent and stance on sparring, the session's fact) with a Save button; a session with no round and under a minute of work offers Done only. |
| `pages/skills_page.dart` | `SkillsPage`: the hub, three `SkillCard`s (combos, reaction and footwork, all wired). |
| `pages/corner_page.dart` | `CornerPage` (an injectable `clock`): the reading tab, the legend of the week over an "All legends" card, TODAY IN BOXING and the next three days over a Calendar card, the Quotes and Did-you-know cards, and the Gym Wall card under WALL. |
| `pages/gym_wall_page.dart` | `GymWallPage`: the poster gallery, a two-column grid of `PhonePreview`s behind a `FilterChipRow` of the five poster kinds (six chips with All); a cell opens `PosterPage`, and the Live wallpaper pill under the intro line opens `LiveWallpaperPage`. |
| `pages/live_wallpaper_page.dart` | `LiveWallpaperPage`: the live wallpaper rotation, an Everything / Pick a few `SegmentedButton` over the gallery grid in selection mode, the render estimate and "Render and set", which renders every poster through `PosterRenderer` into `WallProvider.applyRotation` behind a progress bar with Cancel and then opens Android's live wallpaper screen; a status line says whether Gym Wall is live, refreshed on open and on resume. |
| `pages/poster_page.dart` | `PosterPage`: one poster at 70 percent width in a `PhonePreview`, with the three set buttons; each captures the preview's `RepaintBoundary` at the device pixel ratio and hands the PNG to `WallpaperService`, then says whether it took. |
| `pages/quotes_page.dart` | `QuotesPage`: the whole quote library as compact `QuoteCard`s behind a `FilterChipRow` of sports (a boxing trainer's line files under Boxing). |
| `pages/facts_page.dart` | `FactsPage`: every bundled fact as a `FactCard`. |
| `pages/combos_page.dart` | `ComboView` enum and `CombosPage`: the three combination views (Generate, Library, Saved) behind a segmented control, each able to start a practice drill. |
| `pages/reaction_page.dart` | `ReactionPage`: the reaction trainer's format toggle and eight mode cards under the BOXING and PURE SPEED eyebrows, the running test (playing `AudioService.playTick` on each sound-mode stimulus) and the result (best, average, accuracy on defense and go / no-go, the endurance decay line). |
| `pages/footwork_page.dart` | `FootworkPage`: the footwork catalogue as `WorkoutTile`s; tapping one opens `WorkoutDetailPage`. |
| `pages/legends_page.dart` | `LegendsPage`: the twelve legends as `LegendCard`s under the Legends header; tapping one opens `LegendStoryPage`. |
| `pages/legend_story_page.dart` | `LegendStoryPage`: one legend read as a magazine feature (photo hero in a pinned `SliverAppBar` that turns `ink` and shows the name once collapsed, the title block on the `ink` ground below it, the facts strip as a `Wrap` of country, division and record chips, the four sections with the legend's own pull quotes between them, the FROM THE ARCHIVE `GalleryStrip` (the one block that bleeds past the text column, each other block padded by `_inColumn`), the numbered takeaways and the photo credit, which calls `openExternal`). |
| `pages/calendar_page.dart` | `CalendarPage`: the boxing year in twelve month groups of `EventTile`s, scrolled to the current month on open, with today's entry and the next one marked; a row opens the event sheet. |
| `pages/progress_page.dart` | `ProgressPage`: week rounds/minutes/streak tiles, the 7-day minutes chart, the week's split by type, the reaction section (per-mode best tiles, wrapped three to a line, the chart of the last ten bests and the newest endurance decay), milestone badges, all-time totals with the fact of the day, and the History `SkillCard` (captioned with the number of logged sessions) under the header; with no history it shows an `EmptyState` that switches the shell to Train. |
| `pages/history_page.dart` | `HistoryPage`: every stored session newest first, grouped under TODAY / YESTERDAY / `MON 24 AUG` day headers; a tile opens `SessionDetailPage`, and an empty history shows an `EmptyState` that pops back to the Train tab. |
| `pages/settings_page.dart` | `SettingsPage`: the fighter name field, stance, level, the four cue switches with the "Test voice" button and chosen-voice caption under them, the daily reminder, streak nudge and boxing-days switches (all behind the same permission request, with a refusal snackbar) with the time row and its picker, "Show onboarding again", the confirmed clear-history action and the About card. |
| `pages/about_page.dart` | `AboutPage`: the logo and version, who made it, the PolyForm Noncommercial licence with its two link rows, the privacy stance with the policy and contact rows, and the font, legend-photo, archive-photo and Gym Wall photo credits; a link row that fails says so in a snackbar. |
| `pages/session_detail_page.dart` | `SessionDetailPage`: one stored session read only (stats and notes) with a confirmed delete. |
| `widgets/section_header.dart` | `SectionHeader`: optional uppercase eyebrow, display title, optional trailing widget. |
| `widgets/pill_button.dart` | `PillStyle` enum and `PillButton`: full-width pill action in filled, outlined or ghost weight, with an optional leading icon, scaling down while pressed. |
| `widgets/stepper_row.dart` | `StepperRow`: labelled value with 48 dp round decrement and increment buttons, disabled at the range ends. |
| `widgets/quick_timer_card.dart` | `QuickTimerCard`: rounds, work and rest steppers over a `Workout.quick` summary and its Start button; the values are local to the card. |
| `widgets/workout_tile.dart` | `WorkoutTile`: one library workout as a tappable row (name, shape, estimated minutes). |
| `widgets/skill_card.dart` | `SkillCard`: one skill area (or the History row on Progress) as a tappable card, dimmed and marked SOON when it has no action yet. |
| `widgets/combo_tile.dart` | `ComboTile`: one combination as a tappable row (notation, name or spoken form, tags and level) with a bookmark toggle. |
| `widgets/combo_sheet.dart` | `showComboSheet`: the combination detail sheet (notation, coaching note, spoken form, tags) with Practice this and the Save toggle. |
| `widgets/filter_chip_row.dart` | `FilterChipRow`: a horizontally scrolling row of choice chips over any value type, led by an "All" chip that clears the filter. |
| `widgets/round_clock.dart` | `RoundClock`: the phase-coloured countdown and progress bar, plus `RoundClock.colorFor` (the phase colour the session screen shares); the colour cross-fades, the bar slides over the tick and the clock beats once a second through the last ten. |
| `widgets/cue_banner.dart` | `CueBanner`: the live cue, or the round focus while none has fired; the arriving cue rises as it fades in, the one it replaces only fades. |
| `widgets/rating_input.dart` | `RatingInput`: how the session felt, one to five, as a row of big round targets with the selected label under them. |
| `widgets/journal_field.dart` | `JournalField`: an uppercase label over a themed multi-line `TextField`. |
| `widgets/stat_tile.dart` | `StatTile`: one number and its uppercase label as a surface card, the value optionally coloured and counted up; `StatTile.text` takes a value that is not a plain number. |
| `widgets/bar_chart.dart` | `BarChart`: vertical bars scaled to the largest value on `line` tracks, labelled underneath; the last bar is the full colour, earlier ones faded. |
| `widgets/milestone_badge.dart` | `MilestoneBadge`: one `Milestone` as a circular badge, dimmed while unearned; earned badges settle in and scale up, unearned ones only fade. |
| `widgets/session_tile.dart` | `SessionTile`: one stored session as a tappable row (name, type, rounds, minutes, rating). |
| `widgets/reaction_arena.dart` | `ReactionArena` and the `ReactionTap` callback: the reaction hit area (stimulus, feedback colour, the direction pad, the defense and colour grids, the peripheral dot and its tap-to-fraction mapping, the go / hold flash and the ring pulsing through a dark sound wait); the glyph scales in, and the stimulus colour lands on its own frame so nothing is added to the measured time. |
| `widgets/colour_grid.dart` | `ColourGrid`: the four `ReactionColour`s as a 2 x 2 hit grid of filled zones with cornered labels, and an optional centre widget stacked over it. |
| `widgets/sequence_pad.dart` | `SequencePad`: the four direction edges with a centre that shows the arrows to memorise, then a dot per arrow filled as each is tapped back; with an empty sequence it is the plain direction pad. |
| `widgets/defense_grid.dart` | `DefenseGrid`: the four defense answers as a 2 x 2 hit grid with cornered labels, dimmed until a punch is live, and an optional centre widget stacked over it. |
| `widgets/quick_action.dart` | `QuickAction`: one Home shortcut as a square raised card, an icon over its label. |
| `widgets/quote_card.dart` | `QuoteCard`: one `Quote` as a surface card marked by a 3 dp accent bar down its left edge, `compact` for the in-page version and `cycles` for the tappable version that fades to `quoteAfter` under a "Tap for another" caption. |
| `widgets/fact_card.dart` | `FactCard`: one `BoxingFact` as a raised card under a "DID YOU KNOW · SUBJECT" eyebrow, with the same `cycles` tap-for-another behaviour as `QuoteCard`. |
| `widgets/legend_card.dart` | `LegendCard`: one legend as a photo at 1:1 (4:3 and in bigger type when `featured`) over a solid text block (country and division, name, hook); plus `LegendPhoto`, the portrait cropped around `photoFocus` and shared with the story hero. |
| `widgets/gallery_strip.dart` | `GalleryStrip`: a legend's archive photos as a horizontal `ListView` (280 dp wide at 4:3, caption and a tappable credit line) at a height computed from those metrics, so it can run edge to edge with `horizontalPadding` (`spaceLg` by default) insetting the first and last photo; a photo opens full screen in a zoomable viewer that closes on a tap outside. |
| `widgets/event_tile.dart` | `EventTile`: one calendar entry as a dated row (day and month column, title, blurb, kind and year), coloured `accent` when it is today and `rest` when it is next, tappable through `onTap`. |
| `widgets/event_card.dart` | `EventCard`: one calendar entry as a raised card (title, blurb, kind and year), opening its sheet; shared by Home and Corner. |
| `widgets/event_sheet.dart` | `showEventSheet`: the calendar entry's detail sheet (date line, kind chip, title, blurb) with "Read the legend" when the entry names one, which pops and pushes `LegendStoryPage`; plus `eventDateLine`. |
| `widgets/poster_canvas.dart` | `PosterCanvas`: one poster painted at a given logical `Size` on the ink ground, every measurement a fraction of its width so a thumbnail and a full-resolution render read the same; the corner-post-and-ropes mark is drawn, not an asset. Legend, moment and inspiration posters fill the frame with their photo under a scrim and bake the credit into the bottom; a moment's caption and an inspiration's line shrink to the room left rather than overflowing. |
| `widgets/poster_renderer.dart` | `PosterRenderer` and its public `PosterRendererState`: one poster painted at the device's size behind the live wallpaper page (it stays in the tree and painting, because an offstage box never paints), with `render(Poster)` returning PNG bytes at the device pixel ratio once the poster's photo is precached. |
| `widgets/phone_preview.dart` | `PhonePreview`: a rounded bezel with a punch hole that keeps the device's aspect ratio and scales its child to fill it. |
| `widgets/empty_state.dart` | `EmptyState`: a breathing accent dot, eyebrow, display title, body, an optional action button and an optional extra widget (a `QuoteCard` on Progress). |
| `widgets/settle_in.dart` | `SettleIn`: fades and lifts a page section into place once, staggered by `index` (capped at eight steps). |
| `widgets/count_up_text.dart` | `CountUpText`: a number that counts to its new value on tabular figures, with an optional suffix. |
| `utils/combination_generator.dart` | `generateCombination` and `generateCombinationSet`: seeded, deterministic combinations grown through `boxing_grammar.dart`, so every result passes `isValidCombination`. |
| `utils/cue_speech.dart` | `cueToSpeech`: turns cue notation (`1-2`, `3b`) into speakable text for the TTS engine. |
| `utils/milestones.dart` | `computeMilestones`: the eight badges in fixed order, achieved from `TrainingStats` and the stored reaction results. |
| `utils/date_helpers.dart` | `startOfDay`, `isSameDay`, `startOfWeek` (Monday 00:00) and `dayOfYear` (counted in UTC, feeds the daily quote and fact). |
| `utils/training_stats.dart` | `TrainingStats.fromSessions`: week rounds and minutes, streak days, totals, week rounds by type, minutes per day over the last seven days and the last session per type. |
| `utils/duration_format.dart` | `formatClock` (`3:05`) and `formatMinutes` (`20 min`). |
| `utils/practice_builder.dart` | `buildPracticeWorkout`: a shadow boxing drill that calls a list of combinations in order across its rounds, plus `practiceCueInterval` and `practiceCuesPerRound`. |
| `utils/session_launcher.dart` | `startSession`: starts a workout on `SessionProvider` with the stored stance and pushes `SessionPage`. |
| `utils/recommendation.dart` | `recommendWorkout`: today's session from `TrainingStats`, the least recently trained type at or nearest the boxer's difficulty. |
| `utils/external_links.dart` | `openExternal`: opens a url outside the app through `url_launcher` (`LaunchMode.externalApplication`) and reports whether the platform took it, false on a bad url or a platform failure; the top-level `launcher` is the seam tests swap. |

## Navigation

One `Navigator`, the `MaterialApp`'s. `home` is `OnboardingPage` until `onboarding_done` is set and
`AppShell` after that; finishing or skipping onboarding stores the flag and replaces the route with
the shell. `AppShell` keeps the five tabs alive (Home 0, Train 1, Skills 2, Corner 3,
Progress 4) in an `IndexedStack` indexed by `ShellProvider`, so tab state (the quick timer's numbers, scroll positions) survives switching and any page can send the
boxer to another tab: the empty Progress state switches to Train, the empty History state pops back
to the shell first. Settings can push `OnboardingPage` again through "Show onboarding again", and `AboutPage` from its
About card.
Everything else is pushed on the root navigator: `WorkoutDetailPage` as a normal route,
`SessionPage` as a `fullscreenDialog` route that `PopScope(canPop: false)` holds while the session is active, so a
system back press asks "End session?" instead of leaving the round running. The Skills hub pushes
`CombosPage`, `ReactionPage` and `FootworkPage` as normal routes. The Corner tab pushes
`LegendsPage`, `CalendarPage`, `QuotesPage`, `FactsPage` and `GymWallPage` from its cards
(`GymWallPage` pushes `PosterPage` for the poster tapped and `LiveWallpaperPage` from its Live wallpaper pill) and `LegendStoryPage`
for the legend of the week; `LegendsPage` pushes `LegendStoryPage` for the legend tapped; the combos practice drill starts a generated
`Workout` through the same `startSession` helper. `showComboSheet` is a modal bottom sheet that
pops with whether to practise, so the page it was opened from starts the session once the sheet
is gone. `ReactionPage` holds a running test with
`PopScope(canPop: false)`, but a system back cancels the test straight away instead of asking,
because nothing is stored yet. Home's gear pushes `SettingsPage`, its quick actions push `CombosPage` and `ReactionPage` or start
a quick timer through `startSession`, its legend of the week pushes `LegendStoryPage` with the "More in
Corner" link under it switching the shell to the Corner tab, and its last-session tile pushes `SessionDetailPage`.
An `EventCard` on Home or Corner, an `EventTile` on Corner and every `CalendarPage` row open
`showEventSheet`, a modal bottom sheet that pops with the entry's `Legend` when "Read the legend"
is pressed, so the page it was opened from pushes `LegendStoryPage` once the sheet is gone.
The Progress tab pushes `HistoryPage` from its card under the header, and
a history tile pushes `SessionDetailPage(id)`; deleting there pops back to the history before the
record leaves the provider, so the page never renders a session that is already gone. When the
engine reaches `SessionPhase.complete` the session page replaces itself with `SessionCompletePage`. That page takes the notes: it snapshots the record in
`initState`, and Save writes the rating and notes onto it through `HistoryProvider` before
resetting the engine and popping back to the shell. Save with nothing filled in is the skip; a
session with no completed round and under a minute of work offers Done instead and stores nothing.

## Persistence

`shared_preferences` keys. Training history uses the same store (decision D-01): two JSON lists
under their own keys, read and written by `HistoryStore`.

| Key | Type | Owner (static const) | Meaning |
|---|---|---|---|
| `stance` | String (enum name) | `SettingsProvider.stanceKey` | Lead side, default `orthodox`. |
| `difficulty` | String (enum name) | `SettingsProvider.difficultyKey` | Workout and drill level, default `beginner`. |
| `sound_enabled` | bool | `SettingsProvider.soundEnabledKey` | Bells and cue sounds, default true. |
| `haptics_enabled` | bool | `SettingsProvider.hapticsEnabledKey` | Vibration cues, default true. |
| `voice_enabled` | bool | `SettingsProvider.voiceEnabledKey` | Spoken cues, default true. |
| `keep_screen_on` | bool | `SettingsProvider.keepScreenOnKey` | Wake lock during a session, default true. |
| `fighter_name` | String | `SettingsProvider.fighterNameKey` | How Home greets the boxer, trimmed to 24 characters, default empty. |
| `onboarding_done` | bool | `SettingsProvider.onboardingDoneKey` | Whether the first-launch steps are finished, default false. |
| `session_records` | String (JSON list) | `HistoryStore.sessionsKey` | Every stored session, journal included. |
| `reaction_results` | String (JSON list) | `HistoryStore.reactionsKey` | Every finished reaction test. |
| `saved_combinations` | String (JSON list) | `CombosProvider.savedKey` | Bookmarked combinations, stored whole so a renamed library entry still shows what was saved. |
| `reminder_enabled` | bool | `SettingsProvider.reminderEnabledKey` | Daily training reminder, default false; only set once Android grants the permission. |
| `reminder_hour` | int | `SettingsProvider.reminderHourKey` | Hour the daily reminder fires, default 18. |
| `reminder_minute` | int | `SettingsProvider.reminderMinuteKey` | Minute the daily reminder fires, default 0. |
| `streak_nudge_enabled` | bool | `SettingsProvider.streakNudgeEnabledKey` | The 8 pm nudge on untrained days, default false; only set once Android grants the permission. |
| `event_reminders_enabled` | bool | `SettingsProvider.eventRemindersEnabledKey` | The 9 am note on boxing calendar days, default false; only set once Android grants the permission. |
| `wall_shuffle_all` | bool | `WallProvider.wallShuffleAllKey` | Whether the live wallpaper cycles every poster, default true. |
| `wall_shuffle_ids` | String list | `WallProvider.wallShuffleIdsKey` | The poster ids picked when it does not, default empty. |

Unknown or missing values fall back to the defaults above (`Stance.fromName` / `Difficulty.fromName`).
Read and write failures are caught and exposed on `SettingsProvider.error`; the in-memory value stands.

History schema. Each list holds one map per entry; null fields are omitted and missing fields fall
back on read, so an older record still loads.

- `SessionRecord`: `id`, `workout_id`, `workout_name`, `type`, `difficulty`, `stance`,
  `started_at` (ISO 8601), `duration_seconds`, `rounds_completed`, `rounds_planned`, `completed`,
  `rating`, `what_worked`, `what_needs_work`, `opponent`, `opponent_stance`.
- `ReactionResult`: `mode`, `format`, `completed_at` (ISO 8601), `reaction_millis` (list),
  `false_starts`, `misses`, `correct_holds`, `false_alarms`, `duration_seconds`. `format`,
  `correct_holds`, `false_alarms` and `duration_seconds` default when missing, so a result stored
  before the new modes existed still loads.

`HistoryProvider` keeps the in-memory lists as the truth for the session: a mutation updates them,
notifies, then persists, and a failed write only sets `error` ("Could not save history").

## Native bridge (`android/app/src/main/kotlin/com/prdy/boxer_os/`)

`MainActivity.kt` is a `FlutterActivity` with one `MethodChannel`, `boxer_os/wallpaper`. Any
further channel is named `boxer_os/<area>`, keeps `MainActivity` a thin dispatcher, and is listed
here as `method | args | returns`.

| method | args | returns |
|---|---|---|
| `setWallpaper` | `bytes` (PNG `Uint8List`), `target` (`home`, `lock` or `both`) | `true` once Android has taken the bitmap; a `PlatformException` with code `wallpaper_failed` otherwise |
| `saveRotation` | `bytes` (PNG `Uint8List`), `index`, `count` | `true` once the poster is stored as `filesDir/gym_wall/<index padded to 3>.jpg` (JPEG quality 90); `index` 0 first empties the folder and `index == count - 1` writes the rotation's size; `wallpaper_failed` otherwise |
| `openLiveWallpaperPicker` | none | `true` when Android's live wallpaper screen opened on `GymWallService` |
| `isLiveWallpaperActive` | none | `true` when the wallpaper in use is `GymWallService` |

The activity decodes the PNG with `BitmapFactory`, calls `WallpaperManager.setBitmap(bitmap, null,
true, flags)` with `FLAG_SYSTEM`, `FLAG_LOCK` or both on a background `Thread`, and posts the result
back on the main thread; `saveRotation` re-encodes on that same thread because 148 PNGs are too big
to keep as they are.

`GymWallService.kt` is the live wallpaper. Its `Engine` keeps the surface size from
`onSurfaceChanged` and, on `onVisibilityChanged(true)` (which Android fires on every screen-on),
steps `gym_wall_index` modulo `gym_wall_count`, decodes that JPEG with an `inSampleSize` matched to
the surface and draws it centre-cropped between `lockCanvas` and `unlockCanvasAndPost`; it redraws
without stepping on `onSurfaceChanged` and `onSurfaceRedrawNeeded`, and paints `#0A0A0B` when there
is no poster to show. Each draw logs its duration under the `GymWall` tag. Both the activity and the
service read the Kotlin `SharedPreferences` named `gym_wall` (`gym_wall_count`, `gym_wall_index`),
which is separate from the Flutter preferences.

Manifest (`android/app/src/main/AndroidManifest.xml`): label `Boxer OS`, MAIN/LAUNCHER intent
filter, the `GymWallService` service (exported, `BIND_WALLPAPER`, the
`android.service.wallpaper.WallpaperService` action and `@xml/gym_wall` metadata, whose description
string lives in `res/values/strings.xml`) and four `<queries>` intents: `PROCESS_TEXT` (the Flutter engine's text plugin),
`TTS_SERVICE` (so `flutter_tts` can bind a speech engine on Android 11+) and `VIEW` for the
`https` and `mailto` schemes (so `url_launcher` can resolve the About screen's links on Android 11+).

Permissions: `POST_NOTIFICATIONS` (the Android 13+ prompt, asked for from either Settings reminder
switch), `RECEIVE_BOOT_COMPLETED` (so scheduled reminders survive a reboot) and `SET_WALLPAPER` (the
Gym Wall, a normal permission that needs no prompt). Neither
`SCHEDULE_EXACT_ALARM` nor `USE_EXACT_ALARM` is declared: reminders schedule inexactly on purpose.
`flutter_local_notifications` merges in `VIBRATE` and its own copy of `POST_NOTIFICATIONS`. The cue
plugins need none: `wakelock_plus` sets the window's `FLAG_KEEP_SCREEN_ON`, `audioplayers` plays
local assets and `HapticFeedback` needs nothing. `FOREGROUND_SERVICE` remains a candidate for a
future background session. `flutter_tts` sets the effective `minSdk` to 24, which is already the
Flutter default.

Receivers: `com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver` shows a
scheduled reminder, and `ScheduledNotificationBootReceiver` (BOOT_COMPLETED, MY_PACKAGE_REPLACED
and the two QUICKBOOT actions) reschedules them after a reboot. Both `android:exported="false"`.

Resources: `res/values/colors.xml` defines `boxer_ink` (`#0A0A0B`); both `launch_background.xml`
drawables and the `LaunchTheme` / `NormalTheme` window backgrounds in `values/styles.xml` and
`values-night/styles.xml` use it, so the splash matches `AppTheme.ink` with no white flash. The
same file defines `ic_launcher_background` (`#0A0A0B`), the background layer of
`mipmap-anydpi-v26/ic_launcher.xml`; its foreground is `mipmap-<density>/ic_launcher_foreground.png`.
API 25 and below fall back to the legacy `mipmap-<density>/ic_launcher.png`. All of those PNGs are
copies of the sources in `assets/icon/`, which are not bundled into the app.

## Styling

`lib/theme/app_theme.dart` is the single source of colours, type and spacing; UI references
`AppTheme` tokens rather than literals (the Android `boxer_ink` colour is the one duplicate).

- Palette: `ink` `#0A0A0B`, `surface` `#141416`, `surfaceRaised` `#1C1C1F`, `line` `#2A2A2E`,
  `chalk` `#F4F2EE`, `chalkMuted` `#9A9A9F`, `chalkFaint` `#5C5C62`, `accent` `#FF3D2E`,
  `accentDeep` `#B8261C`, `rest` `#2ED3A5`, `warning` `#FFB020`, `onAccent` `#0A0A0B`. The accent
  is reserved for live state (work phase, primary CTA, active tab); `rest` marks rest and positive
  stats, `warning` the prepare phase and the 10-second warning.
- Spacing `spaceXs` 4 to `spaceXxl` 48 (page padding `spaceLg`), radii `radiusSm` 8 to
  `radiusPill` 999, sizes `minTapTarget` 48, `sessionTapTarget` 72, `hairline` 1.
- Type: BebasNeue for `displayHero` (168, the session countdown), `displayLarge` 64,
  `displayMedium` 40, `displaySmall` 28; Inter for `titleLarge`, `title`, `body`, `bodyStrong`,
  `bodyMuted`, `label` (uppercase eyebrows) and `caption`.
- `AppTheme.dark` is the app's `ThemeData` (Material 3, dark, `ink` scaffold) and themes the app
  bar, navigation bar, cards, chips, dividers, filled buttons, segmented buttons, switches, text
  fields and snack bars from those tokens.
- `AppTheme.appVersion` (`0.1.0`) is kept in step with `pubspec.yaml`.

Motion. `lib/theme/app_motion.dart` is the single source of durations and curves, as `AppTheme` is
of colour: `fast` 150 ms, `base` 250 ms, `slow` 400 ms, `flash` 320 ms, `stagger` 40 ms, with
`enter` (`easeOutCubic`) for arrivals and `change` (`easeInOut`) for state. Every animation goes
through `AppMotion.of(context, ...)`, which returns `Duration.zero` when the system asks for
reduced motion, or through `AppMotion.reduced` where the effect is skipped outright. Page sections
arrive in `SettleIn`, numbers run up in `CountUpText`, and the session screen carries the loud
moments: the clock beats through the last ten seconds and a phase change washes the screen in its
colour. One thing loops: the accent dot on an `EmptyState`. Because it never settles,
`tester.pumpAndSettle()` times out on any page showing an empty state; those tests pump a fixed
duration instead.

## Tests

`test/` mirrors `lib/`. Prefs are mocked with `SharedPreferences.setMockInitialValues`, channels with
`TestDefaultBinaryMessengerBinding`, timers with `FakeAsync` / `tester.pump`; widget tests pump
inside `MultiProvider` with the real providers.
