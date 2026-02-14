# shellcheck shell=zsh

_dce_log() {
  [[ -n "$DCE_DEBUG" ]] || return 0
  print -r -- "[dce] $*" >&2
}

_dce_error() {
  print -r -- "$*" >&2
}
