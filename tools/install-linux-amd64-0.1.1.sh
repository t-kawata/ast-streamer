#!/bin/bash
mkdir -p /usr/local/ast-streamer/bin -m 755
mkdir -p /usr/local/ast-streamer/log -m 755
wget https://github.com/t-kawata/ast-streamer/releases/download/v0.1.1/ast-streamer-linux-amd64-0.1.1 -O /usr/local/ast-streamer/bin/ast-streamer-linux-amd64-0.1.1
chmod 755 /usr/local/ast-streamer/bin/ast-streamer-linux-amd64-0.1.1
ln -s /usr/local/ast-streamer/bin/ast-streamer-linux-amd64-0.1.1 /usr/local/bin/ast-streamer
mkdir -p /etc/sysconfig -m 755
cat <<EOF > /etc/sysconfig/ast-streamer
AST_STREAMER_PORT="3030"
AST_STREAMER_CODE=""
AST_STREAMER_LEFT="ws://localhost:3031/left/{id}"
AST_STREAMER_RIGHT="ws://localhost:3031/right/{id}"
AST_STREAMER_MIX="ws://localhost:3031/mix/{id}"
EOF
cat <<EOF > /lib/systemd/system/ast-streamer.service
[Unit]
Description=AIChain SIP Trunking Streamer
Documentation=https://github.com/t-kawata/ast-streamer

[Service]
LimitNOFILE=10240
ExecStart=/usr/local/bin/ast-streamer -o /usr/local/ast-streamer/log/syslog -p \${AST_STREAMER_PORT} -c \${AST_STREAMER_CODE} -l \${AST_STREAMER_LEFT} -r \${AST_STREAMER_RIGHT}  -m \${AST_STREAMER_MIX}
Restart=always
Type = simple
RemainAfterExit=yes
User=root
Group=root
EnvironmentFile=/etc/sysconfig/ast-streamer

[Install]
WantedBy=multi-user.target
EOF
ln -s /lib/systemd/system/ast-streamer.service /etc/systemd/system/multi-user.target.wants/ast-streamer.service
systemctl daemon-reload
systemctl enable ast-streamer
