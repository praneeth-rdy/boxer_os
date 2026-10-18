---
name: boxer-os-run5-decisions
description: "User's second-round asks and picks (2026-08-29 evening): logo E \"one-two\", Combos 2.0, reminders, motion pass, onboarding/empty states, forced US TTS voice, louder bells"
metadata: 
  node_type: memory
  type: project
  originSessionId: d3e864f0-88dd-4ec8-90ea-a3644def066b
  modified: 2026-08-29T14:41:36.655Z
---

After seeing the run 1 and 2 builds on the device the user asked for, and picked:
- Logo: FINAL pick is C "corner ropes" (red post, three chalk ropes); the user first chose E (one-two), then switched. Review sheet artifact 9f3ec483. Icon PNGs regenerated in `assets/icon/`.
- Bells too quiet: WAVs renormalised to 0.95 peak; audio stream must move from `assistanceSonification` (ring/system on their phone) to `media`.
- "Jab" mispronounced: phone locale is en-IN; fix by forcing a local en-US voice, a pronunciation table, and a "Test voice" button in Settings. Bundled clips rejected for now.
- Combos 2.0: curated 60+ named combination library, boxing-grammar generator (what follows what), bookmarks, practice from saved combos. The user questioned generator output like `3-1` and `6-1b`.
- Reminders: local notifications, daily at a chosen time (default 18:00) plus a 20:00 streak-at-risk nudge.
- Motion pass: micro-animations where they carry meaning; animated, well-worded empty states because Home and Progress looked empty at first launch.
- Onboarding: first-launch welcome (name, stance, level).
- The user wants to be presented with options when there are many ways to enhance the experience.

**Why:** these are explicit product-owner decisions that shape run 5 and beyond.
**How to apply:** treat as fixed; packages live in `.claude/handoffs/2026-08-29-experience/`. See [[boxer-os-product-decisions]].
- Later the same evening: Progress "Journal" text must look like a button (R3-05). Move-animation options were shown in artifact b6efdebc (tactical board recommended; user has not picked yet). Reaction drills picked for run 6: Defense reaction, Go/No-go, Endurance 60 (rejected for now: combination memory, ears-only, two-player, rhythm, custom presets).
- Move animations: DROPPED by the user on 2026-08-29 after four demo attempts (artifact b6efdebc). Do not propose code-drawn figures again; if revisited, it is designer Lottie/Rive clips only.
- Terminology: the user finds "Journal" jargon; the feature is called "History" in the UI, README and docs (code: `HistoryPage`); "Sessions" was considered and rejected. Buttons must be design-system components (SkillCard rows, pills), never outlined-pill-with-icon or bare text.
- 2026-08-30: Legends must NOT live under Skills. Fifth tab "Corner" (stories, calendar, quotes/facts library) chosen over Home-only or Progress. No text over photos (unreadable); calendar rows open a detail sheet with "Read the legend".
- 2026-08-30 later: legend stories may quote only the legend (no mentors, no other athletes). Photos must be HD (user: "clear & HD"); cards were clipping Ali/Frazier/Mayweather (fixed with 1:1 cards + focal points). Corner/All-legends book icon disliked (newspaper + trophy icons instead). New feature "Gym Wall": wallpapers (home/lock) via MethodChannel boxer_os/wallpaper; user asked whether possible, answer yes.
- 2026-08-30 late: Gym Wall extended with Moments (archive photos) and Inspiration (14 new Commons photos in assets/wall) posters, and "Gym Wall Live" auto-shuffle on screen-on via a native WallpaperService (user wants pick-a-few or shuffle-all). Tasks 13 and 14.
- Naming: the screen-on rotation feature is called "Live wallpaper" in the UI (Android's own term); "auto-shuffle" was the user's placeholder. Provider stays WallProvider with wall_shuffle_* keys.
