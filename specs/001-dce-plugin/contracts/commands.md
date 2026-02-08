# Command Contracts: dce CLI

## dce start <service>
- **Input**: `<service>` (string, required)
- **Behavior**:
  - `docker compose` 存在確認、サービス稼働確認を実施。
  - 成功時: セッションをActiveにし、プロンプトに `[in <service>]` を付与。
  - 失敗時: 日本語で原因と対処（例: `docker compose up -d <service>`）を表示し、終了コード≠0で戻る。
- **Exit codes**: 0=成功, 1=前提不足/検証失敗, 2=その他実行エラー。

## dce end
- **Behavior**: Activeセッションを終了し、プロンプトとフックを元に戻す。未開始の場合は警告を表示し終了コード1。
- **Exit codes**: 0=成功, 1=セッション未開始。

## dce status
- **Behavior**: 現在のセッション状態と対象サービス名を表示。
- **Exit codes**: 0=成功。

## 透過実行（preexecフック）
- **Trigger**: Activeセッション中に、`dce` サブコマンド以外の任意入力を行ったとき。
- **Behavior**:
  - 入力コマンドを `docker compose exec <service> zsh -lc "<cmd>"` で実行。
  - コンテナ実行結果をそのまま出力する。
  - 失敗時はエラーを表示し、セッションは維持。ユーザーに `dce end` を案内。
- **Exit codes**: コンテナ内コマンドの終了コードを反映。

## dce --help / help
- **Behavior**: 上記サブコマンドの使い方、セットアップ手順（clone + source）、root実行時の注意を日本語で表示。
- **Exit codes**: 0=成功。
