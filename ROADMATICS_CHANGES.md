<!-- SPDX-FileCopyrightText: 2026 Roadmatics Technologies -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Roadmatics changes and upstream merge map

Baseline and build exceptions: [UPSTREAM_BASE.md](UPSTREAM_BASE.md).
This is a mobile client fork. Do not add Roadmatics backend business logic here.

| Intentional change | Main files / merge notes |
| --- | --- |
| Buildable stable base | v2.9.1; latest v2.9.5 fails with available SDK 37.0 and pinned AGP. Full history preserved. Do not silently reintroduce its compileSdk change without validating the toolchain. |
| Later iOS database fixes | `ios/Notification Service Extension/NotificationService.swift`: retain the v2.9.5 file's notification logging/read-only database fixes over v2.9.1. |
| Product identity | `pubspec.yaml` sets `0.1.0+1`; internal Dart package remains `fluffychat`. `AppConfig`, `AppSettings` and `config.sample.json` expose Roadmatics identity/source/support/privacy. |
| Single-server login | `setting_keys.dart` presets `matrix.roadmatics.com`; deployment identity/endpoints always use source defaults and are hidden from `ConfigViewer`. `SignInViewModel` avoids fetching recommended servers and adding arbitrary entries. `connectToHomeserverFlow` selects the fixed endpoint and rejects registration. |
| Full Matrix IDs | `login.dart` disables username-driven discovery when other homeservers are disabled, retaining `@user:roadmatics.com` against the configured endpoint. No credential or Matrix API envelope changes. |
| Onboarding | `intro_page.dart` retains the supported preset login flow, hides account creation and arbitrary database import for this single-server client. Login hint names `roadmatics.com`. `check_homeserver.dart` preserves the intro route when navigating directly to password login; it only replaces an existing `sign_in`/`sign_up` segment. Regression tests cover first login and add-account navigation. |
| Visible source/support attribution | `platform_infos.dart`, `client_chooser_button.dart`, `fluffy_share.dart`: Roadmatics links, explicit FluffyChat attribution, and no upstream-specific share-link client hint. |
| Mobile artwork | `assets/roadmatics/` holds the blue/cyan logo master adapted from the user-supplied poster, an opaque app icon, and a simplified monochrome SVG. `scripts/generate-roadmatics-icons.sh` and `pubspec.yaml` generate Android/iOS launcher/adaptive/monochrome, splash and notification assets. In-app branding uses the new logo. Earlier RC artwork is retained unused. Theme redesign deferred. |
| Android identity | `android/app/build.gradle.kts`, main manifest and two Kotlin package declarations use `com.roadmatics.chat`. The original Kotlin source directory remains to keep upstream scripts working. `android/fastlane/Appfile` matches the new app ID. |
| Android signing | External upload keystore via ignored `android/key.properties`; placeholder example only committed. Release tasks fail without signing properties and Firebase client config. No debug-signing fallback. |
| FCM | `fcm_shared_isolate` and its three Firebase dependencies added without upgrading existing lockfile entries. Upstream script's Dart/Kotlin activation applied; generated macOS/Windows plugin registrations follow dependency resolution. Android client JSON stays local. |
| Push route | Gateway fixed to `http://127.0.0.1:5000/_matrix/push/v1/notify`. Pusher base `com.roadmatics.chat`; device suffix retained. Legacy IDs only recognize old pushers. Sygnal uses `com.roadmatics.chat.*`. |
| iOS identity | Runner, share and notification extension bundle IDs, entitlements, Swift App Group access, and Dart database/keychain App Group references changed together. URL/share schemes match. Upstream Apple team cleared, display names/version prepared. No iOS build/signing claimed. |
| iOS build helper | `scripts/build-ios.sh` retains upstream environment names/install option, uses already-enabled FCM, validates team input and fixed bundle identity, and no longer applies a missing legacy patch. |
| Firebase iOS config | Removed upstream `ios/Runner/GoogleService-Info.plist` from current source; future Roadmatics file must be local. |
| Licence/security | Original licence texts, attribution and history retained. `REUSE.toml` attributes new artwork correctly. `.gitignore` protects local configs and keys. `.gitleaksignore` identifies eight reviewed upstream-history findings exactly; see `SECRET_AUDIT.md`. |
| CI | Small Android analysis/test/debug compilation in `.github/workflows/integrate.yaml`. Upstream publishing/notification/maintenance workflows retained inert under `.github/upstream-workflows/` to prevent accidental upstream deployments or messages. No release secrets in CI. |
| Documentation | Roadmatics README/privacy, preserved upstream README, Android/Firebase/push guides, publication checklist, external-service audit and build report. PRD preserved as supplied. |

## Intentionally unchanged

Matrix SDK, protocol/storage formats, internal Dart import namespace, translations,
core message/room/media workflows and upstream legal metadata remain intact.
Remaining user-opened help and internal upstream names are classified in
[EXTERNAL_SERVICES.md](EXTERNAL_SERVICES.md). Desktop/web distribution is not
rebranded or certified by this Android-first milestone.

## Regression checks

`test/roadmatics_login_test.dart` verifies that saved settings cannot redirect
login/FCM and typing full Roadmatics or other-domain Matrix IDs does not perform
discovery or switch the endpoint. These tests do not substitute for authenticated
device login, messaging, attachments, search, or push delivery.
