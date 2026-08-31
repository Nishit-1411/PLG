#!/bin/bash

set -e

PROMETHEUS_VERSION="3.5.0"
ARCH="linux-amd64"

USER="prometheus"
GROUP="prometheus"

BIN_DIR="/usr/local/bin"
CONFIG_DIR="/etc/prometheus"
DATA_DIR="/var/lib/prometheus"

DOWNLOAD_URL="https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.${ARCH}.tar.gz"

echo "Installing Prometheus v${PROMETHEUS_VERSION}..."

apt-get update
apt-get install -y wget tar

groupadd --system ${GROUP} 2>/dev/null || true
useradd --system --no-create-home --shell /usr/sbin/nologin --gid ${GROUP} ${USER} 2>/dev/null || true

mkdir -p ${CONFIG_DIR}
mkdir -p ${DATA_DIR}

cd /tmp

rm -rf prometheus-${PROMETHEUS_VERSION}.${ARCH}
rm -f prometheus.tar.gz

wget -q ${DOWNLOAD_URL} -O prometheus.tar.gz

tar -xzf prometheus.tar.gz

cd prometheus-${PROMETHEUS_VERSION}.${ARCH}

install -m 0755 prometheus ${BIN_DIR}/prometheus
install -m 0755 promtool ${BIN_DIR}/promtool

cp prometheus.yml ${CONFIG_DIR}/prometheus.yml

chown -R ${USER}:${GROUP} ${CONFIG_DIR}
chown -R ${USER}:${GROUP} ${DATA_DIR}

chmod 755 ${CONFIG_DIR}
chmod 640 ${CONFIG_DIR}/prometheus.yml

cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=${USER}
Group=${GROUP}
Type=simple
ExecStart=${BIN_DIR}/prometheus \
  --config.file=${CONFIG_DIR}/prometheus.yml \
  --storage.tsdb.path=${DATA_DIR}

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable prometheus
systemctl restart prometheus

rm -rf /tmp/prometheus.tar.gz
rm -rf /tmp/prometheus-${PROMETHEUS_VERSION}.${ARCH}

systemctl status prometheus --no-pager

echo "Prometheus v${PROMETHEUS_VERSION} installed successfully."