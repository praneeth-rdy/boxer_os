# Release

How to build a signed Boxer OS for the Play Console.

Last verified against the code: 2026-08-29. **Not yet wired:** `android/app/build.gradle.kts`
still signs release builds with the debug key. Backlog B-04 adds the `key.properties` flow below;
until then treat this file as the target setup.

## Signing (target, B-04)

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

Copy `android/key.properties.example` (added by B-04) to `android/key.properties` and fill it in:

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
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

The owner line should name the upload key, not `CN=Android Debug`.

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
