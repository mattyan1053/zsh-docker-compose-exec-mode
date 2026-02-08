#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if command -v bats >/dev/null 2>&1; then
  exec bats "$@" "$ROOT/tests"
else
  echo "bats が見つかりません。インストールして再実行してください。" >&2
  exit 1
fi
