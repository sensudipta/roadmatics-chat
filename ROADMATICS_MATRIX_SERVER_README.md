# Roadmatics Matrix Server — Operations README

**Server:** `roadmatics-matrix`  
**Hostname:** `matrix`  
**OS:** Ubuntu 24.04 LTS  
**Instance:** AWS EC2 `t3a.medium`  
**Matrix server name:** `roadmatics.com`  
**Synapse URL:** `https://matrix.roadmatics.com`  
**Element Web:** `https://chat.roadmatics.com`  
**Database:** PostgreSQL 16  
**Media:** Local cache + Amazon S3 (`roadmatics-matrix-media`)  
**Synapse:** Native package installation, no Docker

---

# 1. Important paths

## Synapse

Main config:

```bash
/etc/matrix-synapse/homeserver.yaml
```

Roadmatics override configs:

```bash
/etc/matrix-synapse/conf.d/
```

Important files currently include:

```text
/etc/matrix-synapse/conf.d/server_name.yaml
/etc/matrix-synapse/conf.d/database.yaml
/etc/matrix-synapse/conf.d/network.yaml
/etc/matrix-synapse/conf.d/secrets.yaml
/etc/matrix-synapse/conf.d/registration.yaml
/etc/matrix-synapse/conf.d/user_directory.yaml
/etc/matrix-synapse/conf.d/rooms.yaml
/etc/matrix-synapse/conf.d/media_s3.yaml
```

Registration secret:

```bash
/etc/matrix-synapse/registration.secret
```

**Do not copy registration/database/secret files into Git or public storage.**

---

## Element Web

Element installation:

```bash
/usr/share/element-web
```

Element configuration:

```bash
/etc/element-web/config.json
```

Validate Element JSON after editing:

```bash
python3 -m json.tool /etc/element-web/config.json >/dev/null
```

No output means valid JSON.

---

## nginx

Matrix site:

```bash
/etc/nginx/sites-available/matrix.roadmatics.com
```

Element site:

```bash
/etc/nginx/sites-available/chat.roadmatics.com
```

Enabled sites:

```bash
/etc/nginx/sites-enabled/
```

---

## Media / S3

Local Synapse media cache:

```bash
/var/lib/matrix-synapse/media
```

S3 cleanup working directory:

```bash
/var/lib/matrix-synapse/s3-cleanup
```

S3 bucket:

```text
roadmatics-matrix-media
```

Cleanup timer/service:

```bash
/etc/systemd/system/matrix-s3-cleanup.service
/etc/systemd/system/matrix-s3-cleanup.timer
```

Current policy:

```text
S3 copy: immediate / permanent
Local hot media: 90 days since last access
Cleanup: daily
```

---

# 2. Create a Matrix user

Normal user creation remains admin-controlled.

Run:

```bash
sudo register_new_matrix_user \
  -c /etc/matrix-synapse/homeserver.yaml \
  -c /etc/matrix-synapse/conf.d/registration.yaml \
  http://127.0.0.1:8008
```

Prompts:

```text
New user localpart: username
Password:
Confirm password:
Make admin [no]:
```

For a normal employee:

```text
Make admin [no]: no
```

For a Synapse administrator:

```text
Make admin [no]: yes
```

The final Matrix ID will be:

```text
@username:roadmatics.com
```

Example:

```text
@sudipta:roadmatics.com
@indrani:roadmatics.com
```

---

# 3. Restart / status commands

## Synapse

Restart:

```bash
sudo systemctl restart matrix-synapse
```

Status:

```bash
systemctl status matrix-synapse --no-pager -l
```

Quick check:

```bash
systemctl is-active matrix-synapse
```

Expected:

```text
active
```

Recent logs:

```bash
sudo journalctl -u matrix-synapse -n 100 --no-pager
```

Live logs:

```bash
sudo journalctl -u matrix-synapse -f
```

---

## nginx

Validate configuration before reload:

```bash
sudo nginx -t
```

Reload after configuration changes:

```bash
sudo systemctl reload nginx
```

Restart if needed:

```bash
sudo systemctl restart nginx
```

Status:

```bash
systemctl status nginx --no-pager
```

---

## PostgreSQL

Status:

```bash
systemctl status postgresql --no-pager
```

Restart:

```bash
sudo systemctl restart postgresql
```

Normally PostgreSQL should not need manual restarts.

---

# 4. Validate Synapse config before restart

Run from a directory readable by the `matrix-synapse` user.

Use `/tmp`:

```bash
cd /tmp
```

Then:

```bash
sudo -u matrix-synapse \
  /opt/venvs/matrix-synapse/bin/python \
  -m synapse.app.homeserver \
  --config-path=/etc/matrix-synapse/homeserver.yaml \
  --config-path=/etc/matrix-synapse/conf.d/ \
  --generate-keys
```

If it returns to the prompt with no error, the config parsed successfully.

Then:

```bash
sudo systemctl restart matrix-synapse
```

Do **not** run this validation command from `/home/ubuntu`; the service user may not have permission to inspect that working directory.

---

# 5. Check Matrix API

Local Synapse:

```bash
curl -s http://127.0.0.1:8008/_matrix/client/versions | head -c 300
echo
```

Public HTTPS endpoint:

```bash
curl -s https://matrix.roadmatics.com/_matrix/client/versions | head -c 300
echo
```

If both return JSON containing:

```text
"versions"
```

the Matrix client API is responding.

---

# 6. Check listening ports

Synapse should listen only on localhost port 8008:

```bash
sudo ss -ltnp | grep 8008
```

Expected:

```text
127.0.0.1:8008
[::1]:8008
```

PostgreSQL should not be publicly exposed.

AWS Security Group should normally expose only:

```text
22   SSH     restricted admin IP(s)
80   HTTP    public
443  HTTPS   public
```

Do **not** expose:

```text
5432 PostgreSQL
8008 Synapse internal listener
8448 Matrix federation
```

unless the architecture is deliberately changed later.

---

# 7. Element Web checks

Check served config:

```bash
curl -s https://chat.roadmatics.com/config.json | python3 -m json.tool | head -60
```

After modifying:

```bash
/etc/element-web/config.json
```

validate:

```bash
python3 -m json.tool /etc/element-web/config.json >/dev/null
```

Then normally no service restart is required because Element Web is static content.

Use a hard browser refresh if config appears stale:

```text
Ctrl + Shift + R
```

---

# 8. TLS / Let's Encrypt certificates

Show certificates:

```bash
sudo certbot certificates
```

Test automatic renewal:

```bash
sudo certbot renew --dry-run
```

Certificates currently cover:

```text
matrix.roadmatics.com
chat.roadmatics.com
```

Certbot/systemd normally handles renewal automatically.

---

# 9. S3 media storage checks

Confirm EC2 IAM role:

```bash
aws sts get-caller-identity
```

Expected ARN should contain:

```text
assumed-role/roadmatics-matrix-ec2-role/
```

List recent media objects:

```bash
aws s3 ls s3://roadmatics-matrix-media --recursive | tail -20
```

Check local media size:

```bash
sudo du -sh /var/lib/matrix-synapse/media 2>/dev/null || echo "Local media cache currently empty"
```

The S3 storage provider version:

```bash
/opt/venvs/matrix-synapse/bin/pip show synapse-s3-storage-provider | grep -E "Name|Version"
```

Current expected version:

```text
synapse-s3-storage-provider 1.7.0
```

---

# 10. S3 local-media cleanup

## Check timer

```bash
systemctl status matrix-s3-cleanup.timer --no-pager
```

Show next run:

```bash
systemctl list-timers matrix-s3-cleanup.timer
```

## Run cleanup manually

This uses the configured 90-day local retention period:

```bash
sudo systemctl start matrix-s3-cleanup.service
```

Check result:

```bash
systemctl status matrix-s3-cleanup.service --no-pager
```

Because it is a `Type=oneshot` service, a successful run may finish as:

```text
inactive (dead)
```

with:

```text
status=0/SUCCESS
```

View logs:

```bash
sudo journalctl -u matrix-s3-cleanup.service -n 100 --no-pager
```

---

# 11. Manual S3 cleanup command

Normally use the systemd service above.

If manual commands are ever needed:

```bash
sudo -u matrix-synapse bash -lc '
cd /var/lib/matrix-synapse/s3-cleanup &&
/opt/venvs/matrix-synapse/bin/s3_media_upload \
update /var/lib/matrix-synapse/media 90d
'
```

Then:

```bash
sudo -u matrix-synapse bash -lc '
cd /var/lib/matrix-synapse/s3-cleanup &&
AWS_REGION=ap-south-1 AWS_DEFAULT_REGION=ap-south-1 \
/opt/venvs/matrix-synapse/bin/s3_media_upload \
upload \
/var/lib/matrix-synapse/media \
roadmatics-matrix-media \
--storage-class STANDARD \
--delete
'
```

Do **not** change `90d` to `0d` during normal operation.

`0d` was used only during initial testing.

---

# 12. Server health checks

RAM:

```bash
free -h
```

Disk:

```bash
df -h /
```

Swap:

```bash
swapon --show
```

Current swap:

```text
2 GB /swapfile
```

CPU/load:

```bash
uptime
```

Top processes:

```bash
top
```

or:

```bash
ps aux --sort=-%mem | head -20
```

---

# 13. Basic service health summary

Useful one-liner:

```bash
echo "Synapse:    $(systemctl is-active matrix-synapse)"
echo "nginx:      $(systemctl is-active nginx)"
echo "Postgres:   $(systemctl is-active postgresql)"
echo "S3 timer:   $(systemctl is-active matrix-s3-cleanup.timer)"
```

---

# 14. Ubuntu / package maintenance

Check updates:

```bash
sudo apt update
apt list --upgradable
```

Apply updates:

```bash
sudo apt full-upgrade -y
```

Remove unused packages:

```bash
sudo apt autoremove -y
```

Check whether reboot is needed:

```bash
test -f /var/run/reboot-required \
  && cat /var/run/reboot-required \
  || echo "No reboot required"
```

If required:

```bash
sudo reboot
```

After reconnecting:

```bash
systemctl is-active matrix-synapse
systemctl is-active nginx
systemctl is-active postgresql
```

Also check:

```bash
curl -s https://matrix.roadmatics.com/_matrix/client/versions | head -c 200
echo
```

---

# 15. Synapse / Element package versions

Synapse:

```bash
dpkg -l | grep matrix-synapse
```

Element:

```bash
dpkg -l | grep element-web
```

PostgreSQL:

```bash
psql --version
```

nginx:

```bash
nginx -v
```

---

# 16. PostgreSQL sanity checks

Check database:

```bash
sudo -u postgres psql -d synapse -c \
"SELECT datname, pg_encoding_to_char(encoding), datcollate, datctype
FROM pg_database
WHERE datname='synapse';"
```

Expected:

```text
synapse | UTF8 | C | C
```

Check table count:

```bash
sudo -u postgres psql -d synapse -c \
"SELECT count(*) AS tables
FROM information_schema.tables
WHERE table_schema='public';"
```

Do not modify Synapse tables manually unless there is a specific recovery procedure.

---

# 17. User search

All local users are intended to be searchable.

Config:

```bash
/etc/matrix-synapse/conf.d/user_directory.yaml
```

Current intended settings:

```yaml
user_directory:
  enabled: true
  search_all_users: true
  prefer_local_users: true
  exclude_remote_users: true
```

After changing Synapse YAML:

1. validate config;
2. restart `matrix-synapse`.

---

# 18. Encryption reminder

Operational rooms intended for CRM/bots/automation should be created **without end-to-end encryption**.

Examples:

```text
Sales
Service
Fieldwork
Inventory
HR workflow rooms
```

Reason:

Server-side automation cannot normally read end-to-end encrypted room messages.

Important:

> Once E2EE is enabled for a Matrix room, it cannot later be disabled for that same room.

Private staff DMs or informal rooms can use encryption if desired.

---

# 19. AWS / EC2 reminders

Instance:

```text
t3a.medium
2 vCPU
4 GiB RAM
30 GB gp3
```

Media bucket:

```text
roadmatics-matrix-media
```

IAM role:

```text
roadmatics-matrix-ec2-role
```

Do not create long-lived AWS access keys on this server for S3.

The S3 provider should use temporary credentials from the EC2 IAM role.

---

# 20. Important security rules

Never place these in GitHub or public files:

```text
/etc/matrix-synapse/registration.secret
PostgreSQL password
macaroon secret
Firebase Admin service-account JSON
APNs keys
Android signing keystore
AWS access keys
Matrix admin tokens
```

Do not make the S3 media bucket public.

Do not expose PostgreSQL or Synapse port 8008 publicly.

---

# 21. Database backup — IMPORTANT

**S3 media storage is not a database backup.**

Messages, users, rooms, memberships, event state, etc. live in PostgreSQL.

A proper automated PostgreSQL backup system should be configured separately.

Until automated backups are configured, do not assume the Matrix installation is fully protected against database loss.

Useful manual dump command:

```bash
sudo -u postgres pg_dump \
  -Fc \
  -d synapse \
  -f /tmp/synapse-$(date +%Y%m%d-%H%M%S).dump
```

Check:

```bash
ls -lh /tmp/synapse-*.dump
```

This creates a local backup only.

A proper scheduled backup destination should be configured later, preferably a separate private S3 backup bucket with retention/versioning rules.

---

# 22. Quick troubleshooting sequence

If users report Matrix is down:

```bash
systemctl is-active matrix-synapse
systemctl is-active nginx
systemctl is-active postgresql
```

Then:

```bash
curl -s http://127.0.0.1:8008/_matrix/client/versions | head -c 200
echo
```

Then:

```bash
curl -s https://matrix.roadmatics.com/_matrix/client/versions | head -c 200
echo
```

If local works but public does not:

Check nginx:

```bash
sudo nginx -t
sudo journalctl -u nginx -n 100 --no-pager
```

If Synapse is not active:

```bash
sudo journalctl -u matrix-synapse -n 200 --no-pager
```

If disk is full:

```bash
df -h /
sudo du -sh /var/lib/matrix-synapse/* 2>/dev/null
```

If S3 media is suspected:

```bash
aws sts get-caller-identity
aws s3 ls s3://roadmatics-matrix-media --recursive | tail -20
```

---

# 23. Current architecture

```text
Internet
   |
   +--> https://chat.roadmatics.com
   |         |
   |         +--> nginx
   |                |
   |                +--> Element Web static files
   |
   +--> https://matrix.roadmatics.com
             |
             +--> nginx
                    |
                    +--> 127.0.0.1:8008
                              |
                              +--> Synapse
                                     |
                                     +--> PostgreSQL
                                     |
                                     +--> local media cache
                                     |
                                     +--> S3 roadmatics-matrix-media
```

Future push architecture:

```text
Synapse
   |
   +--> Sygnal on localhost
            |
            +--> Firebase Cloud Messaging
                      |
                      +--> Roadmatics Chat mobile app
```

---

# 24. Normal maintenance checklist

A reasonable monthly manual check:

```text
[ ] apt update / review pending upgrades
[ ] check disk usage
[ ] check RAM/swap
[ ] check Synapse/nginx/PostgreSQL status
[ ] check certbot certificates
[ ] check S3 cleanup timer
[ ] check S3 bucket is receiving media
[ ] verify Matrix web login
[ ] verify mobile push once Sygnal is installed
[ ] verify PostgreSQL backup system once configured
```

---

# 25. Handy commands summary

```bash
# Create user
sudo register_new_matrix_user \
  -c /etc/matrix-synapse/homeserver.yaml \
  -c /etc/matrix-synapse/conf.d/registration.yaml \
  http://127.0.0.1:8008

# Restart Synapse
sudo systemctl restart matrix-synapse

# Synapse logs
sudo journalctl -u matrix-synapse -n 100 --no-pager

# nginx config test + reload
sudo nginx -t && sudo systemctl reload nginx

# Check Matrix
curl -s https://matrix.roadmatics.com/_matrix/client/versions | head -c 200
echo

# Disk / RAM
df -h /
free -h

# Certificates
sudo certbot certificates

# S3 objects
aws s3 ls s3://roadmatics-matrix-media --recursive | tail -20

# S3 cleanup timer
systemctl list-timers matrix-s3-cleanup.timer

# Run cleanup now
sudo systemctl start matrix-s3-cleanup.service

# Check cleanup logs
sudo journalctl -u matrix-s3-cleanup.service -n 100 --no-pager
```

---

**Last updated:** 2026-09-28  
**Purpose:** Internal Roadmatics Matrix server operations reference.
