<!--
SPDX-FileCopyrightText: 2019-Present Christian Kußowski
SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
SPDX-FileCopyrightText: 2026 Roadmatics Technologies
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Roadmatics Chat privacy information

This describes the client configuration. Retention periods, administrator access
policies, data-subject request procedures, company contact details, and store
Data Safety declarations still need confirmation by Roadmatics before store
publication. This document does not invent those practices.

## Matrix messages and media

The app connects to the Roadmatics Matrix server at
`https://matrix.roadmatics.com`. Roadmatics infrastructure controls server-side
message, account, and media storage. The client keeps local account state,
message caches, encryption keys and downloaded media as needed to function.
Android system backup of the app is disabled by the application manifest.

End-to-end encrypted room content is encrypted for participating clients. Server
operators cannot ordinarily read that content without appropriate decryption
keys or access to a participating endpoint. This is not a promise that every
room is encrypted: unencrypted operational rooms may be processed by Roadmatics
backend automation. Room participants can copy or export content, and federated
rooms may involve other homeservers under their own policies.

## Notifications

Firebase Cloud Messaging may process device push tokens and delivery metadata.
The client registers a pusher with the Roadmatics homeserver. The intended route
is Synapse → Roadmatics Sygnal → Firebase → the phone. The gateway uses the
`event_id_only` Matrix format; the client retrieves relevant events to display
notifications. End-to-end delivery is subject to the deployment acceptance tests.

The Roadmatics Firebase token is not configured to use the FluffyChat push
service. Firebase client configuration is distinct from server-side Admin
credentials; Admin credentials must never be included in the mobile app.

## Device permissions and external services

Camera, microphone, photos/files, location and notification permissions support
user-invoked chat features. Denying a permission can disable its associated
feature. The current native client does not configure automatic reporting to
FluffyChat's crash service or silently add Sentry/Crashlytics.

User-opened links, retained upstream help pages, map tiles and other optional
external resources contact their respective providers. See
[EXTERNAL_SERVICES.md](EXTERNAL_SERVICES.md). Future app-store platform telemetry
is governed by the applicable Apple/Google settings and terms.

Logs can contain operational identifiers. Review and redact logs before sharing
an issue; never post access tokens, push tokens, passwords, or private keys.

## Contact and publication

For account access, deletion, retention, or privacy questions, use your established
Roadmatics administrator/support channel. A confirmed public privacy contact and
stable Roadmatics-owned policy URL are required before store publication. The
GitHub version of this document is a temporary publication location.
