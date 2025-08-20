#!/bin/bash

# Terraform Installation Script
# This script installs Terraform on Ubuntu

echo "Starting Terraform installation..."

# Update system
sudo apt-get update -y

# Install required packages
sudo apt-get install -y gnupg software-properties-common

# Install the HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Verify the key's fingerprint
gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

# Add the official HashiCorp repository to your system
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update package information
sudo apt update -y

# Install Terraform
sudo apt-get install terraform -y

# Verify installation
terraform -version

echo "Terraform installation completed!"
echo "Terraform version:"
terraform -version
