# Boxer OS

Train. Fight. Improve. Repeat.

A local-first boxing training companion for Android, built with Flutter. Plan a session, run it
with round timers, bells and haptics, drill combinations and reactions, and track rounds,
minutes, streaks and a sparring journal. No account, no backend: everything stays on the phone.

- Product and V1 scope: `docs/product.md`
- How the code is put together: `docs/architecture.md`
- Plan and open decisions: `docs/backlog.md`
- Working conventions and the tiered agent workflow: `.claude/CLAUDE.md`

## Build

```
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Flutter 3.41.2 stable. See `docs/release.md` for signed builds.
