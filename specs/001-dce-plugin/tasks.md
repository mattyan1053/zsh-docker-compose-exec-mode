---

description: "Task list for Docker Compose Execモード zshプラグイン"
---

# Tasks: Docker Compose Execモード zshプラグイン

**Input**: Design documents from `/specs/001-dce-plugin/`  
**Prerequisites**: plan.md (required), spec.md (user stories), research.md, data-model.md, contracts/, quickstart.md

**Tests**: スモークテストは必須（憲法）。その他のテストは任意。セッション/プロンプト変更時は最低1本のスモークパスを含めること。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: [US1], [US2] from spec
- Include exact file paths in descriptions

## Path Conventions

- プラグイン本体: `zsh-docker-compose-exec-mode.zsh`
- 共通関数: `lib/`
- テスト: `tests/`
- ドキュメント: `README.md`, `specs/001-dce-plugin/quickstart.md`

---

## Phase 1: Setup (Shared Infrastructure)

- [ ] T001 [P] 作業ディレクトリを作成（lib/, tests/）: `lib/`, `tests/`
- [ ] T002 プラグイン本体のベースファイルを作成（ヘッダ/変数のみ）: `zsh-docker-compose-exec-mode.zsh`
- [ ] T003 テストランナー雛形を追加（bats or shunit2 呼び出しスクリプト）: `tests/run.sh`

---

## Phase 2: Foundational (Blocking Prerequisites)

- [ ] T004 docker compose の存在/バージョン検証ヘルパーを実装: `lib/compose_check.zsh`
- [ ] T005 サービス稼働確認ヘルパーを実装（`docker compose ps --services --filter status=running`）: `lib/compose_check.zsh`
- [ ] T006 セッション状態管理とプロンプト退避/復元ヘルパーを実装: `lib/session_state.zsh`
- [ ] T007 デバッグロギング（`DCE_DEBUG=1` 時 stderr 出力）ヘルパーを実装: `lib/logging.zsh`
- [ ] T008 本体で各ヘルパーを読み込み、初期変数と安全なシェルオプション設定を追加: `zsh-docker-compose-exec-mode.zsh`
- [ ] T009 テスト基盤を準備（モック用関数/環境、bats helper）: `tests/helpers.bash`

---

## Phase 3: User Story 1 - サービスに入って連続実行したい (Priority: P1) 🎯 MVP

**Goal**: `dce start <service>` で exec モードに入り、通常入力が同一コンテナで透過実行できること。  
**Independent Test**: start → 任意コマンド2回 → end が成功し、プロンプトが復元される。

### Tests for User Story 1

- [ ] T010 [P] [US1] スモークテスト: start→`ls`→`echo ok`→end の透過実行を検証（モックdocker使用）: `tests/smoke_exec_mode.bats`

### Implementation for User Story 1

- [ ] T011 [US1] preexec フックで `dce` 以外の入力を `docker compose exec <service> zsh -lc "<cmd>"` に転送: `zsh-docker-compose-exec-mode.zsh`
- [ ] T012 [US1] `dce start` を実装（依存チェック、サービス稼働確認、プロンプト付与、フック登録）: `zsh-docker-compose-exec-mode.zsh`
- [ ] T013 [US1] `dce end` を実装（フック解除、プロンプト復元、状態クリア）: `zsh-docker-compose-exec-mode.zsh`
- [ ] T014 [US1] 二重起動/ゾンビ検知ガードを追加し、再入防止メッセージを日本語で表示: `zsh-docker-compose-exec-mode.zsh`
- [ ] T015 [US1] コンテナ内コマンド失敗時のエラーハンドリングと続行/終了案内を追加: `zsh-docker-compose-exec-mode.zsh`

---

## Phase 4: User Story 2 - セットアップを簡単にしたい (Priority: P2)

**Goal**: clone + `.zshrc` 1行追加で `dce` が利用可能になり、誤設定時は日本語で案内される。  
**Independent Test**: 指定手順後の新規シェルで `dce --help` が表示される。

### Tests for User Story 2

- [ ] T016 [P] [US2] ヘルプ/セットアップメッセージのテスト（パス誤り時の案内含む）: `tests/setup_help.bats`

### Implementation for User Story 2

- [ ] T017 [US2] README と quickstart にセットアップ手順を反映: `README.md`, `specs/001-dce-plugin/quickstart.md`
- [ ] T018 [US2] `--help`/`help` 出力にセットアップ手順と使用例を追加: `zsh-docker-compose-exec-mode.zsh`
- [ ] T019 [US2] 誤パス/未source時のガイダンスを実装（`dce` 実行時のエラーメッセージ）: `zsh-docker-compose-exec-mode.zsh`

---

## Phase 5: Polish & Cross-Cutting Concerns

- [ ] T020 パフォーマンス簡易計測スクリプトを追加（start→コマンド実行の時間計測）: `scripts/bench.sh`
- [ ] T021 shellcheck など lint/format を実行し、主要警告を修正: `zsh-docker-compose-exec-mode.zsh`, `lib/*.zsh`

---

## Dependencies & Execution Order

- フェーズ順: Setup → Foundational → US1 → US2 → Polish
- US1 は Foundational 完了後に着手。US2 は US1 の挙動を流用するため US1 完了後。

## Parallel Example

- Setup: T001 と T002 は並行可。  
- Foundational: T004–T007 は別ファイルのため並行可。  
- US1: テスト T010 を先に書き、T011–T015 実装を並行で進める場合はモックの共通部分に注意。  
- US2: T017 ドキュメント更新と T018 コード実装を並行可。

## Implementation Strategy

- MVP は US1 完成（start/透過実行/end＋スモークテスト）。  
- US2 は導入体験向上のため続いて実施。  
- Polish で性能・lint を仕上げ、リリース前にスモーク再実行。
