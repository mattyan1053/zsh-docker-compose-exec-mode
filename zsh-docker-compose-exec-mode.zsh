#!/usr/bin/env zsh
# Docker Compose exec mode plugin for zsh

autoload -Uz add-zsh-hook

DCE_DIR=${0:A:h}

# shellcheck disable=SC1090
source "${DCE_DIR}/lib/logging.zsh"
# shellcheck disable=SC1090
source "${DCE_DIR}/lib/compose_check.zsh"
# shellcheck disable=SC1090
source "${DCE_DIR}/lib/session_state.zsh"

_dce_help() {
  cat <<'EOF'
dce - docker compose exec モード切り替え

使い方:
  dce start <service> [--root]   指定サービスでexecモード開始（デフォルト非root）
  dce end                        execモード終了
  dce status                     状態表示
  dce help|--help|-h             このヘルプを表示

セットアップ:
  git clone <repo> ~/.zsh/zsh-docker-compose-exec-mode
  echo 'source ~/.zsh/zsh-docker-compose-exec-mode/zsh-docker-compose-exec-mode.zsh' >> ~/.zshrc
  exec zsh

注意:
  - `docker compose` が必要です（v2+）。
  - デフォルトはコンテナのデフォルトユーザーで実行します。rootで実行する場合は `--root` を付けて start してください。
  - プロンプト表示を変えたくない場合は `export DCE_PROMPT_MODE=none` をセットしてください（デフォルトは右側に [in service] を表示）。
EOF
}

_dce_restore_widget() {
  if (( DCE_WIDGET_SAVED == 1 )); then
    zle -A _dce_accept_line_orig accept-line 2>/dev/null
    DCE_WIDGET_SAVED=0
  fi
  for km in emacs main viins vicmd; do
    bindkey -M "$km" "^M" accept-line 2>/dev/null
  done
}

_dce_install_widget() {
  if (( DCE_WIDGET_SAVED == 0 )) && zle -A accept-line _dce_accept_line_orig 2>/dev/null; then
    DCE_WIDGET_SAVED=1
  fi
  zle -N "$DCE_WIDGET_NAME" _dce_accept_line 2>/dev/null
  for km in emacs main viins vicmd; do
    bindkey -M "$km" "^M" "$DCE_WIDGET_NAME" 2>/dev/null
  done
}

_dce_accept_line() {
  emulate -L zsh -o noshwordsplit -o noclobber -o no_aliases
  local line="$BUFFER"
  if [[ $DCE_ACTIVE -ne 1 ]]; then
    zle -A _dce_accept_line_orig accept-line 2>/dev/null
    zle accept-line
    return
  fi
  if [[ "$line" == dce* ]]; then
    zle -A _dce_accept_line_orig accept-line 2>/dev/null
    zle accept-line
    return
  fi
  [[ -z "$line" ]] && { BUFFER=""; zle reset-prompt; return; }
  local prefix="docker compose exec -i"
  [[ -n "$DCE_NO_TTY" ]] && prefix+=" -T"
  [[ -n "$DCE_USER" ]] && prefix+=" --user ${DCE_USER}"
  prefix+=" ${DCE_SERVICE}"
  BUFFER="${prefix} ${line}"
  CURSOR=${#BUFFER}
  local marker="[in ${DCE_SERVICE}]"
  print  # blank line for separation
  if [[ "${DCE_COLOR_MARKER:-1}" == "1" ]]; then
    # background yellow (43), red text (31)
    print -r -- $'\033[43;31m'"${marker}"$'\033[0m '
  else
    print -r -- "${marker} "
  fi
  [[ -n "$DCE_DEBUG" ]] && print -r -- "[dce] ${BUFFER}" >&2
  zle -A _dce_accept_line_orig accept-line 2>/dev/null
  zle accept-line
}

_dce_precmd() {
  if [[ $DCE_ACTIVE -ne 1 ]]; then
    return
  fi
  # capture base prompts once per session to avoid cumulative markers
  if [[ -z "$DCE_BASE_PROMPT" ]]; then
    DCE_BASE_PROMPT="$PROMPT"
  fi
  if [[ -z "$DCE_BASE_RPROMPT" ]]; then
    DCE_BASE_RPROMPT="$RPROMPT"
  fi

  local mode="${DCE_PROMPT_MODE:-inline}"
  local marker="[in ${DCE_SERVICE}]"
  local base_p="$DCE_BASE_PROMPT"
  local base_r="$DCE_BASE_RPROMPT"

  case "$mode" in
    right)
      PROMPT="$base_p"
      RPROMPT="${base_r:+${base_r} }${marker}"
      ;;
    none)
      PROMPT="$base_p"
      RPROMPT="$base_r"
      ;;
    inline|left|*)
      PROMPT="${marker} ${base_p}"
      RPROMPT="$base_r"
      ;;
  esac
}

dce_start() {
  emulate -L zsh
  local user=""
  local service=""
  while [[ "$1" == --* ]]; do
    case "$1" in
      --root) user="root" ;;
      *) print -r -- "未知のオプション: $1" >&2; return 1 ;;
    esac
    shift
  done
  service="$1"
  if [[ -z "$service" ]]; then
    print -r -- "使用方法: dce start <service> [--root]" >&2
    return 1
  fi
  _dce_require_compose || return 1
  _dce_require_service_running "$service" || return 1

  if [[ $DCE_ACTIVE -eq 1 ]]; then
    print -r -- "すでに '${DCE_SERVICE}' で exec モード中です。'dce end' で終了してください。" >&2
    return 1
  fi

  _dce_set_session "$service"
  DCE_USER="$user"
  _dce_set_prompt "$service"
  if whence -w zle >/dev/null 2>&1; then
    _dce_install_widget
  fi
  print -r -- "コンテナ '${service}' に入りました。終了するには 'dce end'。"
}

dce_end() {
  emulate -L zsh
  if [[ $DCE_ACTIVE -eq 0 ]]; then
    print -r -- "現在 exec モードではありません。" >&2
    return 1
  fi
  _dce_clear_session
  _dce_restore_prompt
  if whence -w zle >/dev/null 2>&1; then
    _dce_restore_widget
  fi
  print -r -- "exec モードを終了しました。"
}

dce_status() {
  if [[ $DCE_ACTIVE -eq 1 ]]; then
    print -r -- "exec mode: active (service=${DCE_SERVICE})"
  else
    print -r -- "exec mode: inactive"
  fi
}

dce() {
  local cmd="$1"; shift || true
  case "$cmd" in
    start) dce_start "$@";;
    end) dce_end;;
    status) dce_status;;
    help|--help|-h|"") _dce_help;;
    *)
      print -r -- "未知のサブコマンドです: $cmd" >&2
      _dce_help
      return 1
      ;;
  esac
}

# backward compatible aliases
alias dce-start=dce_start
alias dce-end=dce_end
alias dce-status=dce_status
