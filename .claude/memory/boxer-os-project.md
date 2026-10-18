---
name: boxer-os-project
description: Boxer OS state as of 2026-08-29 night: runs 1 to 6 built and reviewed, release run in flight, what is left
metadata:
  type: project
---

Boxer OS (Flutter, Android-only, local-first boxing companion) went from scaffold to a full V1 on 2026-08-29 through six tiered-workflow runs (handoffs under `.claude/handoffs/2026-08-29-*`): core loop, skills, memory, experience (audio/voice, combos 2.0, onboarding/quotes/facts, reminders, motion), reaction drills. 434+ tests, analyze clean, verified on the owner's I2214 phone with screenshot walkthroughs. `docs/backlog.md`, `docs/review-log.md` and `docs/decisions.md` are current.

Remaining: run 7 "release" (`.claude/handoffs/2026-08-29-release`): task-01 signing + corner-ropes icon, task-02 README with device screenshots and Play Console notes. R-03 (bells over gym noise, haptics through a glove, phone call mid-round) is the owner's physical check. The owner has not confirmed the "jab" pronunciation after the en-US voice fix.

**Why:** a new session should not re-plan V1 or re-open dropped ideas (move animations).
**How to apply:** read `docs/backlog.md` first; continue from the release run. See [[boxer-os-product-decisions]], [[boxer-os-run5-decisions]], [[tiered-workflow-and-git-rules]].

Update 2026-08-29 late: the user asked for commits; V1 is committed on `main` as three commits (build assets/android, feat app, docs). Version deliberately stays 0.1.0+1 (a bump to 1.0.0 was cancelled). Release APK is debug-signed (no key.properties yet) and copied to the phone as /sdcard/Download/boxer-os-v0.1.0.apk. Play Store framed assets: `screenshots/` (gitignored), regenerated with `tool/store_assets.py`.
Upload keystore created 2026-08-29 at android/upload-keystore.jks with android/key.properties (both gitignored, chmod 600); alias `upload`, CN=Boxer OS, valid to 2054. Password is only in key.properties and was shown to the user once to back up; never print it again. Release builds now sign with it.
Upload key facts (non-secret) are recorded in `docs/release.md` "Upload key on record": alias upload, CN=Boxer OS, PKCS12, SHA-256 C7:A5:08:DE:...:6E:9D:27, valid to 2054. First signed build 0.1.0+1 (aab 44.7 MB, apk 54.0 MB). The user asked that these be noted; the password stays only in android/key.properties.

Run 8 "content" (2026-08-30, `.claude/handoffs/2026-08-30-content`): quotes/facts 2.0 with per-surface rotation, History icon + combo copy + 10 footwork drills, Legends (12 stories, Commons photos in assets/legends, credits), boxing calendar (39 dates, page, Home card, reminder id 3), 4 new reaction drills (peripheral, colour, sequence, sound), PolyForm NC license + docs/privacy-policy.md + About screen (Praneeth Reddy, brand prdy, url_launcher). Launched via the tiered workflow; review pending.
Run 8 reviewed 2026-08-30: all seven packages plus task-08 (Corner tab) landed, 564+ tests green. Pending when the phone is reconnected: device captures of Corner, About, the privacy link opening the browser, plus a final logcat check; then the user commits. Uncommitted at this point: everything from run 8, LICENSE, docs/privacy-policy.md, assets/legends.
Run 8 committed 2026-08-30 as three commits (8f5177a build, ec9b303 feat, ca6e58a docs); tree clean. Store assets regenerated (8 frames incl. Corner and a Legend story). Next for the user: push the repo public (About links point at github.com/praneeth-rdy/boxer_os), build the signed bundle, upload.
2026-08-30 later: tasks 09 to 12 landed (HD photos + galleries, Gym Wall wallpapers via MethodChannel, credit cleanup, full-bleed strip); 623+ tests. UNCOMMITTED. Pending: device walkthrough of galleries and Gym Wall (lock/home wallpaper check), refresh docs/screenshots and store frames (Corner tab icon changed), then the user commits. User disconnects the phone intermittently; resume device work only when told it is reconnected.
2026-08-30 evening: tasks 09 to 12 device-verified (Gym Wall lock screen works; the user's phone has a text-only launcher so home wallpaper cannot be seen). Screenshots and store frames refreshed. Awaiting the user's commit of this batch.
2026-08-30 night: tasks 13 and 14 (Moments/Inspiration posters, Gym Wall Live via GymWallService) landed, 673 tests. Device check of the live wallpaper running; then the user commits tasks 09 to 14 together.
2026-08-30 22:15: Live wallpaper VERIFIED on the Vivo phone (apply to both on Vivo's "Apply to" sheet; three wakes, three posters). Task-16 (copy + status refresh) in progress; then the user commits tasks 09 to 16.
Tasks 09 to 16 all landed and reviewed (674 tests); final device capture running; then the user commits. Store frame 07 is now Gym Wall (story frame dropped).
2026-08-30 22:30: tasks 09 to 16 committed as f4926d3 (build), 9819f8d (feat), 4f14b9a (docs); tree clean. Next for the user: push, signed bundle, Play upload, gym check (R-03).
