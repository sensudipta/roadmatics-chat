<!-- SPDX-FileCopyrightText: 2026 Roadmatics Technologies -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Android build and signing

See [UPSTREAM_BASE.md](UPSTREAM_BASE.md) for the selected baseline/toolchain and
[BUILD_REPORT.md](BUILD_REPORT.md) for actual results. A command listed here is
not evidence that the build or device test has passed.

## Environment

Install the Flutter version in `.tool_versions.yaml`, Rust stable, Java 21, and
the SDK/NDK versions required by the Android dependencies. Do not upgrade the
Matrix SDK or the whole dependency lockfile as a branding step.

For the current Linux workspace:

```bash
export PATH=/data/DevCaches/roadmatics-chat/flutter/bin:/data/DevCaches/rust-short-drive/cargo/bin:$PATH
export PUB_CACHE=/data/DevCaches/pub
export CARGO_HOME=/data/DevCaches/rust-short-drive/cargo
export RUSTUP_HOME=/data/DevCaches/rust-short-drive/rustup
export ANDROID_HOME=/data/DevCaches/roadmatics-chat/android-sdk
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_USER_HOME=/data/Android/user
export GRADLE_USER_HOME=/data/DevCaches/gradle
```

These are machine-local paths, not requirements for other developers. Use your
own paths on another workstation. Gradle creates ignored `android/local.properties`.

## Firebase and upload key

Place the matching client JSON at `android/app/google-services.json`; see
[FIREBASE_SETUP.md](FIREBASE_SETUP.md). Keep the file ignored.

Copy `android/key.properties.example` to `android/key.properties` and supply the
existing upload key's absolute path and credentials locally. Never use a debug
key for a release. Never generate a new key just because a build cannot find it.

The initial key was generated outside this repository at:

`/data/Android/user/signing/roadmatics-chat/roadmatics-chat-upload.jks`

Its password is stored separately in the same protected directory as
`upload-password`. The directory is mode `0700`; both files are mode `0600`.
Do not display the password in logs, shell commands, screenshots, or chat.
Keep **at least two secure backups** of the key and password. This local folder
alone is not a backup. Review the Play signing-key decision before store rollout.

## Build

```bash
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
flutter build apk --release --split-per-abi
flutter build appbundle --release
```

Typical artifacts:

- `build/app/outputs/flutter-apk/app-debug.apk`
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (64-bit ARM phones)
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (32-bit ARM phones)
- `build/app/outputs/flutter-apk/app-x86_64-release.apk` (64-bit Intel devices)
- `build/app/outputs/bundle/release/app-release.aab`

For direct team distribution, prefer the APK matching the phone's architecture.
Each is a standalone installer with the same features and release signing key.
The universal `app-release.apk` includes multiple architectures and is much
larger. Check a connected phone with `adb shell getprop ro.product.cpu.abilist`.
Use the AAB for Play distribution, which generates device-specific downloads.
See [Flutter's Android release guide](https://docs.flutter.dev/deployment/android#build-an-apk).
Flutter applies ABI-specific version-code offsets to these APKs (the initial
ARM64 build is code `2001`). Future updates, including universal/Play builds,
must have a higher version code than the installed artifact.

Verify before distribution:

```bash
apksigner verify --verbose --print-certs build/app/outputs/flutter-apk/app-release.apk
jarsigner -verify build/app/outputs/bundle/release/app-release.aab
sha256sum build/app/outputs/flutter-apk/app-release.apk build/app/outputs/bundle/release/app-release.aab
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

`apksigner` is in the Android SDK's `build-tools/<version>/` directory. Debug and
release certificates differ: Android cannot replace one with the other using
`adb install -r`. Removing an installed debug app erases its local data; arrange
that explicitly before testing the release. Do not silently uninstall user data.

## Distribution gates

Pass the secret/licence audit and build checks before pushing public source.
Preserve upstream history and AGPL notices. Publish corresponding source with
every shared APK. Complete device login, messaging, attachments, search and push
checks before calling a release accepted. Follow [PUBLICATION_CHECKLIST.md](PUBLICATION_CHECKLIST.md)
for later Play and Apple work.
