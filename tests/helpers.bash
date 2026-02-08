# Helpers for bats tests (mockable docker compose commands)

# Optional: load bats-support / bats-assert if available (workspace may not vendor them)
if command -v bats >/dev/null 2>&1; then
  if [[ -d "${BATS_TEST_DIRNAME}/test_helper" ]]; then
    load 'test_helper/bats-support'
    load 'test_helper/bats-assert'
  fi
fi

setup() {
  export PATH="${BATS_TEST_DIRNAME}/mocks:${PATH}"
  mkdir -p "${BATS_TEST_TMPDIR}/home"
  export HOME="${BATS_TEST_TMPDIR}/home"
}

teardown() {
  true
}
