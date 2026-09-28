<!-- SPDX-FileCopyrightText: 2026 Roadmatics Technologies -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Publication checklist

Android sideloading, Play Internal Testing, Play production, and Apple publication
are separate milestones. No store upload is authorized by this checklist.

## Android

- [ ] Verify signed release APK identity, certificate, and SHA256.
- [ ] Complete login, sync, DM/group, reply/thread, reactions, attachment upload,
      download, search, and background/resume checks on a physical device.
- [ ] Validate FCM delivery through Roadmatics Sygnal in all supported app states.
- [ ] Back up the upload key and its passwords to at least two secure locations.
- [ ] Create the Play app with permanent package `com.roadmatics.chat`.
- [ ] Configure Play App Signing and preserve upload-key ownership. Decide the
      signing-key strategy before expecting an in-place update from the initial
      sideloaded APK to a Play-delivered APK: their signing certificates must be
      compatible. A Play-generated app-signing key differs from the upload key.
- [ ] Upload a verified AAB to **Internal Testing** first.
- [ ] Supply support contact, accurate privacy-policy URL, content rating, target
      audience, Data Safety, and app access/reviewer instructions.
- [x] Replace the temporary RC icon with artwork based on the user-selected
      cube/chat logo. Platform assets and editable monochrome vector prepared.
- [ ] Supply screenshots, feature graphic, store descriptions, and release notes.
- [ ] Increment version/build code for each subsequent upload.
- [ ] Publish corresponding AGPL source for each distributed binary.
- [ ] Obtain a separate decision before production submission/publication.

## iOS later

- [ ] Use macOS, a supported Xcode, and the upstream Flutter/Rust toolchain.
- [ ] Register `com.roadmatics.chat` and its share/notification extensions.
- [ ] Configure the matching App Group across app and extensions.
- [ ] Set the Roadmatics Apple team and provisioning in Xcode.
- [ ] Add Push Notifications and required Background Modes.
- [ ] Register the Firebase iOS app and local `GoogleService-Info.plist`.
- [ ] Configure APNs authentication in Firebase; keep `.p8` outside Git.
- [ ] Verify SSO/deep-link schemes, share extension, E2EE notification behavior,
      background delivery, and room navigation on a physical iPhone.
- [ ] Complete privacy, export compliance, support, screenshots, and reviewer
      access declarations using confirmed data practices.
- [ ] Use TestFlight first; decide public versus unlisted App Store distribution.

References: [Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756),
[Apple unlisted distribution](https://developer.apple.com/support/unlisted-app-distribution).
