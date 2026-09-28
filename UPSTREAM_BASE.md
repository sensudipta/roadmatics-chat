<!-- SPDX-FileCopyrightText: 2026 Roadmatics Technologies -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Upstream base

Project: FluffyChat  
Repository: https://github.com/krille-chan/fluffychat  
Stable tag: `v2.9.1`  
Commit: `f7bded3e049c0077b3ade8d02cae6d06e5d5756f`  
Selected tag commit date: 2026-08-17  
Fork initialized: 2026-09-29 (Asia/Kolkata)  
Upstream application version: `2.9.1+3560`

The latest stable release resolved from GitHub was v2.9.5. It failed the
untouched Android build because its explicit compileSdk 37 cannot be resolved
with the currently available SDK 37.0 and pinned AGP 8.11.1. v2.9.4 shares that
change. The preceding stable tag v2.9.1 was verified from Git and built successfully. Full upstream history and tags are retained locally.
Only Roadmatics `main` should be pushed to `origin`; do not push all upstream refs.

## Toolchain

- Flutter **3.44.9**, pinned by `.tool_versions.yaml`; Dart **3.12.2**.
- Flutter revision `6b182d2c7585eba26d4edce0f97630effd256c33`.
- Rust is required by native dependencies. Upstream CI requests `stable`, without
  a numeric pin. Local Rust initially available: **1.90.0**.
- Android Gradle Plugin **8.11.1**, Gradle **8.14.1**, Kotlin **2.2.20**.
- Selected upstream uses Flutter's compile/target SDK **36**. The secure-storage
  plugin warns that it requests SDK 37; the untouched v2.9.1 build nevertheless
  passes. No SDK package metadata or dependency source was modified.
- Installed NDKs include **27.0.12077973** for native_imaging and **28.2.13676358**
  for the Flutter/native build. Cargokit installed Rust stable **1.98.1** itself.
- Local build Java: Android Studio JBR **21.0.10**.

The shared Flutter installation was not upgraded. This project's matching Flutter
checkout is `/data/DevCaches/roadmatics-chat/flutter`. An isolated Android SDK at
`/data/DevCaches/roadmatics-chat/android-sdk` adds API 37 and reuses installed SDK
components. The shared SDK could not be written by the installer.

## Untouched baseline verification

- `flutter pub get`: passed; upstream lockfile unchanged.
- `flutter analyze`: passed, no issues (35 seconds).
- v2.9.1 debug Android build: passed (220.8 seconds), all default ABIs.
- Baseline APK retained outside the repository at
  `/data/DevCaches/roadmatics-chat/baseline/fluffychat-v2.9.1-debug.apk`.
- Baseline SHA256: `a2e1a25bcee1d427ceb07030c8ad5f4f14559f1ce7ede5d1670c2b8548183610`.
- The analyzer ran on v2.9.5; Dart source and dependency lockfile are identical
  between these two tags. Roadmatics analysis is run again after changes.
- Device execution: pending; no Android device was connected at initialization.

Upstream source and legal metadata were left unchanged for baseline verification.
