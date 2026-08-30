# Task 07 - License, privacy policy, About screen

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** task-06
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
The legal layer: the repository is under the PolyForm Noncommercial License 1.0.0 (file
already at `LICENSE`), the app has an About screen with developer, brand, logo, version,
copyright, license, privacy policy link, source link and credits, and external links open in
the browser.

## Context the worker needs
- `LICENSE` exists (Architect). `docs/privacy-policy.md` exists (Architect). README gets its
  License section from you (the only README edit allowed in this task).
- `url_launcher` `^6.3.2` (Flutter >= 3.27). Android 11+ needs a `<queries>` intent for
  `android.intent.action.VIEW` with `https` data scheme; verify against the plugin README.
- Identity: developer "Praneeth Reddy", brand "prdy", copyright "Copyright 2026 Praneeth
  Reddy", source `https://github.com/praneeth-rdy/boxer_os`, privacy policy
  `https://github.com/praneeth-rdy/boxer_os/blob/main/docs/privacy-policy.md`, license page
  `https://polyformproject.org/licenses/noncommercial/1.0.0`, contact `team.edyma@gmail.com`.
  Keep them in one place: `lib/data/app_identity.dart` as `AppIdentity` `static const`s.
- Logo: add `assets/icon/ic_launcher_1024.png` to `pubspec.yaml` assets (declare the single
  file, not the folder) for the About screen and the Home wordmark row.
- `lib/utils/external_links.dart` was stubbed in task-04; implement it here.

## Files
- `pubspec.yaml` - modify - `url_launcher`, the icon asset.
- `android/app/src/main/AndroidManifest.xml` - modify - `<queries>` intent for https.
- `lib/data/app_identity.dart` - create.
- `lib/utils/external_links.dart` - modify - `openExternal` via `launchUrl(mode: LaunchMode.externalApplication)`, false on failure.
- `lib/pages/about_page.dart` - create.
- `lib/pages/settings_page.dart` - modify - ABOUT section becomes a `SkillCard`-style row that pushes `AboutPage`.
- `README.md` - modify - License section only.
- `docs/architecture.md` - modify - rows, manifest queries, dependency.

## Spec

### `AboutPage`
Transparent app bar (back). `ListView` padded `spaceLg`, `SettleIn` blocks:
1. Logo (`Image.asset`, 96 dp, `radiusLg` clip) beside "BOXER OS" in `displayLarge` with the
   tagline eyebrow under it; "Version {AppTheme.appVersion}" in `caption`.
2. "MADE BY" eyebrow: "Praneeth Reddy" in `title`, "prdy" in `bodyMuted`, then "Copyright 2026
   Praneeth Reddy. All rights reserved for commercial use." in `caption`.
3. "LICENSE" eyebrow: "PolyForm Noncommercial 1.0.0" in `body`, and a `bodyMuted` paragraph:
   "You may copy, change and share Boxer OS for any noncommercial purpose as long as you keep
   the license notice and credit the author. Commercial use needs written permission." Two
   link rows (see below): "Read the license", "Source code on GitHub".
4. "PRIVACY" eyebrow: `bodyMuted` "Boxer OS keeps everything on your phone. No account, no
   analytics, nothing sent anywhere." Link row "Privacy policy". Link row "Contact"
   (`mailto:team.edyma@gmail.com`).
5. "CREDITS" eyebrow: "Bebas Neue and Inter, SIL Open Font License." then one `caption` line
   per legend photo from `legends` (`{legend.name}: {credit.author}, {credit.license}`), each
   tappable to its source.
Link row: a `surface` card row with an `Icons.open_in_new_rounded` at the end, `minTapTarget`
tall, calling `openExternal(url)`; on `false` show a `SnackBar` "Could not open the link."

### Settings
The ABOUT section's two text lines are replaced by a `SkillCard(title: 'About Boxer OS',
description: 'Version {appVersion}, license, privacy, credits', icon: Icons.info_outline_rounded)`
pushing `AboutPage`.

### README License section
"## License" at the end: "Boxer OS is released under the PolyForm Noncommercial License 1.0.0
(see `LICENSE`). You can use, copy, modify and share it for noncommercial purposes provided
the license notice and attribution to Praneeth Reddy stay with the code. Commercial use
requires written permission from the author. Third-party content: fonts under the SIL OFL;
legend photographs from Wikimedia Commons under their listed licenses (see the About screen)."

## Acceptance criteria
- [ ] About page renders every section; link rows call `openExternal` with the identity URLs
      (fake through a testable seam: `openExternal` reads a top-level `launcher` function that
      tests can swap, or the page takes an optional `Future<bool> Function(String)` parameter).
- [ ] Settings About card opens the page.
- [ ] `flutter build apk --debug` succeeds with `url_launcher`; tapping "Privacy policy" on
      the device opens the browser (assistant device check).
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/pages/about_page_test.dart`, extend `settings_page_test.dart`.
