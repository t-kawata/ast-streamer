## AIChain SIP Trunking Streamer
AIChain SIP Trunking サービス内で行われた通話の音声ストリームをリアルタイムで取得する為の実行バイナリです。
ast-streamer を使用することにより、通話をframe単位でストリームとして取得し、リアルタイムの音声認識や感情解析等を含む音声解析を行うことができます。

## ast-streamer のダウンロード
[コチラ](https://github.com/t-kawata/ast-streamer/releases) から最新バージョンのバイナリのダウンロードが可能です。

## ast-streamer のインストール
以下、`ast-streamer-linux-amd64-0.1.0` を使用することを前提とした説明を行います。

ast-streamer-linux-amd64-0.1.0 は Linux AMD64 の環境で実行可能なバイナリです。Windowsサーバー環境では使用できませんのでご注意ください。

### インストール
以下、rootユーザでの操作を前提として記述します。
```
mkdir -p /usr/local/ast-streamer/bin -m 755
mkdir -p /usr/local/ast-streamer/log -m 755
wget https://github.com/t-kawata/ast-streamer/releases/download/v0.1.0/ast-streamer-linux-amd64-0.1.0 -O /usr/local/ast-streamer/bin/ast-streamer-linux-amd64-0.1.0
chmod 755 /usr/local/ast-streamer/bin/ast-streamer-linux-amd64-0.1.0
ln -s /usr/local/ast-streamer/bin/ast-streamer-linux-amd64-0.1.0 /usr/local/bin/ast-streamer
```