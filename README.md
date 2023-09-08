## AIChain SIP Trunking Streamer
AIChain SIP Trunking サービス内で行われた通話の音声ストリームをリアルタイムで取得する為の実行バイナリです。
ast-streamer を使用することにより、通話をframe単位でストリームとして取得し、リアルタイムの音声認識や感情解析等を含む音声解析を行うことができます。

## ast-streamer のダウンロード
[コチラ](https://github.com/t-kawata/ast-streamer/releases) から最新バージョンのバイナリのダウンロードが可能です。

## ast-streamer のインストール
以下、`ast-streamer-linux-amd64-0.1.0` を使用することを前提とした説明を行います。

ast-streamer-linux-amd64-0.1.0 は Linux AMD64 の環境で実行可能なバイナリです。Windowsサーバー環境では使用できませんのでご注意ください。

### インストール
以下のコマンドを実行して ast-streamer をインストールしてください。
```
curl -s https://raw.githubusercontent.com/t-kawata/ast-streamer/master/tools/install-linux-amd64-0.1.0.sh | sudo bash
```

### 環境変数の設定
以下の環境変数を設定します。

| 環境変数名 | 説明 | 例 |
|--|--|--|
| AST_STREAMER_PORT | ast-streamer の Listen Port. | AST_STREAMER_PORT="3030" |
| AST_STREAMER_CODE | AIChain発行の起動認証コード。 | AST_STREAMER_CODE="OkijhAs3ka87・・・" |
| AST_STREAMER_LEFT | LEFT側の音声ストリームを受け取る Websocket サーバーの URL。URL内に `{id}` という文字列を設置すると、ストリームの開始時に、通話の識別IDに置換されます。 | AST_STREAMER_LEFT="ws://localhost:3031/left/{id}" |
| AST_STREAMER_RIGHT | RIGHT側の音声ストリームを受け取る Websocket サーバーの URL。URL内に `{id}` という文字列を設置すると、ストリームの開始時に、通話の識別IDに置換されます。 | AST_STREAMER_RIGHT="ws://localhost:3031/right/{id}" |
| AST_STREAMER_MIX | LEFT/RIGHTの混合音声ストリームを受け取る Websocket サーバーの URL。URL内に `{id}` という文字列を設置すると、ストリームの開始時に、通話の識別IDに置換されます。 | AST_STREAMER_MIX="ws://localhost:3031/mix/{id}" |

`/etc/sysconfig/ast-streamer` の内容を適切に編集してください。  
以下設定例となります。`AST_STREAMER_CODE` に、AIChainより発行する適切な起動認証コードが設定されていない場合、正常に起動できませんのでご注意ください。
```
cat <<EOF > /etc/sysconfig/ast-streamer
AST_STREAMER_PORT="3030"
AST_STREAMER_CODE="OkijhAs3ka87・・・"
AST_STREAMER_LEFT="ws://localhost:3031/left/{id}"
AST_STREAMER_RIGHT="ws://localhost:3031/right/{id}"
AST_STREAMER_MIX="ws://localhost:3031/mix/{id}"
EOF
```

これらの環境変数は、インストール時に作成される `/lib/systemd/system/ast-streamer.service` 内でのみ以下のように使用されます。
```
ExecStart=/usr/local/bin/ast-streamer -o /usr/local/ast-streamer/log/syslog -p ${AST_STREAMER_PORT} -c ${AST_STREAMER_CODE} -l ${AST_STREAMER_LEFT} -r ${AST_STREAMER_RIGHT}  -m ${AST_STREAMER_MIX}
```
インストール時に作成される service ファイルを用いても構いませんし、`ast-streamer` コマンドを利用した独自の service ファイルに置き換えても構いません。インストール実行後に `ast-streamer -h` で使用方法を確認可能です。
```
$ ast-streamer -h
Usage of streamer:
  -c string
    	Auth code issued by AIChain.
  -l string
    	Target websocket url to relay left audio stream frames to. '{id}' will be replaced with the id got from connection. (default "ws://localhost:3031/left/{id}")
  -ll string
    	Log Level. (default "info")
  -m string
    	Target websocket url to relay mixed audio stream frames to. '{id}' will be replaced with the id got from connection. (default "ws://localhost:3031/mix/{id}")
  -o string
    	Destination of log output. (default "stdout")
  -p string
    	Websocket port to listen. (default "3030")
  -r string
    	Target websocket url to relay right audio stream frames to. '{id}' will be replaced with the id got from connection. (default "ws://localhost:3031/right/{id}")
```
環境変数が設定できたら、起動してください。
```
systemctl start ast-streamer
```

## 音声ストリームの受取り方
### 音声ストリームの流れ
音声ストリームは

![draw.jpg](https://github.com/t-kawata/ast-streamer/blob/master/assets/img/draw.jpg?raw=true)