<!--
SPDX-FileCopyrightText: 2019-Present Christian Kußowski
SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
SPDX-FileCopyrightText: 2026 Roadmatics Technologies
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Roadmatics Chat

Roadmatics Chat is a Roadmatics-branded mobile Matrix client, based on
[FluffyChat](https://github.com/krille-chan/fluffychat). It connects to
**https://matrix.roadmatics.com**, with Matrix identities such as
`@username:roadmatics.com`. Accounts are created by Roadmatics administrators.

Android-first release version: **0.1.0+1**. Android application ID and prepared
iOS bundle ID: **com.roadmatics.chat**. The blue/cyan cube-chat logo replaces the
initial RC placeholder; [logo sources and exports](assets/roadmatics/README.md)
are included.
See [BUILD_REPORT.md](BUILD_REPORT.md) for verified artifacts and outstanding
acceptance tests; feature availability is not a claim of completed testing.

## Source and licence

Source: https://github.com/sensudipta/roadmatics-chat

Roadmatics Chat and these modifications are distributed under
**AGPL-3.0-or-later**. Preserve [LICENSE](LICENSE), [LICENSES](LICENSES/), SPDX
headers, [REUSE.toml](REUSE.toml), and upstream copyright notices when distributing.
Roadmatics did not author FluffyChat. Original history and third-party attribution
are retained; [UPSTREAM_README.md](UPSTREAM_README.md) preserves the upstream
project description, credits, and documentation as a historical reference.

Roadmatics CRM, GPS, service, sales, and automation backends are separate systems
and are not part of this repository. This client contains no Roadmatics business
workflows. Publish matching source whenever distributing a modified binary.

## Build and configuration

- [Android build and signing](ANDROID_BUILD.md)
- [Firebase setup](FIREBASE_SETUP.md)
- [Separate Matrix push gateway](PUSH_GATEWAY.md)
- [Privacy](PRIVACY.md)
- [Play and future iOS checklist](PUBLICATION_CHECKLIST.md)
- [Upstream baseline and toolchain](UPSTREAM_BASE.md)
- [Roadmatics change map](ROADMATICS_CHANGES.md)
- [External service audit](EXTERNAL_SERVICES.md)

Firebase client configuration, server credentials, and signing material are not
stored in the current source tree. Use the ignored local configuration paths in
the build guide. The upload key must remain stable and securely backed up.

Homeserver selection and registration are disabled in the Roadmatics login flow.
The login and push endpoints are fixed even if stored advanced settings contain
older values. Password login keeps full Matrix IDs on the configured Roadmatics
endpoint. FCM requires the separate Sygnal service; client Firebase configuration
alone cannot deliver Matrix push notifications.

## Upstream synchronization

Keep the fork shallow. Inspect a new stable release and its notes first:

```bash
git fetch upstream --tags
git checkout main
git switch -c upstream/<version>
git merge <new-upstream-stable-tag-or-commit>
```

Resolve only intentional Roadmatics differences using `ROADMATICS_CHANGES.md`.
Run analysis, focused regression tests, Android builds, signature/secret checks,
and device acceptance. Merge the tested branch into Roadmatics `main`. Do not
blindly merge upstream development `main` or push all upstream refs to `origin`.
