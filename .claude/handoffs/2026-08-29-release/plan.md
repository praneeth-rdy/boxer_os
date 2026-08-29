# Run 4: Release polish (2026-08-29)

## Goal

Make the build shippable: release signing from `android/key.properties` with a debug fallback,
the launcher icon, a README with device screenshots, and the Play Console notes. The physical
device check (bells over gym noise, haptics through a glove, a phone call mid-round) stays a
human task and is listed for the product owner.

## Packages

| # | File | Title | Worker | Tests |
|---|---|---|---|---|
| 01 | `task-01.md` | Release signing and launcher icon | developer | no (smoke: debug and release APK build) |
| 02 | `task-02.md` | README and release notes | assistant | no |

Independent files; may run in parallel.

## Done means

- `flutter build apk --release` succeeds without `key.properties` (debug fallback) and the
  installed app shows the "B." icon and the label "Boxer OS".
- `README.md` has screenshots, install steps and the local-first promise; `docs/release.md`
  matches the Gradle code.
