#!/usr/bin/env bash
sudo groupadd -f node-exporter
sudo useradd -g node-exporter --no-create-home --shell /bin/false node_exporter
sudo mkdir /etc/node-exporter
sudo chown node-exporter:node-exporter /etc/node-exporter