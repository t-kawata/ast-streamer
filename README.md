## AIChain SIP Trunking Streamer
AIChain SIP Trunking サービス内で行われた通話の音声ストリームをリアルタイムで取得する為の実行バイナリです。
ast-streamer を使用することにより、通話をframe単位でストリームとして取得し、リアルタイムの音声認識や感情解析等を含む音声解析を行うことができます。

## ast-streamer のダウンロード
[コチラ](https://github.com/t-kawata/ast-streamer/releases) から最新バージョンのバイナリのダウンロードが可能です。

## ast-streamer のインストール
以下、`ast-streamer-linux-amd64-0.1.1` を使用することを前提とした説明を行います。

ast-streamer-linux-amd64-0.1.1 は Linux AMD64 の環境で実行可能なバイナリです。Windowsサーバー環境では使用できませんのでご注意ください。

### インストール
以下のコマンドを実行して ast-streamer をインストールしてください。
```
curl -s https://raw.githubusercontent.com/t-kawata/ast-streamer/master/tools/install-linux-amd64-0.1.1.sh | sudo bash
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
音声ストリームは以下の流れで、リアルタイムに渡されます。

![draw.jpg](https://github.com/t-kawata/ast-streamer/blob/master/assets/img/draw.jpg?raw=true)

御社設備内に、上述の手順で `ast-streamer` を設置頂くと、ast-streamer は AIChain SIP-Trunking サービスから音声ストリームを受け取る為のスタンバイ状態となります。

上図における「御社設備」内に `ast-streamer` が起動しており、`/etc/sysconfig/ast-streamer` において `AST_STREAMER_PORT="3030"` が設定されている場合、`ws://0.0.0.0:3030/` で WebSocket の LISTEN がされている状態です。

当該御社サーバが Public に sample.com というドメインを持っていると仮定すると、AIChain SIP Trunking サービスからの音声ストリーム受け取り口として、`ws://sample.com:3030/` が利用できる状態です（要FW設定）。

[★ 音声ストリーム連携作成API](https://veiled-node-a86.notion.site/AIChain-SIP-Trunking-API-Doc-for-v0-4a6e590f6f624b7cb648bd71a18613f5#fa9f04a3644243ad8c9e93c80481ba3c) を利用して、音声ストリーム受け取り口である `ws://sample.com:3030/` を登録すると、15分以内に連携が開始されます。

AIChain SIP Trunking サービス内において通話が開始されると、自動的に音声ストリームが ast-streamer に流れます。

AIChain SIP Trunking サービスから音声ストリームを受け取った ast-streamer は、ast-streamer 起動のために設定した `AST_STREAMER_LEFT`、`AST_STREAMER_RIGHT`、`AST_STREAMER_MIX` の WebSocket サーバに対して、音声ストリームをリレーします。

この時、`AST_STREAMER_LEFT`、`AST_STREAMER_RIGHT`、`AST_STREAMER_MIX` の WebSocket サーバは、御社独自のもので構いませんので、受け取った音声ストリームは、音声認識や解析等々、御社が自由に扱うことが可能です。

### 音声ストリーム受取用WebSocketサーバの実装例
ここでは、`AST_STREAMER_LEFT`、`AST_STREAMER_RIGHT`、`AST_STREAMER_MIX` に指定できるWebSocketサーバの実装例を NodeJS v18.x を前提に示します。`ast-streamer` をインストールしたサーバと同じローカルに以下の実装を行うことを前提とします。

#### NodeJS v18.x のインストール
例）Ubuntu 22.04 LTS
```
apt-get update

apt-get install -y ca-certificates curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=18
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

apt-get update

apt-get install nodejs -y
```

#### 音声ストリーム受取用WebSocketサーバ構築
作業ディレクトリ作成。
```
mkdir -p /usr/local/stream_catcher -m 755
```
依存関係インストール。
```
cd /usr/local/stream_catcher
npm install ws@8.13.0
```
WebSocketサーバの記述。
```
cat <<EOF > /usr/local/stream_catcher/server.js
#!/usr/bin/node
const http = require('http')
const WebSocket = require('ws')
const url = require('url')
const fs = require('fs')

const server = http.createServer()
const wss1 = new WebSocket.Server({ noServer: true })
const wss2 = new WebSocket.Server({ noServer: true })
const wss3 = new WebSocket.Server({ noServer: true })
const port = 3031

const getID = (pathname) => {
  const match = pathname.match(/([0-9a-f]{8})-([0-9a-f]{4})-([0-9a-f]{4})-([0-9a-f]{4})-([0-9a-f]{12})/);
  return match ? match[0] : '';
}

wss1.on('connection', (ws, id) => {
  console.log("got left connection ")
  var filestream = fs.createWriteStream(id + '-left.raw')
  ws.on('message', (message) => { console.log('received left frame..'); filestream.write(message) })
})
wss2.on('connection', (ws, id) => {
  console.log("got mix connection ")
  var filestream = fs.createWriteStream(id + '-mix.raw')
  ws.on('message', (message) => { console.log('received mix frame..'); filestream.write(message) })
})
wss3.on('connection', (ws, id) => {
  console.log("got right connection ")
  var filestream = fs.createWriteStream(id + '-right.raw')
  ws.on('message', (message) => { console.log('received right frame..'); filestream.write(message) })
})

server.on('upgrade', function upgrade(request, socket, head) {
  const pathname = url.parse(request.url).pathname
  const id = getID(pathname)
  if (/^\/left\//.test(pathname))       wss1.handleUpgrade(request, socket, head, (ws) => { wss1.emit('connection', ws, id, request) })
  else if (/^\/mix\//.test(pathname))   wss2.handleUpgrade(request, socket, head, (ws) => { wss2.emit('connection', ws, id, request) })
  else if (/^\/right\//.test(pathname)) wss3.handleUpgrade(request, socket, head, (ws) => { wss3.emit('connection', ws, id, request) })
  else socket.destroy()
})

console.log(\`Start running on port \${port}.\`)
server.listen(port)
EOF
chmod 755 /usr/local/stream_catcher/server.js
```
起動。
```
/usr/local/stream_catcher/server.js
```

`server.js` が起動できたら、`/etc/sysconfig/ast-streamer` の `AST_STREAMER_LEFT`、`AST_STREAMER_RIGHT`、`AST_STREAMER_MIX` をそれぞれ以下のように設定してください。
```
AST_STREAMER_LEFT="ws://localhost:3031/left/{id}"
AST_STREAMER_RIGHT="ws://localhost:3031/right/{id}"
AST_STREAMER_MIX="ws://localhost:3031/mix/{id}"
```
これらの環境変数の設定により、`ast-streamer` と `server.js` は音声ストリームをリアルタイムにリレーする関係となります。

環境変数が設定できたら、`ast-streamer` を再起動してください。
```
systemctl restart ast-streamer
```

![draw2.jpg](https://github.com/t-kawata/ast-streamer/blob/master/assets/img/draw2.jpg?raw=true)

#### AID について
`ast-streamer` から `server.js` に対しては URL 内の置換文字列として AID が渡されます。AID は Answer ID であり、通話が成立したコールに対して一意に発行されるUUID形式のIDです。

`ast-streamer` の起動環境変数で以下のように記述されている場合、
```
AST_STREAMER_LEFT="ws://localhost:3031/left/{id}"
AST_STREAMER_RIGHT="ws://localhost:3031/right/{id}"
AST_STREAMER_MIX="ws://localhost:3031/mix/{id}"
```
`{id}` の部分が、その通話の AID に置換された状態で `server.js` の WebSocket サーバに対して接続が試行されます。

接続が行われると、`server.js` 内の以下の箇所で通話の識別IDを取得しています。
```
server.on('upgrade', function upgrade(request, socket, head) {
  const pathname = url.parse(request.url).pathname
  const id = getID(pathname) // <- ここ
```

AIDは、AIChain SIP Trunking サービス内において取得可能な `イベント` にフィールドとして含まれています。

イベントの詳細については、[コチラ](https://veiled-node-a86.notion.site/AIChain-SIP-Trunking-API-Doc-for-v0-4a6e590f6f624b7cb648bd71a18613f5#8a469a5bac904470a0bd4cadb5de4551) をご参照ください。

例）User01からUser02への内線で、User02が電話に出た時
```
{
	"sid": "daf685a5-ed51-481a-a409-2bded858a175",
	"aid": "7bace96a-b33e-4d19-ae72-e1ba25886472",
	"event_number": 1002,
	"ws_key": "46a5c96412d1eb74ffd1c4d51a23bccddb50d414d6531aac2272effa082b467f",
	"from_user_key": "4eb2fb65f6830aa738080f7c402a9c39f8bd6783b723c934470b9bc77eebcb6d",
	"from_user_name": "User01",
	"from_user_number": "101",
	"to_user_key": "2af65d6cce0ccac654e5086617a3f5816e561abdd12ec715651c73f278b71f85",
	"to_user_name": "User02",
	"to_user_number": "102",
	"record_file": "06bbe5d7-608e-4187-a8cc-fc565bd43f2f",
	"urls": [],
	"datetime": "2023-09-07 22:22:59"
}
```
データの中には以下のような AID が含まれています。
```
"aid": "7bace96a-b33e-4d19-ae72-e1ba25886472"
```
従って、イベントを利用してデータベース等に作成したデータ（電話履歴等）と、AIDによって紐付けることが可能であり、音声ストリームを利用した解析結果等々のデータ管理に関して一貫性を保つことができます。

`server.js` が、この例における通話の音声ストリームを受け取った場合には、`server.js` を実行したディレクトリ内に、`7bace96a-b33e-4d19-ae72-e1ba25886472-left.raw`、 `7bace96a-b33e-4d19-ae72-e1ba25886472-right.raw`、`7bace96a-b33e-4d19-ae72-e1ba25886472-mix.raw` という3つの録音ファイルが生成されることになります。

#### 音声ストリームのハンドリング
上記の `server.js` では、受け取った音声ストリームのchunkを順にファイルに対して追記していくだけの処理が書かれていますので、`録音ファイル` が生成されました。しかし、録音ファイルではなく音声ストリーム自体をリアルタイムに扱いたい場合は、スクリプトを編集することで簡単に扱いを変えることが可能です。

以下の部分でストリームを順に受け取っています。
```
wss1.on('connection', (ws, id) => {
  console.log("got left connection ")
  var filestream = fs.createWriteStream(id + '-left.raw')
  ws.on('message', (message) => { console.log('received left frame..'); filestream.write(message) })
})
wss2.on('connection', (ws, id) => {
  console.log("got mix connection ")
  var filestream = fs.createWriteStream(id + '-mix.raw')
  ws.on('message', (message) => { console.log('received mix frame..'); filestream.write(message) })
})
wss3.on('connection', (ws, id) => {
  console.log("got right connection ")
  var filestream = fs.createWriteStream(id + '-right.raw')
  ws.on('message', (message) => { console.log('received right frame..'); filestream.write(message) })
})
```
この中の以下のような部分でファイルへの書き込みが行われています。
```
  var filestream = fs.createWriteStream(id + '-left.raw')
  ws.on('message', (message) => { console.log('received left frame..'); filestream.write(message) })
```
WebSocketのコネクションが `message` を受け取ったらファイルに追記するよう記述されているだけです。

この時、 `message` の実体は、Frame単位の `Byte配列` です。受け取る Byte配列 は、通信や処理上のレイテンシーを考慮しなければリアルタイムのRaw音声データとなりますので、リアルタイム解析ソリューションの構築など、ご自由にお使い頂けます。

尚、`server.js` の例のようにファイルに書き出した Raw データを WAV に変換した上で何らかのプレイヤーで再生して聞きたいようなケースでは、`sox` コマンドを利用して、以下のように変換可能です。
```
sox -r 8000 -e signed-integer -b 16 before.raw after.wav
```

`server.js` で生成されたRawファイルを一気に WAV に変換したい場合には、Rawファイルがあるディレクトリにて以下のように実行してください。
```
cat <<EOF > /usr/local/streamer/to_wav
#!/bin/bash
sox -r 8000 -e signed-integer -b 16 *-left.raw left.wav
sox -r 8000 -e signed-integer -b 16 *-mix.raw mix.wav
sox -r 8000 -e signed-integer -b 16 *-right.raw right.wav
EOF
chmod 755 /usr/local/streamer/to_wav
/usr/local/streamer/to_wav
```