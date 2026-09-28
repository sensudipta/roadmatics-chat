<!-- SPDX-FileCopyrightText: 2026 Roadmatics Technologies -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Public source security audit

Scanner: Gitleaks 8.30.1, redacted reports kept outside the repository.
Do not include secrets or raw scan matches in issues, commits, or build reports.
Final scan status and the exact publication gate are in `BUILD_REPORT.md`.

## Reviewed upstream history

The unfiltered v2.9.1 history scan examined 8,550 commits and found eight entries:

- Six `macos/Podfile.lock` dependency checksums misclassified by the generic
  API-key detector (the dependency names include `auth`).
- One historical pushkey example in upstream `PRIVACY.md`.
- One historical Firebase **client** API key in upstream
  `android/app/google-services.json`, already public in the upstream repository.
  It is not Roadmatics' Firebase configuration or a Firebase Admin credential.

`.gitleaksignore` records only the exact commit/path/rule/line fingerprints for
these eight reviewed findings. It does not disable secret rules or exclude whole
files/commits. History is retained for AGPL attribution and upstream merges.
The current upstream iOS Firebase client config is removed from this fork's head.

## Roadmatics controls

- Upload keystore and password are outside the repository in a protected local
  directory; real `android/key.properties` is ignored and mode `0600`.
- `google-services.json`, `GoogleService-Info.plist`, keystores, APNs keys,
  service-account patterns and private `.env` files are ignored.
- No Firebase Admin key, APNs key, AWS credential or Matrix admin token is needed
  for source compilation or supplied to the client.
- Release signing cannot fall back to the debug certificate.
- CI contains no signing credentials or Firebase configuration.

Before every public push, scan the exact committed history and an export of the
tracked source, check `git ls-files` and staged paths, verify ignored credential
paths, and inspect the final diff. Ignore files are not a substitute for scanning.

```bash
gitleaks git --redact --log-opts=HEAD
git diff --cached --name-status
git diff --cached --check
git ls-files '*google-services.json' '*GoogleService-Info.plist' '*.jks' '*.keystore' '*.p8' '*key.properties'
git check-ignore android/key.properties android/app/google-services.json
```

Do not push all upstream branches/tags. Publish only the audited Roadmatics refs.
