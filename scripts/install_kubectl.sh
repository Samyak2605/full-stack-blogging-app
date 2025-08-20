#!/bin/bash

# Kubectl Installation Script
# This script installs kubectl on Ubuntu

echo "Starting kubectl installation..."

# Update system
sudo apt-get update -y

# Install required packages
sudo apt-get install -y ca-certificates curl

# Download the Google Cloud public signing key
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update apt package index
sudo apt-get update -y

# Install kubectl
sudo apt-get install -y kubectl

# Alternative installation using snap (if the above fails)
# sudo snap install kubectl --classic

# Verify installation
kubectl version --client

echo "kubectl installation completed!"
echo "kubectl version:"
kubectl version --client

echo "To configure kubectl for your EKS cluster, run:"
echo "aws eks --region <your-region> update-kubeconfig --name <cluster-name>"
