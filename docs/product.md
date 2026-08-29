# Product

Last updated 2026-08-29. This is the "why" behind the backlog; `architecture.md` is the "how".
Source: the Boxer OS product concept document (2026-08-29), condensed here so nobody needs the
original.

## One line

Boxer OS is a one-stop mobile companion for boxers: your entire boxing journey, in one place.
Rather than a collection of disconnected timers and trackers, it is a lightweight personal
boxing training system that works before, during, after and between sessions.

Tagline: "Train. Fight. Improve. Repeat."

## Product principle

Before training: **plan**. During training: **coach**. After training: **analyze**. Between
sessions: **improve**.

## Who

Boxers who train on their own or between coached sessions: shadow boxing at home, bag work at
the gym, sparring days. The first target segment (beginners, recreational boxers, competitive
amateurs, or coaches) is an open question, see "Open questions" below; the V1 build keeps the
beginner path simple and lets advanced boxers customise sessions.

## Principles

1. **Training first.** Every feature ultimately helps the boxer train or improve.
2. **Low-friction.** During training the boxer should rarely need to touch the phone.
3. **Gym-friendly.** Large controls, high contrast, strong audio and haptic cues, simple screens.
4. **Local-first.** The core experience works offline and protects the continuity of training
   history. No account, no backend, no cloud database in V1.
5. **Progressive complexity.** Beginners get simple workflows; advanced boxers can customise.
6. **Connected experience.** Training, skills, journal and analytics feed one another.

## Core loop

1. **Plan.** Home recommends today's session (for example "Footwork + Combination Session, 20 min")
   or the boxer picks or builds one: training type, duration, rounds, goals.
2. **Train.** The boxer selects difficulty and stance and starts. The app runs the rounds with
   bells, haptics, warnings and visual feedback, and delivers prompts such as "1-2, slip, pivot,
   exit" without the phone in hand.
3. **Finish.** The boxer rates the session and records one or two observations.
4. **Analyze.** Progress updates rounds, minutes, streak and skill activity.
5. **Next session.** The app surfaces neglected or repeatedly weak skills from local history.

## Information architecture

Primary navigation (four tabs):

| Tab | Holds |
|---|---|
| Home | today's session, quick actions, streak, weekly snapshot |
| Train | guided workouts, round timer, custom sessions |
| Skills | combinations, reaction, defense, footwork drills |
| Progress | training analytics, skill progression, records |

Secondary: fighter profile, history (the session log, called "Journal" in the concept), settings, workout library.

## Modules

| Module | Contents |
|---|---|
| Home / command center | today's recommended workout, start-session CTA, weekly rounds and minutes, training streak, quick access to Timer, Combos and Reaction Trainer |
| Training engine | shadow boxing, heavy bag, speed bag, mitt work, sparring, footwork, conditioning, strength, custom workout; round/rest configuration; 10-second warnings and final-30-second cues; bell sounds and haptics |
| Boxing coach / guided sessions | round-by-round instructions, combination prompts, defense and movement cues, intensity/pace changes, hands-free and phone-down-friendly interaction |
| Skills lab | punch combinations, defense drills, footwork drills, combination generator, beginner/intermediate/advanced difficulty, orthodox/southpaw support |
| Reaction trainer | direction/reaction tests, punch and defense stimuli, combination memory, reaction-time scoring, progress over repeated sessions |
| Fighter dashboard | training minutes, rounds per week, sparring rounds, bag/shadow rounds, session intensity, streaks, reaction-time trends, skill-level visualisation, personal records |
| Training and sparring journal | session rating, what worked, what needs work, opponent/stance notes, recurring weaknesses, historical session review |
| Progression / gamification | fighter XP, levels, achievements, milestones, training streaks, round-count and reaction-time milestones |

## V1 scope (in bold: ships in V1)

| Area | V1 | Later |
|---|---|---|
| Home | **today's workout (least-recently-trained type), quick actions, streak, weekly snapshot, quote and fact of the day, onboarding on first launch** | recommendations from weak-skill history, XP and levels |
| Training | **configurable round timer, guided workouts from a bundled library, custom session builder, bells, haptics, 10 s and final-30 s cues** | voice coaching, pace changes mid-round, wearables |
| Skills | **60-combination library with a boxing-grammar generator, bookmarks and practice sessions; reaction trainer (Tap, Direction, Defense, Go / No-go; Endurance 60 format); footwork drills** | combination memory, ears-only and two-player reaction, move animations (designer clips), video technique analysis |
| Progress | **rounds and minutes this week, streak, 7-day chart, split by type, reaction bests per mode and endurance decay, milestone badges, journal** | personal records, richer analytics |
| History (journal) | **post-session rating, what worked, what needs work, sparring opponent notes; session list and detail** | opponent profiles, recurring-weakness detection |
| Profile / settings | **name, stance, level, sound / haptics / voice / keep-screen-on, voice test, daily reminder and streak nudge, clear history** | weight and recovery tracking |
| Platform | **offline, local-first, no account** | cloud sync, coach/club workflows |

## Roadmap ideas (not planned)

- V2: voice coaching, richer analytics, fight-camp planner, weight and recovery tracking, nutrition.
- V3: AI coach, video-based technique analysis, opponent analysis, personalised training plans.
- Ecosystem: wearables, heart-rate data, coach/club workflows, cloud sync, athlete profiles.

## Technical constraints (from the concept, to be verified as each lands)

- Everything local: workout definitions bundled as Dart data or JSON; combination generation is a
  deterministic or seeded-random local algorithm; training history in a local store; preferences in
  local storage; analytics computed on-device; charts rendered from local session data.
- Audio: bundled bell and cue sounds. They must play while the screen is off or the app is in the
  background during a session, which on Android means a foreground service or keeping the screen
  on with a wake lock; the choice is backlog decision D-03.
- Haptics: Flutter `HapticFeedback` first; a native vibration pattern only if the built-in patterns
  are too weak to feel through a glove.
- Notifications: local only, no push.
- Android-first. The repository is Android-only today; nothing in the design should preclude iOS.

## Answered questions (2026-08-29, with the product owner)

The concept document's eight questions, settled before the first build:

1. **Segment.** All three at once: beginners, competitive amateurs and pros. The library ships
   beginner, intermediate and advanced workouts side by side; drills carry a difficulty picker;
   the beginner path stays the default.
2. **In-training interaction.** Audio and haptics carry every cue, the screen is a huge glanceable
   fallback. Combination prompts are spoken with the phone's on-device text-to-speech engine
   (`flutter_tts`, offline), bells and beeps are bundled WAVs, haptics use `HapticFeedback`.
3. **Minimum library.** Twelve bundled workouts: at least one per training type plus signature
   guided sessions with per-round cues, and a configurable quick timer.
4. **Actionable metrics.** Rounds and minutes per week, streak, split by type (shadow / bag /
   sparring), reaction-time best and average. No calories, no invented scores.
5. **Recommendations.** A local rule: least-recently-trained type, or yesterday's workout when the
   streak is at risk. No ML.
6. **Native capabilities.** Wake lock (screen stays on for the whole session), haptics, bundled
   audio, on-device TTS. No foreground service, no notifications in V1: with the screen on,
   nothing needs to survive screen-off.
7. **Configurable vs fixed.** The boxer sets rounds, work, rest, warnings, stance and difficulty.
   The workout designer fixes cue content and order.
8. **Excluded from V1.** Voice coaching beyond spoken cues, XP and levels, defense drills,
   combination memory, video, wearables, sync. Gamification is limited to the streak and a small
   set of milestone badges.

## Look and feel

"Blackout with one hot accent": near-black surfaces, off-white type, a single hot red accent used
only for live state (active round, primary CTA), a mint secondary for rest and positive stats.
Bebas Neue for the big numbers and headings, Inter for everything else. Modern, minimal, classy;
built to attract Gen Z boxers without shouting. Tokens live in `lib/theme/app_theme.dart`.
