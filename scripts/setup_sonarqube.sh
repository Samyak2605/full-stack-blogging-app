#!/bin/bash

# SonarQube Setup Script
# This script sets up SonarQube using Docker

echo "Starting SonarQube setup..."

# Update system
sudo apt update -y

# Install Docker (if not already installed)
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
fi

# Set required kernel parameters for SonarQube
echo "Setting kernel parameters for SonarQube..."
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=65536

# Make kernel parameters persistent
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
echo 'fs.file-max=65536' | sudo tee -a /etc/sysctl.conf

# Create directory for SonarQube data
sudo mkdir -p /opt/sonarqube-data
sudo chmod 777 /opt/sonarqube-data

# Run SonarQube container
echo "Starting SonarQube container..."
sudo docker run -d \
    --name sonarqube \
    -p 9000:9000 \
    -v /opt/sonarqube-data:/opt/sonarqube/data \
    sonarqube:lts-community

# Wait for SonarQube to start
echo "Waiting for SonarQube to start (this may take a few minutes)..."
sleep 60

# Check container status
sudo docker ps | grep sonarqube

echo "SonarQube setup completed!"
echo "Access SonarQube at: http://<your-server-ip>:9000"
echo "Default username: admin"
echo "Default password: admin"
echo "Please change the default password after first login."
