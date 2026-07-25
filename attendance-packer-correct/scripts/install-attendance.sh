#!/usr/bin/env bash
set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

APP_REPO="${APP_REPO:-https://github.com/OT-MICROSERVICES/attendance-api.git}"
APP_REF="${APP_REF:-main}"
POETRY_VERSION="${POETRY_VERSION:-1.8.5}"

APP_DIR="/opt/attendance-api"
APP_USER="attendance"
APP_GROUP="attendance"
APP_PORT="8081"
CONFIG_DIR="/etc/attendance-api"

log() {
  printf '\n[%s] %s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "$*"
}

retry() {
  local attempts="$1"
  local delay="$2"
  shift 2

  local count=1
  until "$@"; do
    if (( count >= attempts )); then
      return 1
    fi

    log "Command failed. Retry ${count}/${attempts} in ${delay}s: $*"
    sleep "$delay"
    ((count++))
  done
}

if [[ "${EUID}" -ne 0 ]]; then
  echo "This script must run as root." >&2
  exit 1
fi

log "Updating package metadata"
retry 5 10 apt-get update -y

log "Installing operating-system dependencies"
apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  wget \
  git \
  gnupg \
  lsb-release \
  software-properties-common \
  build-essential \
  gcc \
  make \
  libpq-dev \
  postgresql-client \
  redis-tools \
  awscli \
  jq

log "Installing Python 3.11"
if ! apt-cache show python3.11 >/dev/null 2>&1; then
  add-apt-repository -y ppa:deadsnakes/ppa
  retry 5 10 apt-get update -y
fi

apt-get install -y --no-install-recommends \
  python3.11 \
  python3.11-dev \
  python3.11-venv

python3.11 --version

log "Creating Attendance service account"
if ! getent group "${APP_GROUP}" >/dev/null; then
  groupadd --system "${APP_GROUP}"
fi

if ! id "${APP_USER}" >/dev/null 2>&1; then
  useradd \
    --system \
    --gid "${APP_GROUP}" \
    --home-dir "${APP_DIR}" \
    --shell /usr/sbin/nologin \
    "${APP_USER}"
fi

log "Cloning Attendance API"
rm -rf "${APP_DIR}"
git clone \
  --branch "${APP_REF}" \
  --single-branch \
  "${APP_REPO}" \
  "${APP_DIR}"
rm -rf "${APP_DIR}/.git"

log "Installing Poetry ${POETRY_VERSION}"
rm -rf /opt/poetry
python3.11 -m venv /opt/poetry
/opt/poetry/bin/pip install --no-cache-dir --upgrade pip setuptools wheel
/opt/poetry/bin/pip install --no-cache-dir "poetry==${POETRY_VERSION}"
ln -sf /opt/poetry/bin/poetry /usr/local/bin/poetry

log "Installing Attendance API dependencies"
cd "${APP_DIR}"
poetry config virtualenvs.in-project true --local
poetry env use /usr/bin/python3.11
poetry install --no-root --no-interaction --no-ansi

if ! poetry run gunicorn --version >/dev/null 2>&1; then
  poetry run pip install --no-cache-dir "gunicorn==22.0.0"
fi

log "Creating runtime configuration directory"
install -d -o root -g "${APP_GROUP}" -m 0750 "${CONFIG_DIR}"

cat > "${CONFIG_DIR}/attendance.env.example" <<'ENV'
# These values are supplied by Launch Template user-data when EC2 starts.

# AWS RDS PostgreSQL
DB_HOST=replace-with-rds-hostname
DB_PORT=5432
DB_NAME=attendance_db
DB_USER=attendance_admin
DB_PASSWORD=replace-at-runtime

# AWS ElastiCache Redis
REDIS_HOST=replace-with-elasticache-primary-endpoint
REDIS_PORT=6379
REDIS_PASSWORD=
ENV

chmod 0640 "${CONFIG_DIR}/attendance.env.example"
chown root:"${APP_GROUP}" "${CONFIG_DIR}/attendance.env.example"

log "Creating Attendance API startup script"
cat > /usr/local/bin/start-attendance-api.sh <<'SCRIPT'
#!/usr/bin/env bash
set -Eeuo pipefail

APP_DIR="/opt/attendance-api"
APP_PORT="${APP_PORT:-8081}"

: "${DB_HOST:?DB_HOST is required}"
: "${DB_NAME:?DB_NAME is required}"
: "${DB_USER:?DB_USER is required}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"
: "${REDIS_HOST:?REDIS_HOST is required}"

DB_PORT="${DB_PORT:-5432}"
REDIS_PORT="${REDIS_PORT:-6379}"
REDIS_PASSWORD="${REDIS_PASSWORD:-}"

export APP_DIR APP_PORT
export DB_HOST DB_PORT DB_NAME DB_USER DB_PASSWORD
export REDIS_HOST REDIS_PORT REDIS_PASSWORD

# The application reads config.yaml. JSON is valid YAML and safely handles
# punctuation in usernames and passwords.
python3.11 <<'PY'
import json
import os
from pathlib import Path

app_dir = Path(os.environ["APP_DIR"])
config = {
    "postgres": {
        "database": os.environ["DB_NAME"],
        "host": os.environ["DB_HOST"],
        "port": int(os.environ["DB_PORT"]),
        "user": os.environ["DB_USER"],
        "password": os.environ["DB_PASSWORD"],
    },
    "redis": {
        "host": os.environ["REDIS_HOST"],
        "port": int(os.environ["REDIS_PORT"]),
        "password": os.environ.get("REDIS_PASSWORD", ""),
    },
}

config_path = app_dir / "config.yaml"
config_path.write_text(json.dumps(config, indent=2) + "\n", encoding="utf-8")
config_path.chmod(0o600)
PY

# Wait for RDS PostgreSQL to accept connections.
for attempt in $(seq 1 60); do
  if pg_isready \
    --host="${DB_HOST}" \
    --port="${DB_PORT}" \
    --dbname="${DB_NAME}" \
    --username="${DB_USER}" >/dev/null 2>&1; then
    break
  fi

  if [[ "${attempt}" -eq 60 ]]; then
    echo "PostgreSQL is not reachable at ${DB_HOST}:${DB_PORT}" >&2
    exit 1
  fi

  sleep 5
done

# Wait for AWS ElastiCache Redis.
for attempt in $(seq 1 60); do
  if [[ -n "${REDIS_PASSWORD}" ]]; then
    if redis-cli \
      --host "${REDIS_HOST}" \
      --port "${REDIS_PORT}" \
      --pass "${REDIS_PASSWORD}" \
      ping 2>/dev/null | grep -q '^PONG$'; then
      break
    fi
  else
    if redis-cli \
      --host "${REDIS_HOST}" \
      --port "${REDIS_PORT}" \
      ping 2>/dev/null | grep -q '^PONG$'; then
      break
    fi
  fi

  if [[ "${attempt}" -eq 60 ]]; then
    echo "Redis is not reachable at ${REDIS_HOST}:${REDIS_PORT}" >&2
    exit 1
  fi

  sleep 5
done

exec "${APP_DIR}/.venv/bin/gunicorn" \
  --workers 2 \
  --threads 2 \
  --timeout 60 \
  --bind "0.0.0.0:${APP_PORT}" \
  --access-logfile - \
  --error-logfile - \
  app:app
SCRIPT

chmod 0755 /usr/local/bin/start-attendance-api.sh

log "Creating systemd service"
cat > /etc/systemd/system/attendance-api.service <<UNIT
[Unit]
Description=OTMS Attendance API
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=${APP_USER}
Group=${APP_GROUP}
WorkingDirectory=${APP_DIR}
EnvironmentFile=${CONFIG_DIR}/attendance.env
Environment=PYTHONUNBUFFERED=1
Environment=APP_PORT=${APP_PORT}
Environment=PATH=${APP_DIR}/.venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
ExecStart=/usr/local/bin/start-attendance-api.sh
Restart=always
RestartSec=5
TimeoutStartSec=330
TimeoutStopSec=30
KillSignal=SIGQUIT
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full
ProtectHome=true
ReadWritePaths=${APP_DIR}

[Install]
WantedBy=multi-user.target
UNIT

log "Setting ownership and permissions"
chown -R "${APP_USER}:${APP_GROUP}" "${APP_DIR}"
chmod 0750 "${APP_DIR}"

systemctl daemon-reload

# Do not enable or start the service during Packer build.
# Launch Template user-data creates /etc/attendance-api/attendance.env
# and then starts attendance-api.service.

log "Validating installed runtime"
"${APP_DIR}/.venv/bin/python" --version
"${APP_DIR}/.venv/bin/gunicorn" --version
psql --version
redis-cli --version
aws --version
jq --version
systemd-analyze verify /etc/systemd/system/attendance-api.service

log "Cleaning package caches and temporary files"
rm -rf /root/.cache /home/ubuntu/.cache
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

log "Attendance AMI provisioning completed successfully"
