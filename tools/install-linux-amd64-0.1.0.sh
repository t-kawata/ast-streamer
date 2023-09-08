#!/bin/bash
mkdir -p /usr/local/ast-streamer/bin -m 755
mkdir -p /usr/local/ast-streamer/log -m 755
wget https://github.com/t-kawata/ast-streamer/releases/download/v0.1.0/ast-streamer-linux-amd64-0.1.0 -O /usr/local/ast-streamer/bin/ast-streamer-linux-amd64-0.1.0
chmod 755 /usr/local/ast-streamer/bin/ast-streamer-linux-amd64-0.1.0
ln -s /usr/local/ast-streamer/bin/ast-streamer-linux-amd64-0.1.0 /usr/local/bin/ast-streamer