#!/usr/bin/env bats

load ./helpers.bash

@test "help shows setup instructions" {
  run zsh -c "source '${BATS_TEST_DIRNAME}/../zsh-docker-compose-exec-mode.zsh' && dce help"
  [ "$status" -eq 0 ]
  [[ "$output" == *"dce start"* ]]
  [[ "$output" == *"dce end"* ]]
  [[ "$output" == *"dce status"* ]]
  [[ "$output" == *"セットアップ"* ]]
}
