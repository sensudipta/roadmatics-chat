<!-- SPDX-FileCopyrightText: 2026 Roadmatics Technologies -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Matrix host deployment — 2026-09-29

Sygnal is installed on SSH alias `matrix` (Ubuntu 24.04, Python 3.12.3).
It runs natively as system user `sygnal`; no Docker or public listener was added.
The user explicitly approved the localhost Synapse exception and restart.
That exception is installed. The user confirmed background notification arrival
and that tapping it opens the correct room after the startup fix below.

## Installed artifacts

- `sygnal.yaml` → `/etc/sygnal/sygnal.yaml` (`root:sygnal`, `0640`).
- `sygnal.service` → `/etc/systemd/system/sygnal.service` (`root:root`, `0644`).
- Virtual environment: `/opt/sygnal/venv`, owned by root.
- `run_sygnal.py` → `/opt/sygnal/run_sygnal.py` (`root:root`, `0644`).
  The service uses this entrypoint to run upstream Sygnal on one shared reactor.
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

## Runtime POST stall and verified correction

The first real-message test timed out between Synapse and Sygnal. A successful
FCM validate-only request had used a different HTTP transport, so it had not
exercised this runtime path. OAuth refresh and isolated TLS probes passed.

Sygnal v0.17.0 installs a global Twisted asyncio reactor but creates a second
reactor to run the service. Its HTTP body producer uses the global reactor.
A no-credential, no-delivery POST probe reproduced a timeout with that two-reactor
arrangement; the same POST completed promptly with HTTP 401 when using one
shared reactor (401 was expected without credentials).

The small `run_sygnal.py` entrypoint installs one reactor and passes it to
upstream `Sygnal`, retaining its config loader and push-handling implementation.
No dependency downgrade or package-cache source modification was needed. The
unit now invokes this launcher. After restarting only Sygnal, Synapse retried
the queued notification, the gateway returned HTTP 200, and the pusher recorded
`last_success` with `failing_since` cleared. The phone log reached event loading
and push-helper completion without a crash. The user confirmed notification
arrival and navigation to the correct room on tap.

The empty-device diagnostic request returned HTTP 400; this was an intentional
malformed request and is separate from the successful real notification.

## Approved Synapse exception — installed

The user authorized the exact localhost exception and brief restart on
2026-09-29. The live allowlist and absence of the destination file were rechecked
before installing `/etc/matrix-synapse/conf.d/roadmatics-push.yaml`
(`root:matrix-synapse`, `0640`):

```yaml
ip_range_whitelist:
  - '127.0.0.1/32'
```

The installed Synapse parser validated the merged configuration. It allows
`127.0.0.1` while still blocking `127.0.0.2`, `169.254.169.254`, and `10.0.0.1`.
Synapse was restarted successfully. Both local and public Matrix client versions
endpoints returned HTTP 200, Sygnal health returned 200, and both services were
active with no automatic restarts at verification time.

This IP exception applies to all ports on `127.0.0.1` and to outbound request
types governed by this policy, including federation. It cannot be restricted to
Sygnal's port by this setting. No inbound firewall, nginx, DNS or TLS change was
made. Existing Synapse files were not replaced. The activation procedure had an
automatic rollback if validation, restart, or health verification failed;
rollback was not needed.

Background delivery, notification tap, and delivery after removal from recents
are user-confirmed. Tapping opened the correct room in both background cases.
Foreground-specific notification behavior remains a separate acceptance check.
The user initiates test Matrix messages; no Matrix messages were sent by automation.

## Gateway rollback

`sudo systemctl disable --now sygnal` stops only the new gateway. Keep the
credential protected for later reuse or arrange deliberate credential removal.
To undo the approved Synapse exception, remove only
`/etc/matrix-synapse/conf.d/roadmatics-push.yaml` and restart `matrix-synapse` to
restore the previous outbound policy. Verify the client API after rollback.
