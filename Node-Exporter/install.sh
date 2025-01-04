#!/usr/bin/env bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "STEP 1/3: Creating user."
echo "node exporer setup: creating users" | systemd-cat -p info
groupadd -f node_exporter
useradd -g node_exporter --no-create-home --shell /bin/false node_exporter
mkdir /etc/node_exporter
chown node_exporter:node_exporter /etc/node_exporter
echo "node exporer setup: download and extract file" | systemd-cat -p info

echo "STEP 2/3: Downloading and installing files"
wget \
  https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz \
  -q
tar -xvf node_exporter-1.8.2.linux-amd64.tar.gz
mv node_exporter-1.8.2.linux-amd64/node_exporter /etc/node_exporter/
chown node_exporter:node_exporter /etc/node_exporter

echo "STEP 3/3: Setup service"
echo "node exporer setup: setup service" | systemd-cat -p info
cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network.target
After=systemd-user-sessions.service
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/etc/node_exporter/node_exporter\
  --web.listen-address=:9102\
  --collector.disable-defaults\
  --collector.cpu\
  --collector.diskstats\
  --collector.loadavg\
  --collector.meminfo\
  --collector.stat
TimeoutSec=30
Restart=on-failure
RestartSec=30
StartLimitInterval=350
StartLimitBurst=10
 
[Install]
WantedBy=multi-user.target
EOF

chmod 664 /etc/systemd/system/node_exporter.service
systemctl enable node_exporter
systemctl start node_exporter

echo "STEP 3/3. Waiting 2 sec and test."
sleep 2s
curl http://localhost:9102/metrics