#!/usr/bin/env bash
set -Eeuo pipefail

exec > >(tee -a /var/log/attendance-user-data.log | logger -t attendance-user-data -s 2>/dev/console) 2>&1

AWS_REGION="${aws_region}"
DB_SECRET_ARN="${db_secret_arn}"
DB_HOST="${postgres_host}"
DB_PORT="${postgres_port}"
DB_NAME="${postgres_database}"
REDIS_HOST="${redis_host}"
REDIS_PORT="${redis_port}"
REDIS_PASSWORD="${redis_password}"

retry() {
  local attempts="$1"
  local delay="$2"
  shift 2

  local count=1
  until "$@"; do
    if (( count >= attempts )); then
      return 1
    fi

    echo "Command failed. Retry $${count}/$${attempts} in $${delay}s: $*"
    sleep "$${delay}"
    ((count++))
  done
}

for required_value in \
  "$${AWS_REGION}" \
  "$${DB_SECRET_ARN}" \
  "$${DB_HOST}" \
  "$${DB_PORT}" \
  "$${DB_NAME}" \
  "$${REDIS_HOST}" \
  "$${REDIS_PORT}"; do
  if [[ -z "$${required_value}" ]]; then
    echo "A required Launch Template value is empty." >&2
    exit 1
  fi
done

# The EC2 instance profile must allow secretsmanager:GetSecretValue for this ARN.
SECRET_JSON="$(retry 20 10 aws secretsmanager get-secret-value \
  --region "$${AWS_REGION}" \
  --secret-id "$${DB_SECRET_ARN}" \
  --query SecretString \
  --output text)"

DB_USER="$(printf '%s' "$${SECRET_JSON}" | jq -e -r '.username')"
DB_PASSWORD="$(printf '%s' "$${SECRET_JSON}" | jq -e -r '.password')"

if [[ -z "$${DB_USER}" || "$${DB_USER}" == "null" ]]; then
  echo "Database username was not found in Secrets Manager." >&2
  exit 1
fi

if [[ -z "$${DB_PASSWORD}" || "$${DB_PASSWORD}" == "null" ]]; then
  echo "Database password was not found in Secrets Manager." >&2
  exit 1
fi

export DB_HOST DB_PORT DB_NAME DB_USER DB_PASSWORD
export REDIS_HOST REDIS_PORT REDIS_PASSWORD

install -d -o root -g attendance -m 0750 /etc/attendance-api

# Generate a systemd EnvironmentFile without exposing the secret in command output.
python3.11 <<'PY'
import os
from pathlib import Path


def quote_systemd(value: str) -> str:
    escaped = (
        value.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("\n", "\\n")
        .replace("\r", "\\r")
    )
    return f'"{escaped}"'

values = {
    "DB_HOST": os.environ["DB_HOST"],
    "DB_PORT": os.environ["DB_PORT"],
    "DB_NAME": os.environ["DB_NAME"],
    "DB_USER": os.environ["DB_USER"],
    "DB_PASSWORD": os.environ["DB_PASSWORD"],
    "REDIS_HOST": os.environ["REDIS_HOST"],
    "REDIS_PORT": os.environ["REDIS_PORT"],
    "REDIS_PASSWORD": os.environ.get("REDIS_PASSWORD", ""),
}

path = Path("/etc/attendance-api/attendance.env")
path.write_text(
    "\n".join(f"{key}={quote_systemd(value)}" for key, value in values.items()) + "\n",
    encoding="utf-8",
)
path.chmod(0o640)
PY

chown root:attendance /etc/attendance-api/attendance.env

systemctl daemon-reload
systemctl enable attendance-api.service
systemctl restart attendance-api.service

# Fail user-data when the service cannot become active.
for attempt in $(seq 1 60); do
  if systemctl is-active --quiet attendance-api.service; then
    echo "Attendance API service started successfully."
    exit 0
  fi

  if [[ "$${attempt}" -eq 60 ]]; then
    echo "Attendance API failed to start." >&2
    systemctl status attendance-api.service --no-pager || true
    journalctl -u attendance-api.service -n 100 --no-pager || true
    exit 1
  fi

  sleep 5
done
