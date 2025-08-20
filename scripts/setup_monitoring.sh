#!/bin/bash

# Monitoring Setup Script
# This script installs Prometheus, Grafana, and Blackbox Exporter

echo "Starting monitoring tools setup..."

# Update system
sudo apt-get update -y

# Create monitoring user
sudo useradd --no-create-home --shell /bin/false monitoring
sudo useradd --no-create-home --shell /bin/false prometheus
sudo useradd --no-create-home --shell /bin/false grafana

# Create directories
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus
sudo mkdir -p /etc/blackbox_exporter
sudo mkdir -p /var/lib/grafana

# Set ownership
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
sudo chown monitoring:monitoring /etc/blackbox_exporter
sudo chown grafana:grafana /var/lib/grafana

# Install Prometheus
echo "Installing Prometheus..."
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.40.0/prometheus-2.40.0.linux-amd64.tar.gz
tar xvf prometheus-2.40.0.linux-amd64.tar.gz
sudo cp prometheus-2.40.0.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.40.0.linux-amd64/promtool /usr/local/bin/
sudo cp -r prometheus-2.40.0.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-2.40.0.linux-amd64/console_libraries /etc/prometheus

# Set ownership
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

# Install Blackbox Exporter
echo "Installing Blackbox Exporter..."
cd /tmp
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.24.0/blackbox_exporter-0.24.0.linux-amd64.tar.gz
tar xvf blackbox_exporter-0.24.0.linux-amd64.tar.gz
sudo cp blackbox_exporter-0.24.0.linux-amd64/blackbox_exporter /usr/local/bin/
sudo chown monitoring:monitoring /usr/local/bin/blackbox_exporter

# Install Grafana
echo "Installing Grafana..."
sudo apt-get install -y software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
sudo apt-get update -y
sudo apt-get install -y grafana

# Clean up
rm -rf /tmp/prometheus-* /tmp/blackbox_exporter-*

echo "Monitoring tools installation completed!"
echo "Next steps:"
echo "1. Configure Prometheus (/etc/prometheus/prometheus.yml)"
echo "2. Configure Blackbox Exporter (/etc/blackbox_exporter/blackbox.yml)"
echo "3. Start services with systemd"
echo "4. Access Grafana at http://<your-ip>:3000 (admin/admin)"
