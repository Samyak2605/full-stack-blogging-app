# DevOps CI/CD Blog App Deployment Guide

This comprehensive guide will walk you through deploying a production-level blog application using Jenkins, SonarQube, Nexus, Trivy, EKS, and monitoring tools.

## Prerequisites

- AWS Account with appropriate permissions
- Basic understanding of CI/CD, Docker, and Kubernetes
- Domain name (optional for Step 7)

## Step 1: Set up Git Repository and Security Token ✅

The source code has been cloned and is ready. Next, create a GitHub personal access token:

1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate a new token with repo permissions
3. Save the token securely

## Step 2: Setup Required Servers

### 2.1 Create EC2 Instances

Create the following EC2 instances in AWS:

1. **Jenkins Server**: t2.large, 25GB storage, ports 22, 8080
2. **SonarQube Server**: t2.medium, 20GB storage, ports 22, 9000
3. **Nexus Server**: t2.medium, 20GB storage, ports 22, 8081
4. **Monitoring Server**: t2.large, 25GB storage, ports 22, 3000, 9090, 9115
5. **EKS Management Server**: t2.medium, 15GB storage, port 22

### 2.2 Security Group Configuration

Allow the following ports in your security group:
- SSH (22): Your IP
- Jenkins (8080): 0.0.0.0/0
- SonarQube (9000): 0.0.0.0/0
- Nexus (8081): 0.0.0.0/0
- Grafana (3000): 0.0.0.0/0
- Prometheus (9090): 0.0.0.0/0
- Blackbox (9115): 0.0.0.0/0
- Email SMTP (465): 0.0.0.0/0

## Step 3: Set up Jenkins, SonarQube and Nexus

### 3.1 Jenkins Setup

SSH into your Jenkins server and run:

```bash
chmod +x scripts/install_jenkins.sh
./scripts/install_jenkins.sh
```

Then install Docker:
```bash
chmod +x install_docker.sh
./install_docker.sh
```

Access Jenkins at `http://<jenkins-ip>:8080` and follow the setup wizard.

### 3.2 SonarQube Setup

SSH into your SonarQube server and run:

```bash
chmod +x scripts/setup_sonarqube.sh
./scripts/setup_sonarqube.sh
```

Access SonarQube at `http://<sonarqube-ip>:9000` (admin/admin)

### 3.3 Nexus Setup

SSH into your Nexus server and run:

```bash
chmod +x scripts/setup_nexus.sh
./scripts/setup_nexus.sh
```

Access Nexus at `http://<nexus-ip>:8081`

## Step 4: Configure Jenkins Plugins and Integrations

### 4.1 Install Jenkins Plugins

In Jenkins, go to Manage Jenkins → Plugins → Available and install:
- SonarQube Scanner
- Eclipse Temurin Installer
- Config File Provider
- Maven Integration
- Pipeline Maven Integration
- Kubernetes
- Kubernetes Credentials
- Kubernetes CLI
- Kubernetes Client API
- Docker
- Docker Pipeline
- Extended Email Notification

### 4.2 Configure Tools

In Manage Jenkins → Tools, configure:
- **JDK**: Add JDK 17 (auto-install from Adoptium)
- **Maven**: Add Maven (auto-install)
- **SonarQube Scanner**: Add SonarQube Scanner
- **Docker**: Add Docker

### 4.3 Configure SonarQube

1. In SonarQube, generate a token: Administration → Security → Users → Tokens
2. In Jenkins: Manage Jenkins → Credentials → Add Secret Text with the token
3. In Jenkins: Manage Jenkins → System → SonarQube Servers → Add SonarQube

### 4.4 Configure Nexus

1. Update the `pom.xml` distributionManagement URLs with your Nexus server IP
2. In Jenkins: Manage Jenkins → Managed Files → Add Global Maven settings.xml
3. Configure the servers section with Nexus credentials
4. Add Nexus credentials to Jenkins

### 4.5 Install Trivy

On the Jenkins server:
```bash
wget https://github.com/aquasecurity/trivy/releases/download/v0.50.0/trivy_0.50.0_Linux-64bit.deb
sudo dpkg -i trivy_0.50.0_Linux-64bit.deb
```

### 4.6 Configure DockerHub

1. Create a private repository on DockerHub
2. Add DockerHub credentials to Jenkins
3. Update the Jenkinsfile with your DockerHub username and repository

## Step 5: Create CI/CD Pipeline

The Jenkinsfile is already configured. Update the following:
- DockerHub username and repository name
- SonarQube server configuration
- Email notification settings

## Step 6: Create EKS Cluster

### 6.1 Setup EKS Management Server

SSH into your EKS management server and run:

```bash
# Install AWS CLI
chmod +x scripts/install_aws_cli.sh
./scripts/install_aws_cli.sh

# Install Terraform
chmod +x scripts/install_terraform.sh
./scripts/install_terraform.sh

# Install kubectl
chmod +x scripts/install_kubectl.sh
./scripts/install_kubectl.sh
```

### 6.2 Configure AWS Credentials

```bash
aws configure
```

Enter your AWS Access Key, Secret Key, region, and output format.

### 6.3 Deploy EKS Cluster

```bash
cd EKS_Terraform
terraform init
terraform plan
terraform apply --auto-approve
```

### 6.4 Configure kubectl

```bash
aws eks --region eu-west-2 update-kubeconfig --name devopsshack-cluster
kubectl get nodes
```

### 6.5 Setup RBAC

```bash
kubectl create namespace webapps
kubectl apply -f k8s/rbac/
```

### 6.6 Create Docker Registry Secret

```bash
kubectl create secret docker-registry regcred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=<your-username> \
  --docker-password=<your-password> \
  --namespace=webapps
```

### 6.7 Get Service Account Token

```bash
kubectl describe secret jenkins-secret -n webapps
```

Add this token to Jenkins credentials.

## Step 7: Configure Email Notifications

1. Generate an app password for your Gmail account
2. In Jenkins: Manage Jenkins → System → Email Notification
3. Configure SMTP settings and test connection

## Step 8: Monitor the Application

### 8.1 Setup Monitoring Server

SSH into your monitoring server and run:

```bash
chmod +x scripts/setup_monitoring.sh
./scripts/setup_monitoring.sh
```

### 8.2 Configure Prometheus

```bash
sudo cp configs/prometheus.yml /etc/prometheus/
sudo cp configs/prometheus.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
```

### 8.3 Configure Blackbox Exporter

```bash
sudo cp configs/blackbox.yml /etc/blackbox_exporter/
sudo cp configs/blackbox.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start blackbox
sudo systemctl enable blackbox
```

### 8.4 Start Grafana

```bash
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

### 8.5 Configure Grafana

1. Access Grafana at `http://<monitoring-ip>:3000` (admin/admin)
2. Add Prometheus data source: `http://localhost:9090`
3. Import dashboard 7587 for Blackbox monitoring

## Step 9: Deploy the Application

1. Run the Jenkins pipeline
2. Monitor the deployment in Grafana
3. Access your application via the LoadBalancer URL

## Troubleshooting

- Check service logs: `sudo journalctl -u <service-name>`
- Verify container status: `docker ps`
- Check Kubernetes pods: `kubectl get pods -n webapps`
- Monitor resource usage in Grafana

## Security Best Practices

- Use least privilege IAM roles
- Enable VPC flow logs
- Configure security groups restrictively
- Regularly update all components
- Use secrets management for sensitive data

## Cleanup

To destroy the infrastructure:

```bash
cd EKS_Terraform
terraform destroy --auto-approve
```

Stop and remove Docker containers on all servers.
