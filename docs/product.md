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

Secondary: fighter profile, journal / history, settings, workout library.

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
| Home | **today's workout, quick start, streak, weekly snapshot** | recommendations from weak-skill history, XP and levels |
| Training | **configurable round timer, guided workouts from a bundled library, custom session builder, bells, haptics, 10 s and final-30 s cues** | voice coaching, pace changes mid-round, wearables |
| Skills | **combination generator (stance, difficulty), basic reaction trainer, footwork drills** | defense drills, combination memory, video technique analysis |
| Progress | **rounds, training minutes, streak, session history, basic skill progression** | reaction-time trends, personal records, richer analytics |
| Journal | **post-session rating, notes, sparring notes** | opponent profiles, recurring-weakness detection |
| Profile / settings | **stance, level, sound and haptic preferences** | fighter profile, weight and recovery tracking |
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

## Open questions (from the concept, decide before or during the first builds)

1. Which segment does V1 target first: beginners, recreational boxers, competitive amateurs, or coaches?
2. Should the primary in-training interaction be visual, audio, haptic, or a combination? (Working
   assumption: audio and haptic carry every cue; the screen is the fallback.)
3. What minimum workout library makes the app useful on day one?
4. Which metrics are actionable rather than vanity metrics?
5. How should recommendations be generated from local training history?
6. Which native capabilities are required: background audio, wake lock, haptics, local notifications?
7. What is configurable by the boxer versus fixed by the workout designer?
8. Which features are deliberately excluded from V1 to preserve focus?

Suggested first exercise: map one scenario end to end, "a boxer opens Boxer OS at the gym at
6:00 AM and wants to complete a 45-minute session without repeatedly looking at the phone",
identify the smallest lovable V1, and prototype the training screen first.
