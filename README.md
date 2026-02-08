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
```sh
$ dce start sample_container_name
[in sample_container_name]$ ls -la
<略>
[in sample_container_name]$ <command you want to execute>
$ dce end
```
