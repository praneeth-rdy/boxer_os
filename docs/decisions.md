# Decisions

Newest first. One entry per decision that a later reader might want to revisit.

## 2026-10-18 Three UI rules from the August device reviews, recorded late

Settled with the owner on 2026-08-29 and 2026-08-30 and previously held only in
`.claude/memory/`, now deleted: no text over photos (unreadable on the archive shots, so cards
put text below the image); buttons are design-system components (`SkillCard` rows, pills),
never an outlined pill with an icon or bare text; the Corner and All-legends icons are newspaper
and trophy, the book icon having been disliked.

## 2026-10-18 Anything that reads the time takes an injectable clock

`SessionProvider` and `ReactionProvider` already took `{DateTime Function()? clock}` defaulting
to `DateTime.now`; `NotificationService` read `tz.TZDateTime.now(tz.local)` directly and its
scheduling could only be tested by probing 23:59 and 00:00, with a flake window at the minute
boundary. It now takes the same seam and converts with `tz.TZDateTime.from(_clock(), tz.local)`.
The rule going forward: a class that reads the time exposes `clock`, named and shaped like the
providers', so its tests pin an instant instead of racing the wall clock. Pages that rotate
content by date (`quoteFor`, `legendOfTheWeek`) are tested with scoped finders for the same
reason, after `home_page_test.dart` failed on a week where two rotations met on one legend.

## 2026-10-18 Presentational widgets and enum-only models stay untested

`test/` mirrors `lib/`, but 15 files are deliberately left without a mirror: widgets that only
lay out their inputs (`section_header`, `stat_tile`, `empty_state`, `skill_card`, `session_tile`,
`event_card`, `event_tile`, `fact_card`, `filter_chip_row`, `journal_field`, `milestone_badge`,
`phone_preview`, `poster_renderer`, `rating_input`, `combo_sheet`) and models with no logic
beyond their constructor (`legend`, `wall_photo`, `milestone`, `quote`, `boxing_fact`,
`session_phase`, `app_theme`, `main`). A test there would restate the code. The rule: a test
covers logic (parsing, fallbacks, derived values, error containment, state-dependent rendering);
a file with none gets no file, and the page tests that compose these widgets cover them in use.

## 2026-08-30 Live wallpaper activation goes through the OEM screen, and that is fine

On Vivo (Android 16) the change-live-wallpaper intent is handled by the theme app: a preview
hosting our engine, an Apply button, then an "Apply to" sheet (lock, home, both). Stock
Android shows its own picker with the same choice. Verified on the owner's phone: after
applying to both, three wakes showed three different posters. The app therefore only
explains the two steps; it never tries to set the live wallpaper component itself (that API
needs a signature permission).

## 2026-08-30 Wallpaper rotation is a live wallpaper, not a background job

"A new poster every time the screen lights up" needs a screen-on signal, which Android only
delivers to a live wallpaper service (broadcast receivers cannot register for it from a dead
process, and a foreground service would cost battery and a permanent notification). Gym Wall
Live is therefore a `WallpaperService` that shows the next of a set of posters Flutter
pre-rendered to app storage as JPEGs. The boxer picks the set (everything or a selection) in
the app and activates the wallpaper once on the system screen.

## 2026-08-30 A legend's story quotes only that legend

Pull quotes inside a story must be the legend's own words (owner rule). Where the library had
none, one verified quote was added (Marciano, Jack Johnson, Katie Taylor) rather than
borrowing another athlete's line. Mentors' quotes (Cus D'Amato on Tyson's page) were removed.

## 2026-08-30 Photos are exported at up to 2000 px

Cards, story heroes and wallpapers all draw from the same assets, so the primaries are kept
at HD (long side up to 2000 px) and gallery photos at 1600 px, about 14 MB of assets in
total. Where Commons had a sharper clean portrait it replaced the first pick (Tyson,
Robinson, Mayweather, Taylor). Cards use 1:1 (list) and 4:3 (featured) crops with a
per-legend focal point.

## 2026-08-30 Gym Wall sets wallpapers through a MethodChannel

`boxer_os/wallpaper` in `MainActivity.kt` wraps `WallpaperManager` (home, lock or both);
posters are rendered by Flutter at the device resolution from the same theme and assets, so
no image files are shipped for the wallpapers themselves. No plugin dependency.

## 2026-08-30 Fifth tab: Corner

Legends and the calendar were first reachable from the Skills hub, which the owner rejected:
Skills is for drills. Content now has its own tab, "Corner" (after the corner ropes in the
logo): Legend of the week, all legends, today and upcoming boxing dates, the quote and fact
library. Home keeps small cards that deep-link into it. Tab order: Home, Train, Skills,
Corner, Progress.

## 2026-08-30 No text over photographs

Eyebrow and name over a photo were unreadable on bright shirts. Legend cards and the story
hero keep the photo clean and put the text on a solid block below it.

## 2026-08-30 License: PolyForm Noncommercial 1.0.0

The owner wants cloning and modification allowed, attribution required, commercial use
forbidden. PolyForm Noncommercial is written for source code and says exactly that; CC BY-NC
was rejected because Creative Commons advises against its licenses for software. Third-party
content keeps its own licenses (OFL fonts, Commons photos with per-image credits).

## 2026-08-30 Legend photos come from Wikimedia Commons with per-image credits

Twelve photos, each public domain, CC0, CC BY, CC BY-SA or OGL, fetched through the Commons
API with the license and author recorded, resized to 1000 px and bundled. Credits appear on
the story page and the About screen, which is what the attribution licenses require. No
photo without a recorded license goes into the app.

## 2026-08-30 Quotes and facts rotate per surface

One quote per day for every surface made the library feel static. Each surface (Home,
Progress, onboarding, reminder) has its own offset into a fixed shuffled order, so no two
surfaces show the same entry on the same day, and the cards can be tapped for the next one.
The library stays a fixed, verified list; workers may not add entries.

## 2026-08-30 Calendar is data first, page second

Boxing anniversaries and international days live as bundled data; Home shows a card only on
matching days, a page under Legends lists the year, and a settings switch sends a morning
notification. No custom events, no editing.

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
