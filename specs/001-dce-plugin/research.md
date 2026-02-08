# Research: Docker Compose Execモード zshプラグイン

**Date**: 2026-02-08  
**Branch**: 001-dce-plugin

## Decisions & Rationale

### 入力透過方式
- **Decision**: zsh の `preexec` フックでユーザー入力を横取りし、`docker compose exec <service> zsh -lc "<cmd>"` で実行する。`dce` 自身のサブコマンドは透過しないようフィルタする。
- **Rationale**: 最低限の依存でシェル内連続実行を実現でき、ユーザー操作を変えずに済む。
- **Alternatives**: `PROMPT_COMMAND`/`TRAPALRM` でのポーリング（オーバーヘッド増）、ラッパー関数のみで `dce exec <cmd>` を強制（利便性低下）。

### プロンプト表示
- **Decision**: `PROMPT` 先頭に `[in <service>]` を付与し、色は zsh デフォルトに依存せずシンプルにする。
- **Rationale**: 可視性が高く、テーマ非依存で壊れにくい。
- **Alternatives**: 色付き/emoji 表示（テーマ衝突リスク、可搬性低下）。

### 安全チェック
- **Decision**: `docker compose version` の存在確認と `docker compose ps --services --filter status=running` で対象サービス稼働を検証。失敗時は日本語で対処手順を提示し exec モードに入らない。
- **Rationale**: コンテナ未起動時の予期せぬ失敗を防ぎ、ユーザーの次の行動を明確にする。
- **Alternatives**: 成功を仮定して即 exec（失敗時のエラーメッセージが分かりづらい）。

### 権限
- **Decision**: デフォルト非root。root実行は `--user root` オプションを明示指定した場合のみ許可。
- **Rationale**: 安全デフォルトを維持し、誤操作による破壊的変更を防ぐ。
- **Alternatives**: 常にroot（安全性低下）。

### ロギング/デバッグ
- **Decision**: `DCE_DEBUG=1` 環境変数でデバッグログ（stderr）を有効化。通常時は静粛。
- **Rationale**: 標準の使用感を邪魔せず、問題調査時のみ詳細を得られる。
- **Alternatives**: 常時ロギング（ノイズ増）。

## Open Items
- 自動補完提供の有無と方法（このイテレーションではスコープ外、将来検討）。
- テストフレームワークは bats/shunit2 のどちらを採用するか（実装時に選定）。
