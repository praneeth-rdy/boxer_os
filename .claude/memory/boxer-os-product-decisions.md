---
name: boxer-os-product-decisions
description: "Product owner's answers (2026-08-29) on Boxer OS look, audience, cue delivery and gamification, plus the four-run build plan"
metadata: 
  node_type: memory
  type: project
  originSessionId: d3e864f0-88dd-4ec8-90ea-a3644def066b
  modified: 2026-08-29T11:57:02.967Z
---

Settled with the user on 2026-08-29 before the first build:
- Look: "blackout + one hot accent" (near-black, off-white type, hot red for live state, mint for rest), Bebas Neue + Inter bundled as OFL assets.
- Audience: beginners, competitive amateurs AND pros together; difficulty picker everywhere, beginner path is the default.
- Cue delivery: on-device TTS (`flutter_tts`) speaks combination prompts; bells/beeps are synthesized WAVs in `assets/audio/`; haptics via `HapticFeedback`.
- Gamification: streak + milestone badges only, no XP/levels.
- Frontend-only, local-first; the user wants a modern, minimal, classy Gen Z-friendly "operating system for boxers".
- Build plan: run 1 core loop (`.claude/handoffs/2026-08-29-core-loop`), run 2 Skills, run 3 History/Home/Progress/Settings, run 4 polish/release.
- Physical device I2214 (Android 16, 1080x2400) is attached over USB for install and screenshot checks.

**Why:** these answers drive every handoff package; re-asking would waste the user's time.
**How to apply:** treat them as fixed; details are in `docs/product.md` "Answered questions" and `docs/decisions.md`. See [[boxer-os-project]] and [[tiered-workflow-and-git-rules]].
