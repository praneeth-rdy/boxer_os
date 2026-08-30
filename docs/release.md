# Release

How to build a signed Boxer OS for the Play Console.

Last verified against the code: 2026-08-29.

## Signing

Release builds use an upload key when `android/key.properties` exists and fall back to the debug
key otherwise, so a fresh checkout (or CI without secrets) still builds. Both the properties file
and any `.jks` / `.keystore` under `android/` are gitignored.

### 1. Create the upload keystore

Run from the repo root:

```
keytool -genkey -v -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Back the keystore and its passwords up somewhere off this machine.** Play signs every update
with the same upload key; losing it means you cannot ship an update to the existing listing.

### 2. Fill in `android/key.properties`

Copy `android/key.properties.example` to `android/key.properties` and fill it in:

```
storePassword=<store password>
keyPassword=<key password>
keyAlias=upload
storeFile=upload-keystore.jks
```

`storeFile` is resolved relative to `android/`, so the path above matches the keytool command.
An absolute path works too.

### 3. Build

```
flutter build apk --release        # build/app/outputs/flutter-apk/app-release.apk
flutter build appbundle --release  # build/app/outputs/bundle/release/app-release.aab
```

Upload the `.aab` to Play; the `.apk` is for sideloading and manual testing.

### 4. Verify the signature

```
$ANDROID_HOME/build-tools/<version>/apksigner verify --print-certs \
  build/app/outputs/flutter-apk/app-release.apk
```

The `Signer #1 certificate DN` line should name the upload key, not `CN=Android Debug`.
Use `apksigner`, not `keytool -printcert -jarfile`: the release APK carries only the v2/v3
signature blocks, so keytool reports "Not a signed jar file" even on a correctly signed build.

## Launcher icon

`android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` is the adaptive icon (API 26+):
`@mipmap/ic_launcher_foreground` over the `ic_launcher_background` colour in
`res/values/colors.xml`. Below API 26 the legacy `mipmap-<density>/ic_launcher.png` files are
used. All of them are copies of the sources in `assets/icon/`; regenerate those first, then copy
each `ic_launcher_<density>.png` and `ic_launcher_foreground_<density>.png` into the matching
`mipmap-<density>/` folder. `assets/icon/play_store_512.png` is the Play listing icon.

## Release checklist

- Bump `version:` in `pubspec.yaml` (`<name>+<build>`; the build number must increase for every
  Play upload) and keep `AppTheme.appVersion` in step with the name part.
- Run `flutter analyze` and `flutter test`; build the release APK and install it on a device.
- Run a full session on the device: bells, haptics, screen-off behaviour, a phone call mid-round.
- Play Console declarations:
  - Data safety: all training data stays on the device; nothing is collected or shared.
  - Permissions: list only what the manifest declares (wake lock, vibrate, and any foreground
    service or notification permission added for sessions) with a one-line reason each.
- Attach the release notes and a screenshot set taken on a device, not the emulator.

## Play Console notes

**Data safety.** Boxer OS collects nothing and shares nothing. There is no account, no backend,
no analytics SDK in the dependency tree; every workout, session record, rating and preference
stays in the app's local storage on the device. The Play Console data safety form can be filled
in as: no data collected, no data shared.

**Permissions.** Checked with `aapt dump permissions` against
`build/app/outputs/flutter-apk/app-debug.apk` (the current debug build), which reflects what the
plugin manifests merge in beyond `AndroidManifest.xml`:

| Permission | Reason |
|---|---|
| `POST_NOTIFICATIONS` | daily reminder and streak nudge, declared in `AndroidManifest.xml` |
| `RECEIVE_BOOT_COMPLETED` | reschedules reminders after the device restarts, declared in `AndroidManifest.xml` |
| `SET_WALLPAPER` | Gym Wall sets a poster as the home or lock screen wallpaper when the boxer asks, declared in `AndroidManifest.xml` |
| `VIBRATE` | round-change haptics, merged in from a plugin manifest |
| `INTERNET` | merged in from a plugin manifest; unused at runtime since the app makes no network calls |

`WAKE_LOCK` is not present in this build; the session screen keeps the device awake through
`wakelock_plus`, and if a later version of that plugin declares the permission, re-run the
`aapt` command above before shipping.

**Target audience.** 18+ fitness. The app targets boxers training on their own, not children;
set the Play Console target audience and content rating accordingly.

**Screenshots.** Raw device captures live under `docs/screenshots/`; the framed Play listing
set (phone screenshots, feature graphic, icon) is generated from them, see "Store listing
assets" below.

## Upload key on record (created 2026-08-29)

The one key every Play update must be signed with. Password and keystore are NOT in git.

| Item | Value |
|---|---|
| Keystore | `android/upload-keystore.jks` (PKCS12, gitignored, mode 600) |
| Properties | `android/key.properties` (gitignored, mode 600); `storePassword` and `keyPassword` are identical |
| Alias | `upload` |
| Owner | `CN=Boxer OS, OU=Mobile, O=prdy, C=IN` |
| Algorithm | RSA 2048, SHA256withRSA |
| Valid | 2026-08-29 to 2054-01-14 |
| Certificate SHA-256 | `C7:A5:08:DE:33:79:C0:28:34:91:B4:0B:81:43:24:8C:38:31:4D:84:1F:35:B5:32:1E:80:0C:88:14:6E:9D:27` |
| First signed build | 0.1.0+1, `app-release.aab` 44.7 MB, `app-release.apk` 54.0 MB |

Play Console uses this fingerprint to identify the upload key (App integrity > App signing >
Upload key certificate). With Play App Signing, Google holds the app signing key and only this
upload key needs to stay safe; if it is ever lost, request an upload key reset from the Console
before it is needed rather than after.

Backups: keep the `.jks` and the password in at least two places off this machine (password
manager plus an encrypted drive). Never convert the keystore between JKS and PKCS12 or
regenerate it: the fingerprint would change and Play would reject the update.

Quick checks:

```
keytool -list -v -keystore android/upload-keystore.jks -alias upload   # prompts for the password
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk | grep -E "DN|SHA-256"
```

## Store listing assets

`python3 tool/store_assets.py <captures folder>` turns raw 1080x2400 device captures (named
`home.png`, `session.png`, `train.png`, `combos.png`, `reaction.png`, `progress.png`,
`journal.png`, `reminders.png`) into the Play listing set under `screenshots/` (gitignored):
framed 1080x1920 phone screenshots with a headline each, a hero frame with two phones, the
1024x500 feature graphic, and the 512 px icon. Play accepts PNG up to 3840 px with the long
side at most twice the short side, which is why the raw captures are framed rather than
uploaded as they are. Needs Python 3 with Pillow.
