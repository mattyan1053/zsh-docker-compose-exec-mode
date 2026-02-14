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

@test "dce start --root sets DCE_USER to root" {
  run zsh -c "
    source '${BATS_TEST_DIRNAME}/../zsh-docker-compose-exec-mode.zsh'
    dce start --root web
    echo \"DCE_USER=\${DCE_USER}\"
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"DCE_USER=root"* ]]
}

@test "dce start fails when service is not running" {
  run zsh -c "
    export MOCK_RUNNING_SERVICES=''
    source '${BATS_TEST_DIRNAME}/../zsh-docker-compose-exec-mode.zsh'
    dce start web
  "
  [ "$status" -eq 1 ]
  [[ "$output" == *"起動していません"* ]]
}

@test "dce start fails when docker compose is unavailable" {
  run zsh -c "
    export MOCK_COMPOSE_FAIL=1
    source '${BATS_TEST_DIRNAME}/../zsh-docker-compose-exec-mode.zsh'
    dce start web
  "
  [ "$status" -eq 1 ]
  [[ "$output" == *"docker compose"* ]]
}

@test "unknown subcommand returns error" {
  run zsh -c "
    source '${BATS_TEST_DIRNAME}/../zsh-docker-compose-exec-mode.zsh'
    dce foobar
  "
  [ "$status" -eq 1 ]
  [[ "$output" == *"未知のサブコマンド"* ]]
}
