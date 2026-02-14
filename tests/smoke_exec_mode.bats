#!/usr/bin/env bats

load ./helpers.bash

@test "dce status shows inactive by default" {
  run zsh -c "
    source '${BATS_TEST_DIRNAME}/../zsh-docker-compose-exec-mode.zsh'
    dce status
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"inactive"* ]]
}

@test "dce start activates exec mode" {
  run zsh -c "
    source '${BATS_TEST_DIRNAME}/../zsh-docker-compose-exec-mode.zsh'
    dce start web
    dce status
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"active"* ]]
  [[ "$output" == *"web"* ]]
}

@test "dce end deactivates exec mode" {
  run zsh -c "
    source '${BATS_TEST_DIRNAME}/../zsh-docker-compose-exec-mode.zsh'
    dce start web
    dce end
    dce status
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"inactive"* ]]
}

@test "unknown subcommand returns error" {
  run zsh -c "
    source '${BATS_TEST_DIRNAME}/../zsh-docker-compose-exec-mode.zsh'
    dce foobar
  "
  [ "$status" -eq 1 ]
  [[ "$output" == *"未知のサブコマンド"* ]]
}
