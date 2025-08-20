#!/bin/bash

# Quick Setup Script for DevOps Blog App Project
# This script helps you set up the entire infrastructure quickly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        exit 1
    fi
}

# Function to update system
update_system() {
    print_status "Updating system packages..."
    sudo apt update -y
    sudo apt upgrade -y
    print_success "System updated successfully"
}

# Function to install common dependencies
install_common_deps() {
    print_status "Installing common dependencies..."
    sudo apt install -y curl wget unzip git vim nano htop tree software-properties-common apt-transport-https ca-certificates gnupg lsb-release
    print_success "Common dependencies installed"
}

# Function to display menu
show_menu() {
    echo ""
    echo "=========================================="
    echo "  DevOps Blog App Quick Setup"
    echo "=========================================="
    echo "1. Setup Jenkins Server"
    echo "2. Setup SonarQube Server"
    echo "3. Setup Nexus Server"
    echo "4. Setup Monitoring Server"
    echo "5. Setup EKS Management Server"
    echo "6. Install Docker Only"
    echo "7. Update System & Install Dependencies"
    echo "8. Exit"
    echo "=========================================="
    echo -n "Please select an option [1-8]: "
}

# Function to setup Jenkins
setup_jenkins() {
    print_status "Setting up Jenkins server..."
    update_system
    install_common_deps
    
    # Install Java
    print_status "Installing Java 17..."
    sudo apt install -y openjdk-17-jre-headless
    
    # Install Jenkins
    print_status "Installing Jenkins..."
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
        /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
        https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
        /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt update -y
    sudo apt install -y jenkins
    
    # Install Docker
    install_docker
    
    # Start Jenkins
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    
    # Add jenkins user to docker group
    sudo usermod -aG docker jenkins
    sudo systemctl restart jenkins
    
    print_success "Jenkins setup completed!"
    print_status "Access Jenkins at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
    print_status "Initial password: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"
}

# Function to setup SonarQube
setup_sonarqube() {
    print_status "Setting up SonarQube server..."
    update_system
    install_common_deps
    install_docker
    
    # Set kernel parameters
    sudo sysctl -w vm.max_map_count=262144
    sudo sysctl -w fs.file-max=65536
    echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
    echo 'fs.file-max=65536' | sudo tee -a /etc/sysctl.conf
    
    # Create data directory
    sudo mkdir -p /opt/sonarqube-data
    sudo chmod 777 /opt/sonarqube-data
    
    # Run SonarQube container
    sudo docker run -d \
        --name sonarqube \
        -p 9000:9000 \
        -v /opt/sonarqube-data:/opt/sonarqube/data \
        sonarqube:lts-community
    
    print_success "SonarQube setup completed!"
    print_status "Access SonarQube at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9000"
    print_status "Default credentials: admin/admin"
}

# Function to setup Nexus
setup_nexus() {
    print_status "Setting up Nexus server..."
    update_system
    install_common_deps
    install_docker
    
    # Create data directory
    sudo mkdir -p /opt/nexus-data
    sudo chown -R 200:200 /opt/nexus-data
    
    # Run Nexus container
    sudo docker run -d \
        --name nexus \
        -p 8081:8081 \
        -v /opt/nexus-data:/nexus-data \
        sonatype/nexus3
    
    print_success "Nexus setup completed!"
    print_status "Access Nexus at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8081"
    print_status "Default username: admin"
    print_warning "Initial password will be available in a few minutes. Check with:"
    print_status "sudo docker exec -it nexus cat /nexus-data/admin.password"
}

# Function to setup monitoring
setup_monitoring() {
    print_status "Setting up monitoring server (Prometheus, Grafana, Blackbox)..."
    update_system
    install_common_deps
    
    # Install Grafana
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
    sudo apt update -y
    sudo apt install -y grafana
    
    # Install Prometheus
    wget https://github.com/prometheus/prometheus/releases/download/v2.40.0/prometheus-2.40.0.linux-amd64.tar.gz
    tar xvf prometheus-2.40.0.linux-amd64.tar.gz
    sudo cp prometheus-2.40.0.linux-amd64/prometheus /usr/local/bin/
    sudo cp prometheus-2.40.0.linux-amd64/promtool /usr/local/bin/
    sudo useradd --no-create-home --shell /bin/false prometheus
    sudo mkdir -p /etc/prometheus /var/lib/prometheus
    sudo cp -r prometheus-2.40.0.linux-amd64/consoles /etc/prometheus
    sudo cp -r prometheus-2.40.0.linux-amd64/console_libraries /etc/prometheus
    sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus /usr/local/bin/prometheus /usr/local/bin/promtool
    
    # Install Blackbox Exporter
    wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.24.0/blackbox_exporter-0.24.0.linux-amd64.tar.gz
    tar xvf blackbox_exporter-0.24.0.linux-amd64.tar.gz
    sudo cp blackbox_exporter-0.24.0.linux-amd64/blackbox_exporter /usr/local/bin/
    sudo useradd --no-create-home --shell /bin/false blackbox
    sudo mkdir -p /etc/blackbox_exporter
    sudo chown blackbox:blackbox /usr/local/bin/blackbox_exporter /etc/blackbox_exporter
    
    # Start services
    sudo systemctl start grafana-server
    sudo systemctl enable grafana-server
    
    # Clean up
    rm -rf prometheus-* blackbox_exporter-*
    
    print_success "Monitoring setup completed!"
    print_status "Access Grafana at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000"
    print_status "Default credentials: admin/admin"
    print_warning "Don't forget to configure Prometheus and Blackbox Exporter configs!"
}

# Function to setup EKS management server
setup_eks_management() {
    print_status "Setting up EKS management server..."
    update_system
    install_common_deps
    
    # Install AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws
    
    # Install Terraform
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update -y
    sudo apt install -y terraform
    
    # Install kubectl
    sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt update -y
    sudo apt install -y kubectl
    
    print_success "EKS management server setup completed!"
    print_status "Next steps:"
    print_status "1. Run 'aws configure' to set up AWS credentials"
    print_status "2. Use Terraform to deploy EKS cluster"
    print_status "3. Configure kubectl for EKS"
}

# Function to install Docker
install_docker() {
    print_status "Installing Docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -y
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    print_success "Docker installed successfully"
}

# Main execution
main() {
    check_root
    
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1) setup_jenkins ;;
            2) setup_sonarqube ;;
            3) setup_nexus ;;
            4) setup_monitoring ;;
            5) setup_eks_management ;;
            6) install_docker ;;
            7) update_system && install_common_deps ;;
            8) print_status "Goodbye!"; exit 0 ;;
            *) print_error "Invalid option. Please try again." ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main "$@"
