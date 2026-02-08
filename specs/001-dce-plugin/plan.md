# Implementation Plan: Docker Compose Execモード zshプラグイン

**Branch**: `001-dce-plugin` | **Date**: 2026-02-08 | **Spec**: specs/001-dce-plugin/spec.md
**Input**: Feature specification from `/specs/001-dce-plugin/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

開発者が `docker compose exec` を都度書かずに、`dce start <service>` でコンテナ内実行モードに入り通常のシェル入力を透過的に同一コンテナで実行できる zsh プラグインを提供する。セットアップは `~/.zsh/` への clone と `.zshrc` への1行追加のみ。非rootデフォルト、安全確認（compose存在/サービス稼働）と日本語ヘルプを必須とする。

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: zsh 5.8+  
**Primary Dependencies**: docker, docker compose v2  
**Storage**: N/A  
**Testing**: 手動スモーク + （あれば）bats/shunit2 でCLI挙動確認  
**Target Platform**: macOS/Linux 開発環境（docker利用可能な端末）  
**Project Type**: single CLI plugin  
**Performance Goals**: `dce start`→最初のコマンド実行まで3秒以内；1コマンドの透過オーバーヘッド100ms未満  
**Constraints**: 非rootデフォルト、日本語メッセージ、依存最小（zsh + docker compose のみ）  
**Scale/Scope**: 単一リポジトリ・小規模プラグイン

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- CLIファーストとシンプルさ: OK — `dce`単一入口、明示サービス指定、プロンプト表示。
- 安全なコンテナ実行: OK — compose存在/稼働確認と非rootデフォルト、rootは明示opt-in。
- セッションの明確化と隔離: OK — start/endでプロンプト復元、ネスト検知とガード実装予定。
- 最小依存と性能: OK — 依存はzsh+docker composeのみ、オーバーヘッド目標設定済み。
- テスト可能性とドキュメント整合: OK — スモークテスト必須、README/--help同期を計画。
- 日本語優先コミュニケーション: OK — ヘルプ/エラー/ドキュメントを日本語で提供。

再評価（設計後）: 上記すべて計画に反映済みのため問題なし。

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
```text
zsh-docker-compose-exec-mode.zsh   # プラグイン本体
lib/                               # 共通関数（サービス検証、プロンプト制御）
tests/                             # CLIスモーク/ユニット（bats/shunit2想定）
README.md
.specify/                          # specify メタデータ・テンプレ
```

**Structure Decision**: Single CLI plugin構成。プラグイン本体はリポジトリ直下、共通ロジックを`lib/`に分離。テストは`tests/`に配置。

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
