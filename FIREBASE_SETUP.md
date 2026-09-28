<!-- SPDX-FileCopyrightText: 2026 Roadmatics Technologies -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Firebase setup

Use the existing Roadmatics Firebase project; do not create a second project.
Register the Android application as **`com.roadmatics.chat`**, then download its
client configuration to **`android/app/google-services.json`**. This file is
environment-specific and ignored by Git. Never force-add it.

The local file supplied on 2026-09-29 contains a matching Android client. This
confirms the configuration's package name, not successful token registration.

## Code path

Upstream enables FCM through `scripts/add-firebase-messaging.sh`. It adds
`fcm_shared_isolate`, updates `pubspec.yaml` / `pubspec.lock`, and enables guarded
code in `lib/utils/background_push.dart` and the Android `FcmPushService.kt`.
Review the Roadmatics build report for whether this step and device validation
have completed. Once enabled and committed, builds should use the committed
dependency lockfile; do not rerun the upstream script to update dependencies.

Gradle reads the matching client entry from the local JSON. The APK contains
Firebase client identifiers; it must never contain an Admin service-account key.
FCM does not normally require signing fingerprints for registration; add the
release certificate SHA fingerprints if other Firebase services require them.

## Runtime checks

Use a physical Android phone with Google Play Services. Allow notifications,
sign into a Roadmatics Matrix account, and confirm FCM initialization and token
registration without copying tokens into reports. Inspect the account's pusher:

- app ID starts with `com.roadmatics.chat.`;
- gateway URL is `http://127.0.0.1:5000/_matrix/push/v1/notify`;
- format is `event_id_only`.

A token alone does not establish notification delivery. Complete the separate
gateway setup and end-to-end tests in [PUSH_GATEWAY.md](PUSH_GATEWAY.md).

## Server and iOS credentials

The Firebase Admin JSON belongs only on the Sygnal server. Obtain it through
Project settings → Service accounts, and transfer it directly to the protected
server location. Do not place it beside `google-services.json`.

For iOS later, register `com.roadmatics.chat`, keep `GoogleService-Info.plist`
local, and configure the Apple APNs key in Firebase. Never commit `.p8` files.

References: [Firebase Flutter setup](https://firebase.google.com/docs/flutter/setup),
[FCM setup](https://firebase.google.com/docs/cloud-messaging/flutter/get-started).
