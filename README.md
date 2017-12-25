# Gitlab 用の証明書をつくるやつ

## Directory Structure

```
$ tree
.
├── bin ...Server証明書/Client証明書を作るshell
├── ca  ...証明書に署名するCA証明書, CRLなど（秘密鍵のPEMファイルはgitignore）
├── client
│   ├── out ... クライアント証明書であるp12ファイルが出力される場所(gitignore)
│   └── seed ... クライアント証明書発行用の基礎情報
├── docker-compose.yaml
├── Dockerfile
├── nginx ... クライアント証明書動作検証用のNginx設定
│   └── ssl.conf
├── README.md
└── server
    ├── out ...server証明書が出力される場所（Gitに保存する）
    └── seed  ...server証明書発行用の基礎情報
```

## How to use

### create CA cert & CRL

```
$ docker-compose run create_ca_cert
```

`./ca`ディレクトリ直下に以下のファイルが出来ます。

* ca.pem ... CA用の秘密鍵
* ca.crt ... CAの自己署名証明書
* ca.crl ... 失効リスト

証明書の期限、サブジェクトは[ca.json](ca/ca.json)に設定します。

### create client cert

```
$ docker-compose run create_client_cert yoshiko
```

上記で生成された`./ca/ca.crt`で署名されたクライアント証明書が`./client/out`ディレクトリにp12ファイルとして出来ます。  
パスワードは空文字が設定されています。

* 証明書の期限、サブジェクトは[./client/seed/yoshiko.json](client/seed/yoshiko.json) で設定します
* seedを増やすことでクライアント証明書を増産できます

### create server cert

```
$ docker-compose run create_server_cert site.kinoboku.net
```

上記で生成された`./ca/ca.crt`で署名されたサーバー証明書が`./server/out`ディレクトリにファイルとして出来ます。  

* 証明書の期限、サブジェクトは[./server/seed/site.kinoboku.net.json](server/seed/site.kinoboku.net.json) で設定します
* seedを増やすことでサーバー証明書を増産できます
* seedのJSONファイル名はサーバーのFQDNを指定します

### nginxで試してみる

```
$ SERVER=site.kinoboku.net docker-compose up test_nginx
```

https://localhost:8443

これで試せるが、2つの理由で怒られる。

1. 署名に使ったCAが信頼できない
2. ドメイン名が証明書のものと違う（localhostだから）

そこでまず、`/etc/hosts` に以下を登録する。

```
127.0.0.1    site.kinoboku.net
```

次に`./ca/crt` を信頼できるルート証明書としてブラウザに登録する。

https://site.kinoboku.net:8443

これで、証明書のエラーは出ずに`No required SSL certificate was sent` というNginxの400エラー画面が出る。（クライアント証明書を提示していないため）

クライアント証明書をブラウザに登録することで、`Welcome to nginx!`ページが表示される。
