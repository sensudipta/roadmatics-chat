<!-- SPDX-FileCopyrightText: 2026 Roadmatics Technologies -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# External service audit

Scope: selected FluffyChat v2.9.1 source and Roadmatics mobile changes. Searches
cover `fluffy.chat`, `fluffychat.im`, `push.fluffychat.im`, `crash.fluffy.chat`,
`livekit`, `ko-fi`, `matrix.org`, `recommended_homeservers`,
`chat.fluffy.fluffychat`, and `im.fluffychat`. Source inspection is not a network
capture of an installed app. Repeat device traffic verification before release
acceptance and repeat this audit on every upstream update.

| Occurrence / category | Decision and evidence |
| --- | --- |
| `push.fluffychat.im` production default | Replaced in `lib/config/setting_keys.dart` with the localhost Sygnal URL. Deployment settings ignore stored overrides; FCM uses this setting in `background_push.dart`. |
| `crash.fluffy.chat`, LiveKit fallback | No configured production endpoint found in the selected native client source. No new telemetry service added. Experimental VoIP stays upstream-default off; calls are unverified and outside initial acceptance. |
| Upstream homeserver list | Constant retained for merge compatibility, but `SignInViewModel` returns the Roadmatics server without making the list request when other homeservers are disabled. Login uses the preset endpoint; registration is blocked. |
| `matrix.org` / `matrix.to` protocol references | Keep specification links and standard Matrix room/user links. No matrix.org login recommendation remains in the Roadmatics flow. |
| `fluffychat.im/faq/...` tutorials | Intentionally retain the four user-opened push/E2EE/chat/sticker help links in `AppConfig`. These do not register tokens or send crash reports. Review for relevance when Roadmatics help is available. |
| Source/support/release/privacy links | Point current app links at the Roadmatics repository. About view retains FluffyChat attribution. The update dialog compares locally installed versions; it does not fetch upstream GitHub releases. |
| `ko-fi`, upstream website, banner, community references | Historical attribution/documentation in `UPSTREAM_README.md`, changelog, metadata, and history. Not Roadmatics launcher/onboarding branding. |
| `chat.fluffy.fluffychat` legacy pusher IDs | Retained only to recognize/remove legacy pushers, not to register new Roadmatics pushers. New base is `com.roadmatics.chat`, with upstream's per-device suffix. |
| `im.fluffychat.*` storage / Matrix event names | Internal preferences, client database namespace, account bundles/configuration and custom event types retained to avoid unnecessary protocol/storage changes. Mobile bundle IDs, App Groups and URL schemes use Roadmatics. Kotlin source directory and internal Dart package remain upstream-named. |
| Original artwork | Original assets/copyright remain in history/source for attribution. Active mobile icons, splash, notification glyph, login, about, lock and empty screens use isolated Roadmatics RC assets. Desktop/web packaging remains outside this mobile milestone. |
| Firebase | Explicit dependency for Roadmatics push; matching Android configuration is local and ignored. Upstream tracked iOS Firebase client config removed from current tree. Historical upstream client keys are not Roadmatics server credentials. |
| UnifiedPush | Optional upstream non-FCM route retained. Its public gateway applies to a user-selected UnifiedPush endpoint, not Roadmatics FCM tokens. |
| Map tiles, URLs and Matrix federation | Upstream optional features can contact their providers or remote media/servers. This is not a blanket offline or single-domain network promise. |

`PUSH_GATEWAY.md` records the server prerequisite and Synapse loopback policy
issue. No AWS, Synapse, database, S3, DNS or Element configuration was changed.
