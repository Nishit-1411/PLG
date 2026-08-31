#!/bin/bash

# Define Node Exporter version
VERSION="1.12.1"

# Update system packages
echo "Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

# Create a user for Node Exporter
echo "Creating node_exporter user..."
sudo useradd --no-create-home --shell /bin/false node_exporter

# Download and extract Node Exporter
echo "Downloading Node Exporter..."
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-amd64.tar.gz

echo "Extracting Node Exporter..."
tar xvf node_exporter-${VERSION}.linux-amd64.tar.gz
sudo mv node_exporter-${VERSION}.linux-amd64/node_exporter /usr/local/bin/

# Set ownership and permissions
echo "Setting permissions..."
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create a systemd service file
echo "Creating systemd service file..."
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Node Exporter
echo "Starting Node Exporter service..."
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Check service status
echo "Checking service status..."
sudo systemctl status node_exporter --no-pager

# Confirm Node Exporter is running
echo "Node Exporter is running. You can verify by accessing:"
echo "http://<your-server-ip>:9100/metrics"

exit 0