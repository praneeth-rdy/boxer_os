# Task 01 - Release signing and launcher icon

- **Run:** `.claude/handoffs/2026-08-29-release/`
- **Depends on:** none
- **Worker:** developer (Opus)
- **Tests:** no (verify with builds)

## Goal
Release builds sign with an upload key when `android/key.properties` exists and fall back to
the debug key otherwise, so CI and fresh checkouts still build. The app gets its launcher icon
(adaptive on API 26+, legacy PNGs below) from the images already generated in `assets/icon/`.

## Context the worker needs
- `docs/release.md` describes the target flow (key.properties fields: `storePassword`,
  `keyPassword`, `keyAlias`, `storeFile` relative to `android/`). Make the code match it.
- `android/app/build.gradle.kts` is Kotlin DSL; `.gitignore` already ignores `key.properties`,
  `*.jks`, `*.keystore` at both levels.
- Icon sources in `assets/icon/`: `ic_launcher_{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}.png` (48 to
  192 px legacy), `ic_launcher_foreground_{density}.png` (108 dp adaptive foreground with a
  transparent background, 108 to 432 px), `ic_launcher_background_1024.png` (solid `#0A0A0B`),
  `play_store_512.png`. These are source images; copy, do not reference from `assets/`.

## Files
- `android/app/build.gradle.kts` - modify - `signingConfigs.release` loaded from
  `key.properties`, `release` build type uses it when present.
- `android/key.properties.example` - create.
- `android/app/src/main/res/mipmap-*/ic_launcher.png` - replace with the legacy PNGs.
- `android/app/src/main/res/mipmap-*/ic_launcher_foreground.png` - create from the foreground PNGs.
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` - create - adaptive icon.
- `android/app/src/main/res/values/colors.xml` - modify - add `ic_launcher_background` = `#0A0A0B`.
- `docs/release.md` - modify - drop the "Not yet wired" banner; verify each step against the code.
- `docs/architecture.md` - modify - the signing sentence under Stack.

## Spec

### Signing (`build.gradle.kts`)
At the top of the `android {}` block (or above it), load the properties:
```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKey = keystorePropertiesFile.exists()
if (hasReleaseKey) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```
Then:
```kotlin
signingConfigs {
    if (hasReleaseKey) {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
}
buildTypes {
    release {
        signingConfig = if (hasReleaseKey) signingConfigs.getByName("release")
                        else signingConfigs.getByName("debug")
    }
}
```
`rootProject` in the app module is the `android/` project, so `key.properties` and
`storeFile` resolve relative to `android/` as `docs/release.md` says. Remove the two scaffold
`TODO` comments in `defaultConfig` and `buildTypes`; keep everything else.
`android/key.properties.example`:
```
storePassword=
keyPassword=
keyAlias=upload
storeFile=upload-keystore.jks
```

### Icon
Copy each `assets/icon/ic_launcher_<density>.png` over the matching
`mipmap-<density>/ic_launcher.png` and each `ic_launcher_foreground_<density>.png` to
`mipmap-<density>/ic_launcher_foreground.png`. Create
`mipmap-anydpi-v26/ic_launcher.xml`:
```xml
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
```
The manifest already points at `@mipmap/ic_launcher`; no change there.

### Verification you run
`flutter build apk --debug` and `flutter build apk --release` (no `key.properties` present:
must succeed with the debug fallback). Then, with a throwaway keystore you create in the
scratchpad directory (`keytool -genkey ... -storepass test1234 -keypass test1234 -alias upload
-dname "CN=test"`) and a temporary `android/key.properties` pointing at it by absolute path,
`flutter build apk --release` must succeed and `keytool -printcert -jarfile
build/app/outputs/flutter-apk/app-release.apk` must show `CN=test`. Delete the temporary
`key.properties` afterwards and confirm `git status` shows no keystore or properties file.
Install the debug APK on the attached device (`adb install -r`) and confirm the icon.
If Gradle reports "Cannot lock file hash cache", run `cd android && ./gradlew --stop` and retry.

## Out of scope
- Play Console upload, app bundles beyond confirming `flutter build appbundle --release` is
  not broken (do not run it; it needs nothing new).
- Any Dart change.

## Acceptance criteria
- [ ] Release build without `key.properties` signs with the debug key; with one it signs with
      the upload key (verified with the throwaway keystore, then removed).
- [ ] `key.properties.example` exists and `git status` shows no secrets.
- [ ] Adaptive icon on the device shows the "B." mark on the ink background; legacy PNGs replaced.
- [ ] `docs/release.md` matches the code, no "target" caveats left.
- [ ] `flutter analyze` 0 issues (unchanged).
