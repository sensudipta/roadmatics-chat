<!-- SPDX-FileCopyrightText: 2026 Roadmatics Technologies -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Roadmatics Chat build report — 2026-09-29

**Android source/build checkpoint complete; device acceptance and server push
deployment pending. Do not describe this as an end-to-end accepted release.**

## Repository

| Field | Value |
| --- | --- |
| Local path | `/data/Github/roadmatics-chat` |
| Existing public repository | https://github.com/sensudipta/roadmatics-chat |
| origin | `https://github.com/sensudipta/roadmatics-chat.git` |
| upstream | `https://github.com/krille-chan/fluffychat.git` |
| Branch | `main` |
| Stable base | `v2.9.1` |
| Base SHA | `f7bded3e049c0077b3ade8d02cae6d06e5d5756f` |
| Public push | User published implementation commit `b28766ac3`; GitHub CLI browser authentication is now configured. |

The latest stable v2.9.5 was tried first. Its explicit SDK 37 target is incompatible
with the currently available SDK 37.0 under its pinned AGP. The PRD's earlier
stable fallback was used; untouched v2.9.1 built successfully. Later upstream iOS
notification/database fixes were carried forward separately. Details:
[UPSTREAM_BASE.md](UPSTREAM_BASE.md).

## Identity

| Field | Value |
| --- | --- |
| Display name | Roadmatics Chat |
| Android application ID / namespace | `com.roadmatics.chat` |
| Prepared iOS bundle ID | `com.roadmatics.chat` |
| Homeserver | `https://matrix.roadmatics.com` |
| Matrix identity domain | `roadmatics.com` |
| Pusher app ID | `com.roadmatics.chat.<device ID>` |
| Pusher URL | `http://127.0.0.1:5000/_matrix/push/v1/notify` |
| Version / Android code | `0.1.0` / `1` |
| Android min / target / compile SDK | `24` / `36` / `36` |

## Toolchain and artifacts

- Flutter **3.44.9**, Dart **3.12.2**.
- Rust native builds used stable **1.98.1**, installed by upstream Cargokit.
- Java for Gradle: Android Studio JBR **21.0.10**.
- AGP **8.11.1**, Gradle **8.14.1**, Kotlin **2.2.20**.
- APK: `build/app/outputs/flutter-apk/app-release.apk` (approximately 185.6 MB).
- APK SHA256: `9a571a7de55ffc8d5218e3b4453dddab9f71d689ff53b957f400cdeb409859d6`.
- AAB: `build/app/outputs/bundle/release/app-release.aab` (approximately 147.1 MB).
- AAB SHA256: `012eff7104a9092e3285ceeab517a1e8936a54db9cba4a12079ce3add8c3bf05`.
- Upload certificate SHA256:
  `814ac1705878e9dd808ed9cde05a2a5d733d45c553cb02dc31c99f7b0277bd02`.
- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`.

Artifacts are local and ignored; no binaries have been uploaded to GitHub or a
store. The private upload key/password are outside the checkout. Back up both to
two secure locations as described in [ANDROID_BUILD.md](ANDROID_BUILD.md).

## Verification

| Check | Result |
| --- | --- |
| Untouched stable Android baseline | PASS — v2.9.1 debug build, 220.8 seconds |
| Dependency resolution | PASS — existing dependency versions retained; only FCM/Firebase entries added |
| Roadmatics analyze | PASS — no issues, final run 38.6 seconds |
| Tests | PASS — 8 tests, including 4 login/configuration regression tests; upstream includes placeholder widget tests |
| Roadmatics debug build | PASS — 64.3 seconds |
| Roadmatics signed release APK | PASS — corrected release, 68.4 seconds |
| APK signature | PASS — APK Signature Scheme v2, one RSA-3072 Roadmatics signer |
| APK manifest | PASS — package/name/version/launcher verified from artifact |
| APK Firebase resources | PASS — matching Roadmatics Android app/project identifiers and FCM service present; notification permission declared |
| APK ZIP / 64-bit ELF alignment | PASS — 16 KB zipalign and all 18 inspected 64-bit ELF libraries |
| Release AAB | PASS — corrected release, 22.8 seconds; bundletool 1.18.3 validation successful |
| AAB signing | PASS — jarsigner reports verified; standard self-signed/no-timestamp warnings and streaming manifest-order warnings recorded |
| REUSE licence audit | PASS — 636/636 files with copyright/licence information at audit time |
| Secret scan | PASS — staged-source scan clear; history clear with eight explicitly reviewed upstream findings (see SECRET_AUDIT.md) |
| Release install / launch | PASS — corrected signed release updated in place and launched on Realme RMX1921, Android 11 |
| Account login / room sync | PENDING — corrected release now opens the password form against `matrix.roadmatics.com` on the phone; awaiting manual account login. |
| Text send/receive / DM / group | NOT TESTED |
| Reply/thread / reactions | NOT TESTED |
| Attachment / media download | NOT TESTED |
| Search / background-resume | NOT TESTED |
| FCM initialization/token / push delivery / notification tap | NOT TESTED — device and Sygnal prerequisites pending |
| iOS build/signing | NOT RUN — Android-first Linux milestone |
| GitHub Actions | No remote runs returned after publication |

Read-only HTTP checks confirmed that the Roadmatics Matrix endpoint responds and
advertises password login. These are not proof of authenticated login or messaging.

## Device regression correction

The initial release sent the preset-server Sign in button from `/home` to
nonexistent `/login`. The shared flow had assumed that every caller was on a
server-selection page. It now removes only `sign_in` or `sign_up`, preserving
the intro route for both first login and adding an account. Two widget tests
reproduced the incorrect destinations before the fix and pass after it.

The corrected release was installed with `adb install -r` using the same upload
key. A real tap of Sign in reached the live Roadmatics password screen, with
two input fields and no route-error page. No password was entered by automation.
Authenticated login, room sync and messaging remain pending user sign-in.

## Known build warnings and resolved failures

- Upstream `flutter_secure_storage 11.0.0` warns about SDK 37, and AGP reports a
  newer SDK XML schema. The selected baseline and Roadmatics builds pass. No
  package-cache source or SDK metadata was altered to suppress the warning.
- Upstream translations contain untranslated messages; older native plugins
  report Java/deprecation warnings. No unrelated translation/dependency sweep.
- First baseline attempts needed NDK 27 and exposed the SDK 37 target problem.
- Icon generation initially duplicated an upstream colour resource; fixed by
  letting the generator own the single colour definition. Final icons inspected.
- A release attempt overlapped Flutter tests and picked up test-only plugin
  registration. Rerun succeeded with operations serialized. Do not run Flutter
  tests/builds simultaneously in this checkout.
- Host unit tests need CMake in PATH; this machine uses
  `/data/Android/Sdk/cmake/3.22.1/bin`.

## Security and infrastructure

No signing key committed. No Firebase Admin key committed. No APNs key committed.
No AWS credential committed. No Matrix admin token committed. Secret scan complete
for the reviewed source, with historical upstream exceptions documented explicitly.
Real Android signing properties and Firebase client JSON are ignored. No secrets
were added to CI or release documentation.

No AWS, Synapse, PostgreSQL, S3, DNS, nginx or Element changes were made. Sygnal is
not deployed. Synapse's default outbound IP policy blocks loopback, so its actual
configuration must be inspected before deploying the localhost gateway. If a
Synapse exception is required, the PRD's exclusion of Synapse changes requires
separate authorization for that exact change.

## Remaining actions

1. Complete normal-account login on the connected phone and the remaining
   acceptance checks above. Do not send passwords in chat.
2. Check the public repository CI run when available.
3. Once mobile Firebase initialization is verified, provide the Matrix host/access
   details and put a matching Firebase Admin service-account JSON securely on the
   server (not in this repository). Then install/test Sygnal per PUSH_GATEWAY.md.
4. Back up the upload key/password. Store console setup, approved artwork,
   confirmed privacy details and later iOS signing remain separate publication work.
