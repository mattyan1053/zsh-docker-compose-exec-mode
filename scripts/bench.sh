#!/usr/bin/env zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
source "${SCRIPT_DIR}/../zsh-docker-compose-exec-mode.zsh"

service="${1:-}"
if [[ -z "$service" ]]; then
  echo "Usage: $0 <service>" >&2
  exit 1
fi

start_ts=$(date +%s%3N)
dce start "$service" >/dev/null
mid_ts=$(date +%s%3N)
docker compose exec "$service" echo ok >/dev/null
end_ts=$(date +%s%3N)
dce end >/dev/null

start_ms=$((mid_ts - start_ts))
cmd_ms=$((end_ts - mid_ts))
echo "dce start: ${start_ms} ms"
echo "first command: ${cmd_ms} ms"
