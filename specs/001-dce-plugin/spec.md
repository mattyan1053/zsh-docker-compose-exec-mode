# Feature Specification: Docker Compose Execモード zshプラグイン

**Feature Branch**: `001-dce-plugin`  
**Created**: 2026-02-08  
**Status**: Draft  
**Input**: User description: "プラグインを作成してください。設定方法は、このリポジトリを~/.zsh/配下にcloneし、~/.zshrcでsource ~/.zsh/zsh-docker-compose-exec-mode/zsh-docker-compose-exec-mode.zsh とすることでdceコマンドが利用できるようになるものをイメージしています。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - サービスに入って連続実行したい (Priority: P1)

開発者として、対象サービス名を指定して exec モードに入り、同じコンテナ内で複数コマンドを連続実行したい。毎回 `docker compose exec` を書かずに済むことで、作業効率を上げたい。

**Why this priority**: 本機能の中心価値であり、これが無いとプラグインの目的を果たさないため。

**Independent Test**: `dce start <service>` でプロンプトにサービス名が表示され、その後は通常通り入力した任意コマンドが同一コンテナで連続実行されるかを確認する。

**Acceptance Scenarios**:

1. **Given** サービスが起動している, **When** `dce start web` を実行, **Then** プロンプトに `[in web]` が表示され exec モードに入る
2. **Given** exec モード中, **When** `ls` を2回実行, **Then** どちらも同じコンテナで実行され結果が表示される
3. **Given** exec モード中, **When** `dce end` を実行, **Then** 元のプロンプトに戻り exec モードが終了する

---

### User Story 2 - セットアップを簡単にしたい (Priority: P2)

利用者として、`~/.zsh/` にリポジトリをcloneし、`.zshrc` に1行追加するだけで `dce` コマンドが使えるようにしたい。複雑なインストール手順を避けてすぐ試せるようにしたい。

**Why this priority**: 導入手順が簡単でないと利用開始の障壁が高くなるため。

**Independent Test**: 指定のパスに clone し、`.zshrc` へ `source ~/.zsh/zsh-docker-compose-exec-mode/zsh-docker-compose-exec-mode.zsh` を追記後、新しいシェルで `dce --help` が表示されるか確認する。

**Acceptance Scenarios**:

1. **Given** リポジトリを `~/.zsh/zsh-docker-compose-exec-mode` にclone済み, **When** `.zshrc` に記載を追加し新規シェルを起動, **Then** `dce --help` が利用可能になる
2. **Given** 前提を満たさない（パス誤りなど）, **When** `dce` を実行, **Then** 修正方法が日本語で案内される

---

[追加のユーザーストーリーが必要になれば計画フェーズで拡張する]

### Edge Cases

- `docker compose` がインストールされていない／v2未満の場合の挙動とメッセージ
- 指定サービスが未起動・存在しない場合の失敗メッセージ
- 既に別サービスで exec モード中に再度 `dce start` した場合の扱い
- `.zshrc` の設定忘れ・パス誤りで `dce` が見つからない場合の案内
- root 権限での実行要求がある場合の扱い（明示オプトイン）

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `dce` コマンドは `start`, `end`, `status`, `help/--help` を提供し、サービス名はユーザーが明示指定すること。
- **FR-002**: `dce start <service>` は `docker compose` の存在と対象サービスの稼働を確認し、問題があれば理由と対処を日本語で表示して終了すること。
- **FR-003**: execモード中はプロンプトにサービス名が明示され、`dce end` 実行で元のプロンプトとシェル状態が復元されること。
- **FR-004**: execモード中は、通常のシェル入力が透過的に対象コンテナ内で実行されること。実行失敗時は理由を表示し、モード継続または終了の手段を案内すること。
- **FR-005**: インストール手順は「~/.zsh/ 配下に clone し .zshrc で source する」だけで完結し、手順を README と `--help` に記載すること。
- **FR-006**: 依存は zsh と `docker compose` のみに限定し、追加依存が必要な場合は理由と設定手順を文書化すること。
- **FR-007**: 主要メッセージ・ヘルプ・README は日本語で提供し、英語が必要な箇所は理由を記載すること。

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 指定手順でセットアップした新規シェルで、90秒以内に `dce --help` が表示できること。
- **SC-002**: 起動済みサービスに対し `dce start` から最初の `echo ok` 完了までが3秒以内であること（一般的な開発環境）。
- **SC-003**: 起動していないサービス名を指定した場合、原因と起動方法を含む日本語メッセージが1回の実行で表示されること。
- **SC-004**: READMEの手順に従った利用者アンケートで、80%以上が「導入が簡単」と回答すること（内部評価で代替可）。

## 前提・想定
- ユーザーは docker compose v2 互換環境を持ち、対象サービスを起動できる。
- プラグインは zsh 5.8 以降で動作させる。
- 入力透過型の実行（preexec を用いた passthrough）は本イテレーションで実装対象とする。高度な補完連携や履歴加工などは将来検討とする。
