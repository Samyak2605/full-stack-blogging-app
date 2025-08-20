#!/bin/bash

# AWS CLI Installation Script
# This script installs AWS CLI v2 on Ubuntu

echo "Starting AWS CLI installation..."

# Update the package list
sudo apt update -y

# Install curl if not already installed
sudo apt install curl unzip -y

# Download the AWS CLI v2 installation file
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Extract the downloaded zip file
unzip awscliv2.zip

# Run the AWS CLI installer
sudo ./aws/install

# Clean up
rm -rf awscliv2.zip aws

# Verify the installation
aws --version

echo "AWS CLI installation completed!"
echo "Run 'aws configure' to set up your credentials."
echo "You'll need:"
echo "- AWS Access Key ID"
echo "- AWS Secret Access Key"
echo "- Default region (e.g., us-east-1, eu-west-2)"
echo "- Default output format (json recommended)"
