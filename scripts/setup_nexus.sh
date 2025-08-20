#!/bin/bash

# Nexus Setup Script
# This script sets up Nexus using Docker

echo "Starting Nexus setup..."

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

# Create directory for Nexus data
sudo mkdir -p /opt/nexus-data
sudo chown -R 200:200 /opt/nexus-data

# Run Nexus container
echo "Starting Nexus container..."
sudo docker run -d \
    --name nexus \
    -p 8081:8081 \
    -v /opt/nexus-data:/nexus-data \
    sonatype/nexus3

# Wait for Nexus to start
echo "Waiting for Nexus to start (this may take a few minutes)..."
sleep 60

# Check container status
sudo docker ps | grep nexus

echo "Nexus setup completed!"
echo "Access Nexus at: http://<your-server-ip>:8081"
echo "Default username: admin"
echo "To get the initial password, run:"
echo "sudo docker exec -it nexus cat /nexus-data/admin.password"

# Display initial password
echo "Initial Nexus admin password:"
sudo docker exec -it nexus cat /nexus-data/admin.password 2>/dev/null || echo "Please wait for Nexus to fully initialize and try the command above."
