# Quickstart: Docker Compose Execモード zshプラグイン

1) リポジトリ取得  
```sh
git clone https://<your_repo>/zsh-docker-compose-exec-mode.git ~/.zsh/zsh-docker-compose-exec-mode
```

2) zshrc に追記  
```sh
echo 'source ~/.zsh/zsh-docker-compose-exec-mode/zsh-docker-compose-exec-mode.zsh' >> ~/.zshrc
```

3) 反映  
```sh
exec zsh
```

4) 利用例  
```sh
dce start web
ls
dce end
```

5) トラブルシュート  
- `dce` が見つからない: zshrcのパスを確認し、再読込する。  
- サービスが未起動: `docker compose ps --services --filter status=running` で確認し、`docker compose up -d <service>` を実行。  
- root実行が必要: 明示フラグ（実装時に案内）を付与する。  

6) アンインストール  
`~/.zsh/zsh-docker-compose-exec-mode` を削除し、zshrc の設定行を削除する。
