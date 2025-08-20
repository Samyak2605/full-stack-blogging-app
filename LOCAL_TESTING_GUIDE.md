# Local Testing Guide for DevOps Blog App

## 🏠 What Can Be Tested Locally

### ✅ Components You CAN Test Locally

#### 1. **Spring Boot Blog Application**
```bash
# Start the application
./mvnw clean spring-boot:run

# Or using Maven directly
mvn clean spring-boot:run
```
**Access URL**: `http://localhost:8080`
**Features to test**:
- User registration: `http://localhost:8080/register`
- User login: `http://localhost:8080/login`
- Blog home: `http://localhost:8080/`
- Create posts: `http://localhost:8080/add`

#### 2. **Docker Containers (Development Setup)**

**SonarQube Container**:
```bash
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community
```
**Access URL**: `http://localhost:9000`
**Default credentials**: admin/admin

**Nexus Container**:
```bash
docker run -d --name nexus -p 8081:8081 sonatype/nexus3
```
**Access URL**: `http://localhost:8081`
**Default username**: admin
**Get password**: `docker exec -it nexus cat /nexus-data/admin.password`

**Jenkins Container**:
```bash
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
```
**Access URL**: `http://localhost:8080`
**Get password**: `docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword`

#### 3. **Monitoring Stack (Local Development)**

**Prometheus**:
```bash
# Download and run locally
wget https://github.com/prometheus/prometheus/releases/download/v2.40.0/prometheus-2.40.0.darwin-amd64.tar.gz
tar xvf prometheus-2.40.0.darwin-amd64.tar.gz
cd prometheus-2.40.0.darwin-amd64
./prometheus --config.file=../configs/prometheus.yml
```
**Access URL**: `http://localhost:9090`

**Grafana**:
```bash
# Using Docker
docker run -d --name grafana -p 3000:3000 grafana/grafana-oss
```
**Access URL**: `http://localhost:3000`
**Default credentials**: admin/admin

**Blackbox Exporter**:
```bash
# Download and run locally
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.24.0/blackbox_exporter-0.24.0.darwin-amd64.tar.gz
tar xvf blackbox_exporter-0.24.0.darwin-amd64.tar.gz
cd blackbox_exporter-0.24.0.darwin-amd64
./blackbox_exporter --config.file=../configs/blackbox.yml
```
**Access URL**: `http://localhost:9115`

### ❌ Components That REQUIRE AWS Infrastructure

#### 1. **AWS EKS Cluster**
- **Requirement**: AWS account and EC2 instances
- **Documentation Reference**: See `DEPLOYMENT_GUIDE.md` Step 6
- **Terraform Files**: `EKS_Terraform/main.tf`

#### 2. **Production CI/CD Pipeline**
- **Requirement**: Jenkins on EC2 instance
- **Documentation Reference**: See `DEPLOYMENT_GUIDE.md` Step 3.1
- **Files**: `Jenkinsfile`, `Jenkinsfile-Custom`

#### 3. **Load Balancer and Production Monitoring**
- **Requirement**: AWS Load Balancer and EKS cluster
- **Documentation Reference**: See `DEPLOYMENT_GUIDE.md` Step 8

## 🧪 Local Testing Commands

### Test 1: Run Spring Boot Application
```bash
# Terminal 1: Start the application
./mvnw clean spring-boot:run

# Terminal 2: Test endpoints
curl http://localhost:8080
curl http://localhost:8080/login
curl http://localhost:8080/register
```

### Test 2: Build and Test with Maven
```bash
# Compile the application
mvn compile

# Run tests
mvn test

# Package the application
mvn package

# The JAR file will be created in target/ directory
ls -la target/*.jar
```

### Test 3: Docker Build and Run
```bash
# Build the Docker image
mvn package
docker build -t blog-app:local .

# Run the containerized application
docker run -d -p 8080:8080 --name blog-app-container blog-app:local

# Test the containerized app
curl http://localhost:8080
```

### Test 4: Local Development Stack
```bash
# Start all services with Docker Compose (create docker-compose.yml)
docker-compose up -d

# Services will be available at:
# - Blog App: http://localhost:8080
# - Jenkins: http://localhost:8080 (different port needed)
# - SonarQube: http://localhost:9000
# - Nexus: http://localhost:8081
# - Grafana: http://localhost:3000
# - Prometheus: http://localhost:9090
```

## 📖 Documentation Links

### Primary Documentation Files:
1. **Main README**: `README.md`
2. **Deployment Guide**: `DEPLOYMENT_GUIDE.md`
3. **Project Status**: `PROJECT_STATUS.md`

### Key Configuration Files:
1. **Application Config**: `src/main/resources/application.properties`
2. **Maven Config**: `pom.xml`
3. **Docker Config**: `Dockerfile`
4. **Kubernetes Config**: `deployment-service.yml`
5. **Terraform Config**: `EKS_Terraform/main.tf`

### Installation Scripts:
1. **Jenkins**: `scripts/install_jenkins.sh`
2. **SonarQube**: `scripts/setup_sonarqube.sh`
3. **Nexus**: `scripts/setup_nexus.sh`
4. **Monitoring**: `scripts/setup_monitoring.sh`
5. **Quick Setup**: `scripts/quick-setup.sh`

## 🔗 URLs Referenced in Documentation

### Local Testing URLs:
- **Blog Application**: `http://localhost:8080`
- **Jenkins**: `http://localhost:8080` (if running locally)
- **SonarQube**: `http://localhost:9000`
- **Nexus**: `http://localhost:8081`
- **Grafana**: `http://localhost:3000`
- **Prometheus**: `http://localhost:9090`
- **Blackbox Exporter**: `http://localhost:9115`

### Production URLs (AWS Required):
- **Jenkins**: `http://<jenkins-ec2-ip>:8080`
- **SonarQube**: `http://<sonarqube-ec2-ip>:9000`
- **Nexus**: `http://<nexus-ec2-ip>:8081`
- **Grafana**: `http://<monitoring-ec2-ip>:3000`
- **Prometheus**: `http://<monitoring-ec2-ip>:9090`
- **Blog App on EKS**: `http://<loadbalancer-url>`

## ⚠️ Important Notes

1. **Port Conflicts**: If testing multiple services locally, ensure different ports
2. **Memory Requirements**: Local testing may require sufficient RAM
3. **Database**: The app uses H2 in-memory database (no separate DB needed)
4. **AWS Services**: EKS, EC2, and Load Balancer require AWS account
5. **Production Setup**: Follow `DEPLOYMENT_GUIDE.md` for AWS deployment

## 🚀 Quick Local Start

```bash
# 1. Start the blog application
./mvnw clean spring-boot:run

# 2. In another terminal, test the application
curl http://localhost:8080

# 3. Open in browser
open http://localhost:8080
```

## 📞 Troubleshooting

- **Port 8080 in use**: Kill existing process or use different port
- **Java version**: Ensure Java 17+ is installed
- **Maven issues**: Check `mvnw` permissions: `chmod +x mvnw`
- **Docker issues**: Ensure Docker is running

For full production deployment, follow the AWS deployment guide in `DEPLOYMENT_GUIDE.md`.
