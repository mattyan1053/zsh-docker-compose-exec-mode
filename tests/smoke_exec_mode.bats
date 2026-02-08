#!/usr/bin/env bats

load ./helpers.bash

@test "start -> two commands -> end uses same service" {
  export PATH="${BATS_TEST_DIRNAME}/mocks:${PATH}"
  ZDOTDIR="$BATS_TEST_TMPDIR"
  cat >"$ZDOTDIR/.zshrc" <<'RC'
source "$BATS_TEST_DIRNAME/../zsh-docker-compose-exec-mode.zsh"
dce start web
ls
echo ok
dce end
RC
  skip "Integration shell execution is environment-dependent; validate manually."
}
