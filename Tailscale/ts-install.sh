#!/usr/bin/env bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "tailscale service setup step 1"
echo "tailscale service setup: setup service" | systemd-cat -p info
mkdir /etc/tailscale

cat > /etc/tailscale/tailscale.sh <<EOF
#!/usr/bin/env bash
exec tailscale up &
exec tailscale web --readonly --listen :9101 &
EOF
chmod +x /etc/tailscale/tailscale.sh


echo "tailscale service setup step 2"
cat > /etc/systemd/system/tailscale.service <<EOF
[Unit]
Description=Tailscale client
After=network.target
After=systemd-user-sessions.service
After=network-online.target

[Service]
Type=simple
RemainAfterExit=yes
ExecStart=/bin/bash -c /etc/tailscale/tailscale.sh
 
[Install]
WantedBy=multi-user.target
EOF

echo "tailscale service setup step 3"
chmod 664 /etc/systemd/system/tailscale.service

systemctl enable tailscale
systemctl start tailscale

echo "done, waiting 2 sec"
sleep 2s
curl http://localhost:9101/metrics
rm node_exporter-*