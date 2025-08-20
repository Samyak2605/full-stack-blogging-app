# DevOps CI/CD Blog App Project

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.25+-green.svg)](https://kubernetes.io/)
[![Jenkins](https://img.shields.io/badge/Jenkins-2.400+-red.svg)](https://jenkins.io/)

A production-level DevOps project demonstrating CI/CD pipeline implementation for a Spring Boot blog application using Jenkins, SonarQube, Nexus, Trivy, AWS EKS, and comprehensive monitoring with Prometheus and Grafana.

## 🏗️ Architecture Overview

This project implements a complete DevOps pipeline with the following components:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Developer     │    │   GitHub        │    │   Jenkins       │
│                 ├────▶                 ├────▶                 │
│   Git Push      │    │   Repository    │    │   CI/CD Pipeline│
└─────────────────┘    └─────────────────┘    └─────────┬───────┘
                                                         │
┌─────────────────┐    ┌─────────────────┐    ┌─────────▼───────┐
│   SonarQube     │    │     Nexus       │    │     Trivy       │
│                 │    │                 │    │                 │
│ Code Analysis   │    │ Artifact Store  │    │ Security Scan   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                         │
┌─────────────────┐    ┌─────────────────┐    ┌─────────▼───────┐
│   DockerHub     │    │   AWS EKS       │    │   Monitoring    │
│                 │    │                 │    │                 │
│ Image Registry  │    │ Kubernetes      │    │ Prometheus/     │
│                 │    │ Cluster         │    │ Grafana         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🛠️ Tools & Technologies

### Core Infrastructure
- **AWS EKS**: Container orchestration platform
- **Terraform**: Infrastructure as Code
- **Docker**: Containerization platform

### CI/CD Pipeline
- **Jenkins**: Automation server
- **Maven**: Build automation tool
- **SonarQube**: Code quality analysis
- **Nexus**: Artifact repository manager
- **Trivy**: Vulnerability scanner

### Monitoring & Observability
- **Prometheus**: Metrics collection
- **Grafana**: Metrics visualization
- **Blackbox Exporter**: Endpoint monitoring

### Application Stack
- **Spring Boot**: Java web framework
- **H2 Database**: In-memory database
- **Thymeleaf**: Template engine

## 📁 Project Structure

```
devops-blog-app/
├── configs/                    # Configuration files
│   ├── blackbox.yml           # Blackbox exporter config
│   ├── prometheus.yml         # Prometheus config
│   ├── blackbox.service       # Systemd service for Blackbox
│   ├── prometheus.service     # Systemd service for Prometheus
│   └── environment-template.env # Environment variables template
├── EKS_Terraform/             # Terraform infrastructure code
│   ├── main.tf               # Main Terraform configuration
│   ├── variables.tf          # Variable definitions
│   └── output.tf             # Output definitions
├── k8s/                      # Kubernetes manifests
│   └── rbac/                 # RBAC configurations
│       ├── serviceaccount.yaml
│       ├── role.yaml
│       ├── rolebinding.yaml
│       └── sa-secret.yaml
├── scripts/                  # Installation and setup scripts
│   ├── install_jenkins.sh    # Jenkins installation
│   ├── setup_nexus.sh        # Nexus setup
│   ├── setup_sonarqube.sh    # SonarQube setup
│   ├── install_aws_cli.sh    # AWS CLI installation
│   ├── install_terraform.sh  # Terraform installation
│   ├── install_kubectl.sh    # Kubectl installation
│   ├── setup_monitoring.sh   # Monitoring tools setup
│   └── quick-setup.sh        # Automated setup script
├── src/                      # Application source code
│   ├── main/java/           # Java source files
│   └── test/java/           # Test files
├── deployment-service.yml    # Kubernetes deployment manifest
├── Dockerfile               # Container definition
├── Jenkinsfile             # Original Jenkins pipeline
├── Jenkinsfile-Custom      # Customizable Jenkins pipeline
├── pom.xml                 # Maven configuration
├── DEPLOYMENT_GUIDE.md     # Detailed deployment guide
└── README.md               # This file
```

## 🚀 Quick Start

### Prerequisites

- AWS Account with appropriate permissions
- 5 EC2 instances (see server requirements below)
- Domain name (optional)
- DockerHub account
- GitHub repository

### Server Requirements

| Server | Instance Type | Storage | Ports | Purpose |
|--------|---------------|---------|-------|---------|
| Jenkins | t2.large | 25GB | 22, 8080 | CI/CD Pipeline |
| SonarQube | t2.medium | 20GB | 22, 9000 | Code Analysis |
| Nexus | t2.medium | 20GB | 22, 8081 | Artifact Repository |
| Monitoring | t2.large | 25GB | 22, 3000, 9090, 9115 | Monitoring Stack |
| EKS Management | t2.medium | 15GB | 22 | Kubernetes Management |

### Option 1: Automated Setup (Recommended)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/ougabriel/full-stack-blogging-app.git
   cd full-stack-blogging-app
   ```

2. **Run the quick setup script** on each server:
   ```bash
   chmod +x scripts/quick-setup.sh
   ./scripts/quick-setup.sh
   ```

3. **Follow the interactive menu** to set up each component.

### Option 2: Manual Setup

Follow the detailed steps in [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md).

## 🔧 Configuration

### Environment Variables

Copy and customize the environment template:
```bash
cp configs/environment-template.env .env
# Edit .env with your specific values
```

### Jenkins Pipeline Configuration

Update the `Jenkinsfile-Custom` with your environment-specific values:
- DockerHub credentials
- AWS region and cluster details
- Email notifications
- SonarQube server details

### Terraform Variables

Update `EKS_Terraform/variables.tf`:
```hcl
variable "ssh_key_name" {
  description = "The name of the SSH key pair to use for instances"
  type        = string
  default     = "your-keypair-name"
}
```

## 📊 Pipeline Stages

The CI/CD pipeline includes the following stages:

1. **Git Checkout**: Clone source code
2. **Compile**: Compile Java application
3. **Test**: Run unit tests
4. **Trivy FS Scan**: Scan filesystem for vulnerabilities
5. **SonarQube Analysis**: Code quality analysis
6. **Quality Gate**: Enforce quality standards
7. **Build Package**: Create JAR artifact
8. **Publish Artifacts**: Deploy to Nexus repository
9. **Docker Build & Tag**: Create container image
10. **Trivy Image Scan**: Scan container for vulnerabilities
11. **Docker Push**: Push image to DockerHub
12. **Deploy to EKS**: Deploy to Kubernetes cluster
13. **Verify Deployment**: Validate deployment success

## 📈 Monitoring

The monitoring stack includes:

- **Prometheus**: Collects metrics from various sources
- **Grafana**: Visualizes metrics and creates dashboards
- **Blackbox Exporter**: Monitors application endpoints

### Default Dashboards

- **Blackbox Monitoring (ID: 7587)**: Application availability and response times
- **Kubernetes Cluster Monitoring**: Pod and node metrics
- **Jenkins Pipeline Metrics**: Build success rates and duration

### Accessing Monitoring

- Grafana: `http://<monitoring-ip>:3000` (admin/admin)
- Prometheus: `http://<monitoring-ip>:9090`
- Blackbox Exporter: `http://<monitoring-ip>:9115`

## 🔒 Security Features

- **Trivy vulnerability scanning** for both filesystem and container images
- **SonarQube code quality** analysis with quality gates
- **RBAC configuration** for Kubernetes access control
- **Secrets management** for sensitive data
- **Network security groups** with minimal required access

## 🧪 Testing

Run tests locally:
```bash
./mvnw test
```

View test reports:
```bash
open target/surefire-reports/index.html
```

## 📝 Logging

Application logs are available:
- **Jenkins**: `/var/log/jenkins/jenkins.log`
- **Application pods**: `kubectl logs -n webapps <pod-name>`
- **System services**: `journalctl -u <service-name>`

## 🚨 Troubleshooting

### Common Issues

1. **Jenkins build fails**:
   - Check Jenkins logs: `sudo journalctl -u jenkins`
   - Verify tool configurations in Jenkins
   - Ensure Docker is running and Jenkins user is in docker group

2. **SonarQube won't start**:
   - Check system parameters: `sysctl vm.max_map_count`
   - Verify container logs: `docker logs sonarqube`

3. **EKS deployment fails**:
   - Verify AWS credentials: `aws sts get-caller-identity`
   - Check kubectl context: `kubectl config current-context`
   - Validate RBAC permissions

4. **Monitoring not working**:
   - Check service status: `systemctl status prometheus`
   - Verify network connectivity between components
   - Check configuration files syntax

### Logs and Debugging

```bash
# Check service status
sudo systemctl status <service-name>

# View logs
sudo journalctl -u <service-name> -f

# Debug Kubernetes
kubectl describe pod <pod-name> -n webapps
kubectl logs <pod-name> -n webapps

# Check Docker containers
docker ps
docker logs <container-name>
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Spring Boot community for the excellent framework
- Jenkins community for the robust CI/CD platform
- AWS for the cloud infrastructure
- Prometheus and Grafana communities for monitoring tools

## 📞 Support

If you encounter any issues or have questions:

1. Check the [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for detailed instructions
2. Review the troubleshooting section above
3. Open an issue in the GitHub repository
4. Contact the maintainers

---

**Note**: This project is for educational and demonstration purposes. For production use, implement additional security measures and follow your organization's DevOps best practices.