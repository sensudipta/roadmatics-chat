<!-- SPDX-FileCopyrightText: 2026 Roadmatics Technologies -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Roadmatics push gateway

Sygnal v0.17.0 is now installed on the existing Matrix host and its localhost
health check passes. Firebase service-account authentication and FCM token
validation pass. Synapse still blocks localhost, so delivery remains pending
explicit approval for the exception and restart. See the
[deployment record](deploy/sygnal/README.md) for evidence and rollback.

## Contract

The phone registers its FCM token and gateway URL with Synapse. **Synapse calls
the gateway**, not the phone. The initial deployment is native Sygnal on the
existing Matrix EC2 host, listening only on `127.0.0.1:5000`.

- Gateway: `http://127.0.0.1:5000/_matrix/push/v1/notify`
- Android package: `com.roadmatics.chat`
- Pusher app ID: `com.roadmatics.chat.<Matrix device ID>` (upstream suffix retained)
- Sygnal application pattern: `com.roadmatics.chat.*`
- Pusher format: `event_id_only`; retain upstream data-message payload behavior.

Sygnal supports app-ID pattern matching. Retaining device-specific IDs preserves
upstream multi-account behavior. A read-only server check confirmed one registered Roadmatics pusher using this
ID pattern, URL and payload format on the sideloaded release.

No DNS record, public listener, nginx route, certificate, or EC2 inbound port is
required. The earlier public endpoint suggestion in PRD section 12 is superseded
by section 25. A future remote gateway requires a deliberate HTTPS migration.

## Deployment prerequisites

1. Matching Firebase Android client configuration is present locally.
2. The release app initializes Firebase and obtains an FCM token on a phone.
3. The Firebase project owner creates a Firebase Admin service-account JSON:
   Firebase Console → Project settings → Service accounts → Generate new private
   key. Transfer it directly to the Matrix host using a secure channel. Never put
   it in this repository or paste its contents into chat.
4. Confirm the existing Matrix host, access method, service topology, and Synapse
   version. A container or separate network namespace changes the meaning of
   `127.0.0.1`; the push worker must share Sygnal's loopback namespace.
5. Inspect Synapse's effective outbound IP policy. Its default `ip_range_blacklist`
   blocks `127.0.0.0/8`, including push servers. A narrow exception may be needed.
   The PRD excludes Synapse changes: obtain explicit authorization for the exact
   configuration change and restart if an exception is missing. Do not disable
   the general blacklist. An IP allowlist applies beyond this single port.

## Server configuration

The installed release, source hash, dependency snapshot and full configuration
are in [deploy/sygnal](deploy/sygnal/README.md). The following abbreviated example
shows the configuration shape:

```yaml
http:
  bind_addresses: ['127.0.0.1']
  port: 5000
apps:
  'com.roadmatics.chat.*':
    type: gcm
    api_version: v1
    project_id: REPLACE_WITH_FIREBASE_PROJECT_ID
    service_account_file: /etc/sygnal/firebase-roadmatics.json
```

Install in a dedicated virtual environment, run as an unprivileged `sygnal`
system user, and use systemd with automatic restart and journald logging. Store
the Admin JSON outside the checkout, owned by root and readable only by the
service group (directory `0750`, credential `0640`, or tighter equivalent).
Enable the FCM HTTP v1 API and validate the service account's sending permissions.
Keep telemetry off. Do not log push tokens, credentials, or message content.

## Acceptance

- Verify loopback-only listening and `/health` from the Matrix host.
- Verify the authenticated Matrix pusher's app ID, URL, and format, redacting token.
- Send a real message from another account and correlate Synapse, Sygnal, FCM,
  and phone delivery; a successful gateway HTTP response alone is insufficient.
- Test foreground, background, removal from recents, and notification tap into
  the correct room. Android force-stop and OEM restrictions can prevent delivery.
- Test the signed release, not only a debug build. Confirm no FluffyChat gateway
  receives the Roadmatics Firebase token.

For iOS later, configure the Roadmatics Apple App ID and APNs key in Firebase,
then validate Sygnal's iOS payload options and notification extension behavior.

## References

- [Sygnal configuration](https://github.com/element-hq/sygnal/blob/main/sygnal.yaml.sample)
- [Sygnal app matching](https://github.com/element-hq/sygnal/blob/main/sygnal/http.py)
- [Synapse outbound IP policy](https://element-hq.github.io/synapse/latest/usage/configuration/config_documentation.html#ip_range_blacklist)
