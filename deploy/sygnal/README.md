<!-- SPDX-FileCopyrightText: 2026 Roadmatics Technologies -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Matrix host deployment — 2026-09-29

Sygnal is installed on SSH alias `matrix` (Ubuntu 24.04, Python 3.12.3).
It runs natively as system user `sygnal`; no Docker or public listener was added.
Synapse remains unchanged. End-to-end notification delivery is not yet accepted.

## Installed artifacts

- `sygnal.yaml` → `/etc/sygnal/sygnal.yaml` (`root:sygnal`, `0640`).
- `sygnal.service` → `/etc/systemd/system/sygnal.service` (`root:root`, `0644`).
- Virtual environment: `/opt/sygnal/venv`, owned by root.
- Firebase Admin credential: `/etc/sygnal/firebase-roadmatics.json`
  (`root:sygnal`, `0640`, parent directory `0750`). Never commit this file.
- Upstream v0.17.0, commit `53c25a82f85739eb58f2c95b9483f61ac8deedc4`.
  `requirements.txt` pins the source URL and SHA256; `requirements-frozen.txt` captures
  the validated dependency versions. The distribution is named `matrix-sygnal`.
- systemd service enabled, automatic restart on failure, logs in journald.
- Listener: only `127.0.0.1:5000`; external telemetry and metrics disabled.

GCM and dispatch exception logs are suppressed because upstream paths can log
registration tokens or provider payloads. Access logs retain HTTP status and
timing; do not enable debug logs with real device tokens.

For a future rebuild in a dedicated virtual environment:

```bash
/opt/sygnal/venv/bin/pip install -r requirements-frozen.txt
/opt/sygnal/venv/bin/pip check
```

Do not install dependencies into Synapse's environment. Preserve the existing
credential and upload it through SSH without displaying it. Validate the unit
with `systemd-analyze verify`, then reload systemd and restart only Sygnal after
an intentional gateway update.

## Verified

- Synapse 1.161.0 runs as a native service with `PrivateNetwork=no`.
- A read-only PostgreSQL transaction found one Roadmatics pusher with the
  expected app-ID prefix, localhost URL, `event_id_only`, and `data_message=true`.
  Token and account identifiers were not printed.
- `pip check` and systemd unit validation passed.
- Service active with no restarts during the initial check.
- `GET http://127.0.0.1:5000/health` returned 200.
- Synapse's client versions endpoint remained 200.
- Firebase service-account authentication passed. FCM HTTP v1 returned 200 for
  `validate_only=true` using the registered device token. This did not deliver a
  notification and is not evidence of end-to-end push delivery.

## Pending Synapse exception — requires explicit approval

The live Synapse allowlist is empty. Its effective blocklist blocks `127.0.0.1`.
The proposed file `synapse-local-push.yaml.example` would be installed as:

`/etc/matrix-synapse/conf.d/roadmatics-push.yaml`

```yaml
ip_range_whitelist:
  - '127.0.0.1/32'
```

The installed Synapse parser accepted this candidate, loaded from a temporary
file alongside the real configuration. It allowed `127.0.0.1` while still
blocking `127.0.0.2`, `169.254.169.254`, and `10.0.0.1`. The temporary file was
removed; the candidate was not installed and Synapse was not restarted.

This IP exception applies to all ports on `127.0.0.1` and to outbound request
types governed by this policy, including federation. It cannot be restricted to
Sygnal's port by this setting. No inbound firewall, nginx, DNS or TLS change is
needed. The PRD section 3 says "Change Synapse" is out of scope, so applying this
exception and restarting `matrix-synapse` needs explicit user authorization.
A restart briefly interrupts Matrix connections.

After approval: recheck that the allowlist and candidate destination are
unchanged; install the candidate with appropriate owner/read permissions;
validate the merged configuration; restart `matrix-synapse`; verify service and
client API health. If health fails, remove only the newly installed candidate
file and restart Synapse to restore the previous policy. Existing Synapse files
are not replaced.

Then validate notifications from another real Matrix account in foreground,
background, after removal from recents, and on notification tap. The user must
initiate test messages; no messages have been sent by this deployment.

## Gateway rollback

`sudo systemctl disable --now sygnal` stops only the new gateway. Keep the
credential protected for later reuse or arrange deliberate credential removal.
If the Synapse exception was separately approved and installed, remove that
single drop-in and restart Synapse to restore the previous outbound policy.
