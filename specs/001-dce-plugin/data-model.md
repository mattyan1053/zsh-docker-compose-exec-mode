# Data Model: Docker Compose Execモード zshプラグイン

## Entities

### Session
- **Fields**: `service_name` (string, required), `prompt_backup` (string), `active` (bool), `user` (string, default from shell), `start_time` (timestamp)
- **Relationships**: 属するサービス (`service_name` → Service)
- **Rules**: 同時に1セッションのみ有効。ネスト検知で二重開始を拒否。

### Service
- **Fields**: `name` (string, required), `is_running` (bool), `last_check` (timestamp)
- **Rules**: `is_running=true` のサービスのみ `Session` を開始できる。

## States & Transitions
- **Idle → Active**: `dce start <service>` が成功したとき。前提: compose存在確認・サービス稼働確認。
- **Active → Idle**: `dce end` 実行、またはエラーで強制終了したとき。`prompt_backup` を復元。
- **Active → Error**: コンテナ実行エラー時。モードは維持し、ユーザーに終了/続行の選択肢を提示。

## Validation Rules
- サービス名は非空。`docker compose ps --services` に存在する名前のみ許可。
- `preexec` フックは `dce` サブコマンドを透過し、その他入力のみコンテナ実行に転送。
- root実行は明示フラグ指定時のみ許可。
