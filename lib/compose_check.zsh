# shellcheck shell=bash
# docker compose availability and service state checks

_dce_require_compose() {
  if ! command -v docker >/dev/null 2>&1; then
    print -r -- "docker コマンドが見つかりません。インストールしてください。" >&2
    return 1
  fi
  if ! docker compose version >/dev/null 2>&1; then
    print -r -- "docker compose が利用できません。v2 以降をインストールしてください。" >&2
    return 1
  fi
}

_dce_require_service_running() {
  local service="$1"
  if [[ -z "$service" ]]; then
    print -r -- "サービス名を指定してください。" >&2
    return 1
  fi
  local running
  running=$(docker compose ps --services --filter "status=running" 2>/dev/null | grep -Fx "$service")
  if [[ -z "$running" ]]; then
    print -r -- "サービス '${service}' は起動していません。先に 'docker compose up -d ${service}' を実行してください。" >&2
    return 1
  fi
}
