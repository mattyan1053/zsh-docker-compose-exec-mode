# zsh-docker-compose-exec-mode
zsh でdocker compose を利用していて、コンテナ内でコマンドを連続で叩きたいときに毎度
```sh
$ docker compose exec <service> hoge
```
したり

```sh
docker compose exec <service> bash
```
することなく、自動でコンテナ内でコマンドを実行してくれるようにモード切り替えできるようにするプラグインです。

# Usage

## セットアップ
```sh
git clone https://<your_repo>/zsh-docker-compose-exec-mode.git ~/.zsh/zsh-docker-compose-exec-mode
echo 'source ~/.zsh/zsh-docker-compose-exec-mode/zsh-docker-compose-exec-mode.zsh' >> ~/.zshrc
exec zsh
```

## 使い方
```sh
$ dce start sample_container_name
# 以降のコマンドは自動的にコンテナ内で実行される
[in sample_container_name]
ls
[in sample_container_name]
echo ok
$ dce end
```

### オプション
- `dce status` : 現在の exec モード状態を表示
- `dce help`   : 使い方とセットアップ手順を表示
- `dce start --root <service>` : root ユーザーで実行（通常は非root推奨）
- `DCE_NO_TTY=1` を付けて `dce start ...` すると `docker compose exec -T` で実行
- `DCE_COLOR_MARKER=0` で `[in service]` の色付けをオフ（デフォルトは黄背景・赤文字）
- `DCE_DEBUG=1` で実行時に置換後のコマンドを表示

### トラブルシュート
- `docker compose` が無い/古い: v2 以降をインストールしてください。
- サービスが起動していない: `docker compose up -d <service>` を実行してください。
- `dce` が見つからない: `.zshrc` の source 設定とパスを確認してください。
