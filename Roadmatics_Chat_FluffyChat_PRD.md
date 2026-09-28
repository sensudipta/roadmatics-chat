# PRD — Roadmatics Chat (FluffyChat-based Matrix Client)

**Status:** Draft for Codex execution  
**Primary milestone:** Build a signed Android release APK that can be sideloaded now, with the project structured for Google Play / Apple App Store publication later.  
**Upstream:** FluffyChat — https://github.com/krille-chan/fluffychat  
**License:** AGPL-3.0-or-later  
**Roadmatics Matrix homeserver:** `https://matrix.roadmatics.com`  
**Matrix identity domain:** `roadmatics.com`  
**Target public repository:** `roadmatics-chat`  
**Preferred local path:** `/data/Github/roadmatics-chat`

---

## 1. Product goal

Create a minimally modified Roadmatics-branded mobile Matrix client based on FluffyChat.

The client is not intended to contain Roadmatics business logic. It is a temporary / transitional mobile UI for the Roadmatics Matrix backend while the wider Roadmatics CRM ecosystem is developed.

Roadmatics business automation will operate against the Matrix backend directly, not against this mobile client.

### Required outcome

At the end of this task:

1. There is a public Git repository for `roadmatics-chat`.
2. The repository preserves FluffyChat licensing and attribution correctly.
3. `origin` points to the Roadmatics public repository.
4. `upstream` points to `https://github.com/krille-chan/fluffychat.git`.
5. The app is visibly branded **Roadmatics Chat**.
6. Android application ID is Roadmatics-owned and suitable for future Play publication.
7. The app defaults to / is restricted to the Roadmatics Matrix homeserver.
8. The app can build and run on Android.
9. A **signed release APK** can be produced and sideloaded immediately.
10. The Android project is ready to produce a signed `.aab` for Google Play later.
11. Firebase Cloud Messaging support is enabled for the Roadmatics Firebase project.
12. No private Firebase server credentials, Android signing keys, Apple keys, passwords, tokens, or other secrets are committed to the public repository.
13. The repository contains clear documentation for Android build/release, Firebase setup, push-gateway dependency, licensing, and future iOS publication.
14. The changes are deliberately small so future upstream FluffyChat updates can be merged with manageable conflicts.

---

# 2. Architecture boundary

The intended architecture is:

```text
Roadmatics CRM / GPS / Service / Sales / Automation
                     |
                     | Matrix Client/Admin/Application Service APIs
                     v
              Roadmatics Matrix
        Synapse + PostgreSQL + S3
                     ^
                     |
               Matrix protocol
                     |
        +------------+------------+
        |                         |
 Roadmatics Chat             Element / future
 (FluffyChat fork)          Roadmatics CRM UI
```

**Important:** Roadmatics Chat is only a Matrix client.

Do not add CRM workflows, service-ticket processing, GPS logic, AI message parsing, or business rules into the FluffyChat fork during this project.

Those belong to Roadmatics backend services.

---

# 3. Scope

## In scope

- Clone and establish upstream relationship.
- Create Roadmatics Git repository.
- Preserve AGPL licensing.
- Rebrand application.
- Change Android package/application identity.
- Prepare iOS bundle identity for future use without requiring an iOS build now.
- Configure Roadmatics homeserver defaults/restrictions.
- Remove unnecessary FluffyChat-hosted service dependencies where practical.
- Enable Firebase Cloud Messaging code path.
- Configure Android release signing.
- Produce signed release APK.
- Prepare Android App Bundle build.
- Add documentation.
- Add basic CI checks if practical.
- Push sanitized source repository publicly.
- Document separate Matrix push-gateway requirement.

## Out of scope for this milestone

Do not:

- Rewrite the Matrix client.
- Replace the Matrix Dart SDK.
- Add Roadmatics CRM features.
- Deploy CRM integrations.
- Change Synapse.
- Change PostgreSQL/S3.
- Rebuild the existing Element web installation.
- Publish to Play Production immediately.
- Publish to Apple App Store immediately.
- Implement a custom Matrix push gateway inside the mobile app.
- Redesign the entire FluffyChat UI.
- Perform broad refactors unrelated to Roadmatics branding/configuration.
- Rename every internal Dart symbol from FluffyChat to Roadmatics.

---

# 3A. Required execution sequence

Codex should execute the project in this order:

```text
1. Clone/inspect upstream FluffyChat
2. Confirm stable upstream baseline and toolchain
3. Build untouched upstream Android app
4. Connect existing blank Roadmatics public GitHub repository
5. Apply Roadmatics identity/branding/homeserver changes
6. Create/configure Android signing without committing secrets
7. Build Roadmatics debug app
8. User creates matching Firebase Android app
9. Add local `google-services.json`
10. Enable/verify FCM code path
11. Build signed Roadmatics release APK and AAB
12. User generates Firebase Admin service-account JSON
13. Install/configure Sygnal on existing Matrix EC2, localhost only
14. Configure Roadmatics Matrix pusher URL/app ID
15. Test push end-to-end with sideloaded release APK
16. Run secret/licence audit
17. Push sanitized source to the existing public GitHub repository
18. Prepare Play Internal Testing / later iOS publication
```

Steps 12–15 are prerequisite-driven. Codex should continue all non-blocked mobile work while waiting for Firebase server credentials.

---

# 4. Guiding principle: keep the fork shallow

Future upstream updates are valuable.

Therefore:

- Make the smallest possible source changes.
- Prefer configuration/constants over architectural rewrites.
- Do not rename the Dart package/import namespace merely for cosmetic reasons if this causes widespread changes.
- Do not reorganize upstream folders.
- Avoid formatting unrelated files.
- Do not mass-replace the word `fluffychat` blindly.
- Platform identifiers and visible user-facing branding **should** change.
- Internal names that do not leak to users may remain if changing them creates unnecessary merge conflicts.

Create a file:

```text
ROADMATICS_CHANGES.md
```

listing every intentional Roadmatics-specific change and the main files involved. This is an operational map for future upstream merges.

---

# 5. Source baseline and Git strategy

## 5.1 Resolve a stable upstream baseline

Before changing code:

1. Inspect FluffyChat upstream.
2. Fetch tags/releases.
3. Identify the latest stable release tag.
4. Prefer the latest stable release tag over an arbitrary development commit on `main`, unless the stable release cannot build on the current Roadmatics toolchain.
5. Record:
   - upstream release/tag
   - upstream commit SHA
   - date
   - Flutter version expected upstream
   - Rust requirement

Create:

```text
UPSTREAM_BASE.md
```

Example:

```md
# Upstream base

Project: FluffyChat
Repository: https://github.com/krille-chan/fluffychat
Tag: <resolved tag>
Commit: <resolved SHA>
Fork initialized: <date>
```

Do not invent values; resolve them from Git.

## 5.2 Local clone

Preferred location:

```bash
cd /data/Github
git clone https://github.com/krille-chan/fluffychat.git roadmatics-chat
cd roadmatics-chat
```

If `/data/Github/roadmatics-chat` already exists, stop and inspect rather than overwriting anything.

## 5.3 Remotes

Rename original remote:

```bash
git remote rename origin upstream
```

Verify:

```bash
git remote -v
```

The desired long-term state is:

```text
origin    <Roadmatics public repository>
upstream  https://github.com/krille-chan/fluffychat.git
```

## 5.4 Branch

Create Roadmatics main branch from the selected stable upstream commit/tag.

Do not destroy upstream history.

Use normal commits such as:

1. `chore: initialize Roadmatics Chat fork`
2. `chore: apply Roadmatics branding`
3. `chore: configure Roadmatics homeserver`
4. `chore: configure Android application identity`
5. `chore: enable Firebase messaging`
6. `docs: add build and licensing documentation`

Small commits are preferred over one giant commit.

---

# 6. Public GitHub repository

The user is creating a **blank public GitHub repository** for this project.

Target repository name:

```text
roadmatics-chat
```

Target visibility:

```text
public
```

Codex must **not create a second repository** if the blank Roadmatics repository already exists.

First determine the authenticated GitHub account / organization and confirm the intended repository URL.

If `gh` is available:

```bash
gh auth status
```

Then configure remotes so the desired final state is:

```text
origin    <existing Roadmatics public roadmatics-chat repository>
upstream  https://github.com/krille-chan/fluffychat.git
```

Typical flow after cloning upstream:

```bash
git remote rename origin upstream
git remote add origin <ROADMATICS_PUBLIC_REPO_URL>
git remote -v
```

Do not push anything until the secret scan and build checks described later have passed.

If GitHub CLI is not installed or not authenticated, that is not a blocker: use normal Git remotes over SSH/HTTPS if credentials are already configured.

Do not ask for or store a GitHub password.

---

# 7. Licensing and attribution requirements

FluffyChat is AGPL-3.0-or-later.

The Roadmatics fork must remain compliant.

## Required

Preserve upstream:

- `LICENSE`
- `LICENSES/`
- SPDX headers
- relevant copyright notices
- `REUSE.toml`
- third-party licence information
- original Git history where practical

Create/update README so it clearly states:

- Product name: Roadmatics Chat
- Roadmatics Chat is based on FluffyChat.
- Link to upstream FluffyChat repository.
- Roadmatics modifications are distributed under AGPL-3.0-or-later.
- Source repository URL for this released client.
- Roadmatics backend services are separate systems and are not part of this repository.

Do not claim Roadmatics wrote FluffyChat.

Do not remove upstream copyright notices from files.

## Branding assets

Do not reuse the FluffyChat logo/banner as Roadmatics branding.

If approved Roadmatics artwork is not already available in the repository:

- use a temporary neutral Roadmatics Chat icon (for example a simple `RC` placeholder),
- clearly mark it as temporary,
- keep asset replacement isolated so the final company artwork can be swapped later easily.

---

# 8. Product identity

Use these defaults unless a collision is discovered.

## User-facing name

```text
Roadmatics Chat
```

## Android application ID

Preferred:

```text
com.roadmatics.chat
```

Before committing, verify this identifier is not already used by another Roadmatics Android app.

Do not change it after Play publication.

## iOS bundle identifier

Prepare:

```text
com.roadmatics.chat
```

Do not perform Apple signing in this milestone unless the required macOS signing environment is already present.

## Android notification/pusher application identity

The FluffyChat source currently has push-related IDs such as the upstream `chat.fluffy.fluffychat`.

Change the Roadmatics build so its Matrix pusher/app identity is Roadmatics-owned and consistent with the Roadmatics push-gateway configuration.

Preferred base:

```text
com.roadmatics.chat
```

Search for all app IDs and legacy FluffyChat-specific identifiers before changing them.

## Version

Start Roadmatics releases independently from upstream.

Recommended initial version:

```text
0.1.0+1
```

Do not overwrite the documented upstream version history.

For each Play/App Store release, increment the build/version code.

---

# 9. Homeserver configuration

Roadmatics users should not need to know what a Matrix homeserver is.

Homeserver:

```text
https://matrix.roadmatics.com
```

Identity/server domain:

```text
roadmatics.com
```

FluffyChat currently exposes configurable defaults such as `defaultHomeserver`, `presetHomeserver`, and source-level homeserver behavior.

Codex must inspect the current upstream implementation and use the least invasive supported mechanism.

## Desired behavior

At first launch:

- app should lead users directly to Roadmatics login;
- user should not be encouraged to select matrix.org or another public homeserver;
- remove Roadmatics users' dependency on upstream recommended homeserver lists;
- registration should not be offered if it is useless because Roadmatics server registration is admin-controlled.

Recommended source-level values where appropriate:

```text
default homeserver = matrix.roadmatics.com
allow other homeservers = false
enable registration = false
```

Do not break Matrix login compatibility merely to hide a field.

If the current FluffyChat implementation has a safe supported way to preset/lock the homeserver, use it.

Document the final mechanism in `ROADMATICS_CHANGES.md`.

---

# 10. Audit FluffyChat-hosted external services

A Roadmatics-branded build should not silently depend on FluffyChat-operated services unless explicitly accepted.

Search the repository for at least:

```text
fluffy.chat
fluffychat.im
push.fluffychat.im
crash.fluffy.chat
livekit
ko-fi
matrix.org
recommended_homeservers
chat.fluffy.fluffychat
im.fluffychat
```

Classify every occurrence as one of:

1. code/internal name — harmless;
2. attribution/upstream link — keep;
3. production network service — replace/disable;
4. tutorial/help URL — replace or retain intentionally;
5. branding asset — replace.

## Specific concerns

### Crash reporting

Do not send Roadmatics client crash data automatically to `crash.fluffy.chat`.

Disable upstream automatic crash reporting unless Roadmatics explicitly configures its own service later.

Do not add Sentry/Crashlytics telemetry silently.

### Update checks

If FluffyChat checks upstream GitHub releases, point update/release metadata at the Roadmatics repository or disable custom in-app update checks for the initial build.

Store-distributed apps will ultimately receive updates through Google Play / App Store.

### Support links

Replace upstream support/issues links with either:

- Roadmatics repository issues, or
- a Roadmatics-owned help URL.

### Calls / LiveKit fallback

Do not silently depend on an upstream FluffyChat-hosted fallback calling service.

If calls require an external upstream fallback and Roadmatics has no configured MatrixRTC/LiveKit service yet:

- leave basic chat features functional,
- disable/hide the affected call feature or document it as unsupported,
- do not introduce a new server dependency without approval.

---

# 11. Branding

The initial build requires only a restrained rebrand.

## Change

- App display name → `Roadmatics Chat`
- Android launcher label
- iOS display name
- launcher icon
- adaptive icon
- monochrome icon where supported
- splash branding
- about/source links
- repository URLs
- support URLs
- default homeserver

## Colour

Do not perform broad theme redesign.

If no Roadmatics brand colour has been explicitly supplied, preserve a sensible upstream theme temporarily and centralize the value so it can be changed later.

Do not block the APK on final colour selection.

---

# 12. Firebase / FCM

FluffyChat's upstream README currently documents enabling Google Firebase Cloud Messaging through:

```bash
./scripts/add-firebase-messaging.sh
```

Codex must inspect this script before running it and understand all files it modifies.

## Firebase app

Use an Android Firebase app matching:

```text
com.roadmatics.chat
```

The user already has a Firebase account/project; do not create duplicate Firebase infrastructure unless required.

If Firebase project access is not available from the CLI, stop only at the point that user action is required and provide the exact console steps.

## Client configuration

Obtain the Android Firebase configuration for `com.roadmatics.chat`.

Expected file typically includes:

```text
android/app/google-services.json
```

Treat client Firebase config as environment-specific.

Even though Firebase client config is not equivalent to a server credential, do **not** commit it to the public repo unless the user explicitly approves.

Prefer:

```text
android/app/google-services.json
```

in `.gitignore`, plus documentation explaining where to place it.

Similarly keep future iOS:

```text
GoogleService-Info.plist
```

out of the public repository unless explicitly approved.

## Important: FCM alone is not sufficient

`google-services.json` enables the Android client to register with Firebase and obtain an FCM token. It does **not** give Synapse permission to send FCM messages.

The Firebase Admin service-account JSON belongs only on the Sygnal server and is a separate prerequisite.

Matrix mobile push flow is:

```text
Synapse
   |
   | Matrix Push Gateway API
   v
Roadmatics push gateway (Sygnal on same Matrix EC2)
   |
   | FCM v1
   v
Firebase
   |
   v
Roadmatics Chat
```

FluffyChat currently registers a Matrix pusher pointing to a configurable push gateway.

A Roadmatics-branded app using its own Firebase project must not depend on FluffyChat's push gateway.

Therefore document and prepare for a Roadmatics-owned Matrix push gateway.

Recommended reference implementation:

```text
Sygnal
https://github.com/element-hq/sygnal
```

The push gateway is a separate infrastructure task.

Preferred future endpoint:

```text
https://push.roadmatics.com/_matrix/push/v1/notify
```

Do not commit Firebase Admin service-account JSON to this repository.

Do not embed Firebase server credentials in the APK.

## Client pusher configuration

Configure the Roadmatics client so its push gateway URL and pusher application ID match the Roadmatics Sygnal deployment.

The final app must not register:

```text
https://push.fluffychat.im/...
```

for Roadmatics FCM tokens.

---

# 13. Android signing — must be production-safe from day one

We want a sideloadable **release APK now** and Play publication later.

Use one stable Roadmatics upload key.

## Generate upload keystore

If a Roadmatics upload keystore for this app does not already exist, generate one.

Example approach:

```bash
keytool -genkeypair \
  -v \
  -keystore ~/secure/roadmatics-chat-upload.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias roadmatics-chat-upload
```

Do not hard-code the exact secure path if the user's key-management convention differs.

## Required security rules

Never commit:

```text
*.jks
*.keystore
key.properties
store passwords
key passwords
private signing keys
```

Confirm `.gitignore` covers these.

Use a local `key.properties` or equivalent Gradle secret configuration.

Document:

```text
android/key.properties.example
```

with placeholders only.

Example:

```properties
storePassword=CHANGE_ME
keyPassword=CHANGE_ME
keyAlias=roadmatics-chat-upload
storeFile=/absolute/path/outside/repository/roadmatics-chat-upload.jks
```

The real file must be ignored.

## Key backup

Document that the user must keep at least two secure backups of the upload key and its passwords.

Later Google Play can use Play App Signing while Roadmatics retains the upload key.

---

# 14. Android build environment

Before editing dependencies, inspect the upstream pinned toolchain.

Check:

```bash
flutter --version
dart --version
rustc --version
cargo --version
java -version
flutter doctor -v
```

Read:

```text
.tool_versions.yaml
pubspec.yaml
pubspec.lock
android/
README.md
```

Use the upstream-supported Flutter/Rust/Java versions whenever practical.

Do not casually upgrade Flutter, Gradle, Kotlin, Rust, or Matrix SDK versions as part of the branding task.

First make the unmodified upstream baseline build.

This is important for distinguishing upstream/toolchain problems from Roadmatics changes.

---

# 15. Baseline build before modifications

Before changing product identity:

```bash
flutter pub get
flutter analyze
flutter build apk --debug
```

Run the upstream app on a connected Android device if possible.

Record any baseline warnings/failures.

Do not "fix" unrelated upstream warnings unless they prevent the Roadmatics build.

---

# 16. Build the Roadmatics debug app

After identity/config changes and Firebase patching:

```bash
flutter clean
flutter pub get
flutter analyze
flutter build apk --debug
```

Install on device:

```bash
adb install -r <debug-apk-path>
```

Verify:

- launcher name says Roadmatics Chat;
- Roadmatics icon shown;
- app starts;
- login targets Matrix Roadmatics;
- no accidental matrix.org onboarding;
- login succeeds;
- room list syncs;
- send/receive text;
- DM;
- room invite;
- replies/threads;
- image upload;
- PDF/file upload;
- media download;
- background/resume stability.

---

# 17. Signed release APK

Configure release signing through the external keystore.

Build:

```bash
flutter build apk --release
```

Expected output is typically under:

```text
build/app/outputs/flutter-apk/
```

Record the exact generated artifact path.

Verify signature:

```bash
apksigner verify --verbose <apk>
```

If `apksigner` is not in PATH, use the Android SDK build-tools path.

Install the release APK on a physical device:

```bash
adb install -r <release-apk>
```

Acceptance requirement:

The signed release build must successfully log into the Roadmatics Matrix server and send/receive messages.

---

# 18. Google Play readiness

Also verify:

```bash
flutter build appbundle --release
```

Expected `.aab` under the Flutter build outputs.

Do not upload to production in this task unless explicitly requested.

Prepare documentation for:

- Play app creation
- package name `com.roadmatics.chat`
- Play App Signing
- internal test track
- app content declarations
- privacy policy
- Data Safety
- screenshots
- icon
- feature graphic
- release notes
- content rating
- target audience
- support contact

Prefer Play **Internal Testing** for the first Roadmatics store-distributed build.

---

# 19. iOS future readiness

Current milestone is Android-first.

Do not block Android work on iOS signing.

However:

- change the visible application name to Roadmatics Chat;
- prepare bundle identifier `com.roadmatics.chat`;
- audit URL schemes/deep links;
- remove upstream FluffyChat bundle identifiers where needed;
- preserve FluffyChat's iOS build script compatibility;
- document future Firebase/APNs setup.

Future FCM-on-iOS requires:

- Apple bundle/App ID;
- Push Notifications capability;
- Background Modes / remote notifications as required by the current FluffyChat implementation;
- APNs authentication key;
- APNs key uploaded to Firebase;
- Roadmatics Firebase iOS app;
- Roadmatics push gateway configuration.

The final iOS distribution target can later be App Store / unlisted App Store distribution.

Do not commit `.p8` APNs keys.

---

# 20. Secret handling / public repository gate

Before the first public push, perform a dedicated secret audit.

Search for:

```text
BEGIN PRIVATE KEY
PRIVATE KEY
service_account
client_secret
password
storePassword
keyPassword
AWS_ACCESS_KEY
META_ACCESS_TOKEN
google-services.json
GoogleService-Info.plist
*.p8
*.jks
*.keystore
```

Also inspect:

```bash
git status
git diff --cached
git ls-files
```

If available, run a secret scanner such as `gitleaks` on the repository and Git history.

Absolutely do not publish:

- signing keystore;
- key passwords;
- Firebase Admin service account;
- APNs `.p8`;
- AWS credentials;
- Matrix admin access tokens;
- database passwords;
- private environment files;
- personal developer credentials.

The public repository should contain only client source and non-secret configuration/templates.

---

# 21. README requirements

Replace the README top section with Roadmatics-specific information while retaining attribution.

Suggested structure:

```md
# Roadmatics Chat

Roadmatics Chat is an internal Matrix client used by Roadmatics Technologies.

It is based on FluffyChat:
https://github.com/krille-chan/fluffychat

Roadmatics Chat is distributed under the GNU Affero General Public License
(AGPL-3.0-or-later). See LICENSE and LICENSES/ for details.

## Homeserver

Roadmatics Chat is configured for:
https://matrix.roadmatics.com

## Build

...

## Firebase

Client Firebase configuration is not stored in this repository.

## Android signing

Signing keys are not stored in this repository.

## Upstream synchronization

...
```

Do not delete upstream legal metadata.

---

# 22. Privacy document

Adapt `PRIVACY.md` for Roadmatics Chat.

Do not falsely claim data practices that have not been confirmed.

At minimum describe:

- the app connects to the Roadmatics Matrix server;
- message/media storage is controlled by Roadmatics infrastructure;
- Firebase Cloud Messaging may process push tokens / notification delivery metadata;
- app-store platform telemetry is subject to Apple/Google terms;
- do not claim that Roadmatics reads E2EE content where it cannot;
- operational unencrypted rooms may be processed by Roadmatics backend automation.

For store publication, this document will eventually need a stable public URL.

A GitHub-hosted document can be temporary; a Roadmatics-owned website URL is preferable later.

---

# 23. Upstream update process

Document this exact concept:

```bash
git fetch upstream
git checkout main
git merge <new-upstream-stable-tag-or-commit>
```

Do not blindly merge upstream `main` into production.

Preferred process:

1. identify new stable FluffyChat release;
2. review release notes;
3. create branch:
   `upstream/<version>`;
4. merge/rebase as appropriate;
5. resolve only Roadmatics-specific conflict points;
6. run full build/test;
7. merge to Roadmatics `main`.

Maintain Roadmatics changes centrally so upgrade conflicts remain small.

Do not routinely edit generated translation files, large unrelated UI areas, or dependency locks without need.

---

# 24. Optional CI

If GitHub Actions are retained/added, start small.

On pull request / push:

- checkout
- install supported Flutter
- install Rust as required upstream
- `flutter pub get`
- `flutter analyze`
- unit tests that do not need private infrastructure
- debug Android build if runtime is reasonable

Do not put release signing credentials in the first CI iteration.

Do not run upstream integration tests that require Docker merely to satisfy this milestone unless there is a real need.

Release signing can remain local initially.

---

# 25. Push-gateway prerequisite and deployment specification

This is required for fully functioning Roadmatics FCM push, but **do not install/configure it until the mobile/Firebase prerequisites are ready**.

Preferred service:

```text
Element-maintained Sygnal
https://github.com/element-hq/sygnal
```

## 25.1 Prerequisites — Codex must wait until these exist

Do not proceed with Sygnal until all of the following are confirmed:

1. Final Android application ID:
   ```text
   com.roadmatics.chat
   ```
2. Matching Android app exists in the Roadmatics Firebase project.
3. `google-services.json` for that Android app has been obtained and the mobile build can initialize Firebase.
4. Final Matrix pusher application ID has been chosen and is consistent with the Roadmatics app identity.
5. A **Firebase Admin service-account JSON** has been generated for the Roadmatics Firebase project.

If item 5 is missing, Codex must stop only at the Sygnal deployment step and ask the user to generate/download the Firebase Admin service-account JSON from Firebase / Google Cloud.

The service-account JSON is a **server secret**:

- do not copy it into the mobile repository;
- do not commit it to Git;
- do not embed it in the APK/AAB;
- do not print its contents into logs or final reports.

## 25.2 Deployment location

Install Sygnal on the **existing Roadmatics Matrix EC2 instance**, alongside:

```text
Synapse
PostgreSQL
nginx
Element Web
Sygnal
```

For the initial Roadmatics deployment, Sygnal does **not** need a public internet hostname.

Bind Sygnal only to localhost, for example:

```text
127.0.0.1:5000
```

The Matrix push gateway URL registered by Roadmatics Chat should therefore be:

```text
http://127.0.0.1:5000/_matrix/push/v1/notify
```

This works because **Synapse**, not the phone, calls the push gateway URL.

Do not add:

```text
push.roadmatics.com
```

DNS, nginx proxying, TLS certificates, or an AWS Security Group port for Sygnal unless/until Sygnal is moved off the Matrix host or there is another explicit operational reason.

## 25.3 Required push flow

```text
Roadmatics Chat
   |
   | registers Matrix pusher:
   | app_id + FCM token + localhost gateway URL
   v
Synapse (same EC2)
   |
   | HTTP localhost
   v
Sygnal 127.0.0.1:5000
   |
   | FCM HTTP v1, outbound Internet
   v
Firebase Cloud Messaging
   |
   v
Roadmatics Chat phone
```

## 25.4 Sygnal configuration requirements

Configure Sygnal with:

- Roadmatics Matrix pusher application ID;
- FCM API v1;
- Firebase project ID;
- Firebase Admin service-account JSON stored only on the EC2 server;
- localhost-only listener;
- native/systemd-managed service;
- automatic restart on failure;
- logs through journald or another existing server logging mechanism.

Suggested protected server location for the Firebase Admin file:

```text
/etc/sygnal/firebase-roadmatics.json
```

Set restrictive ownership/permissions appropriate to the Sygnal service user.

Do not expose Sygnal directly to the public Internet.

## 25.5 Client requirement

Roadmatics Chat must **not** register:

```text
https://push.fluffychat.im/...
```

or any other FluffyChat-operated push infrastructure for the Roadmatics Firebase app.

The Roadmatics build must register its Matrix pusher against:

```text
http://127.0.0.1:5000/_matrix/push/v1/notify
```

with the Roadmatics application ID.

## 25.6 iOS later

For iOS via Firebase later:

- create the Roadmatics iOS Firebase app;
- configure APNs in the Apple Developer account;
- upload the Roadmatics APNs authentication key to Firebase;
- Sygnal continues communicating to Firebase;
- Firebase delivers to APNs.

Do not commit APNs `.p8` keys.

## 25.7 Future topology change

If Sygnal is ever moved to another host, then replace localhost with a stable HTTPS endpoint such as:

```text
https://push.roadmatics.com/_matrix/push/v1/notify
```

Only at that time should DNS, nginx/TLS, security-group exposure and external health monitoring be added.

---

# 26. Acceptance tests

## Build acceptance

- [ ] Upstream stable baseline builds before customization.
- [ ] `flutter analyze` completes without new Roadmatics-created errors.
- [ ] Roadmatics debug APK builds.
- [ ] Signed Roadmatics release APK builds.
- [ ] APK signature verifies.
- [ ] Android App Bundle builds.
- [ ] Public repo contains no secrets.

## Branding acceptance

- [ ] App launcher says `Roadmatics Chat`.
- [ ] No FluffyChat logo used as Roadmatics app icon.
- [ ] Roadmatics launcher/adaptive/monochrome icons are present.
- [ ] Splash screen is Roadmatics-branded or neutral.
- [ ] About/source link points to Roadmatics public repo.
- [ ] FluffyChat upstream attribution remains.

## Matrix acceptance

- [ ] App defaults to `matrix.roadmatics.com`.
- [ ] Other homeserver selection is hidden/disabled if safely supported.
- [ ] Registration UI is hidden/disabled where practical.
- [ ] Login with `@user:roadmatics.com` works.
- [ ] Room sync works.
- [ ] DM works.
- [ ] Group room works.
- [ ] Reply/thread works.
- [ ] Reactions work.
- [ ] Image/file uploads work.
- [ ] Media download works.
- [ ] Search works.

## Push acceptance

After Roadmatics push gateway is available:

- [ ] App obtains FCM token.
- [ ] Matrix pusher references Roadmatics push gateway.
- [ ] App does not register `push.fluffychat.im`.
- [ ] Notification arrives when app is foregrounded.
- [ ] Notification arrives when app is backgrounded.
- [ ] Notification arrives after app is removed from recent apps / process is not active, subject to Android OEM rules.
- [ ] Tapping notification opens the correct room.
- [ ] Sideloaded release APK receives FCM push on a Google Play Services device.

## Dependency audit acceptance

- [ ] No automatic crash report is sent to `crash.fluffy.chat`.
- [ ] No Roadmatics Firebase token is sent to FluffyChat push infrastructure.
- [ ] No accidental FluffyChat-hosted call fallback is relied upon without explicit approval.
- [ ] Remaining upstream URLs are intentional attribution/help references only.

---

# 27. Deliverables

Codex should finish with:

1. Local Roadmatics Chat Git repository.
2. Public GitHub repository.
3. `origin` + `upstream` remotes correctly configured.
4. Signed release APK path.
5. Release AAB path, if build succeeds.
6. `UPSTREAM_BASE.md`
7. `ROADMATICS_CHANGES.md`
8. updated `README.md`
9. updated/adapted `PRIVACY.md`
10. `android/key.properties.example`
11. secret-safe `.gitignore`
12. Firebase setup documentation
13. `PUSH_GATEWAY.md`
14. Android publication checklist
15. iOS future publication checklist
16. final build/test report.

---

# 28. Required final Codex report

At the end, Codex must report:

## Repository

```text
Local path:
Public repository:
origin:
upstream:
branch:
upstream base tag:
upstream base SHA:
```

## Identity

```text
App name:
Android application ID:
iOS bundle ID:
Homeserver:
Matrix server domain:
Push app ID:
```

## Build

```text
Flutter:
Dart:
Rust:
Java:
APK:
APK SHA256:
AAB:
AAB SHA256:
```

## Tests

State pass/fail for:

- analyze
- debug build
- release build
- release install
- login
- text send/receive
- attachment
- search
- push

## Security

Explicitly confirm:

```text
No signing key committed.
No Firebase Admin key committed.
No APNs key committed.
No AWS credential committed.
No Matrix admin token committed.
Secret scan complete.
```

## Outstanding manual actions

List only actions Codex genuinely could not complete, e.g.:

- Firebase console app registration;
- download `google-services.json`;
- BigRock DNS for `push.roadmatics.com`;
- Play Console app creation;
- Apple Developer App ID/certificate actions.

Do not present untested features as completed.

---

# 29. Execution instructions to Codex

When executing this PRD:

1. Inspect first; do not make speculative mass changes.
2. Get the upstream baseline building before rebranding.
3. Preserve AGPL metadata.
4. Keep the Roadmatics diff shallow.
5. Use small logical commits.
6. Never commit secrets.
7. Do not overwrite existing local repositories.
8. Do not create duplicate Firebase/Play/Apple resources without checking.
9. Ask the user only when a credential, console action, company-specific value, or destructive action is genuinely required.
10. Continue all non-blocked work while waiting for external configuration.
11. Before public push, perform a secret scan and show the staged file list.
12. Do not push the repository publicly until the secret audit passes.
13. After push, verify the repository is actually public and the expected files are visible.
14. Produce the final report defined above.

---

# 30. External references for implementation

FluffyChat upstream:
- https://github.com/krille-chan/fluffychat

Current upstream build documentation says FluffyChat requires Flutter and Rust, supports `flutter build apk`, and provides `./scripts/add-firebase-messaging.sh` for Firebase messaging.

FluffyChat configuration sample:
- https://github.com/krille-chan/fluffychat/blob/main/config.sample.json

Matrix push gateway reference:
- https://github.com/element-hq/sygnal

Firebase Flutter setup:
- https://firebase.google.com/docs/flutter/setup

Firebase Cloud Messaging:
- https://firebase.google.com/docs/cloud-messaging/flutter/get-started

Google Play App Signing:
- https://support.google.com/googleplay/android-developer/answer/9842756

Apple unlisted app distribution:
- https://developer.apple.com/support/unlisted-app-distribution

AGPL-3.0:
- https://www.gnu.org/licenses/agpl-3.0.html
