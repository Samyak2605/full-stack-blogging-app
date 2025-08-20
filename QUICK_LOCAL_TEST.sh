#!/bin/bash

# Quick Local Testing Script for DevOps Blog App
# This script helps you test components locally

echo "🧪 DevOps Blog App - Local Testing"
echo "=================================="
echo

# Function to check if port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null ; then
        echo "❌ Port $1 is already in use"
        return 1
    else
        echo "✅ Port $1 is available"
        return 0
    fi
}

# Function to wait for service
wait_for_service() {
    local url=$1
    local name=$2
    echo "⏳ Waiting for $name to start..."
    for i in {1..30}; do
        if curl -s $url > /dev/null 2>&1; then
            echo "✅ $name is ready at $url"
            return 0
        fi
        sleep 2
    done
    echo "❌ $name failed to start"
    return 1
}

echo "1. 🚀 Testing Spring Boot Application"
echo "====================================="
if check_port 8080; then
    echo "Starting Spring Boot app..."
    echo "🔗 Will be available at: http://localhost:8080"
    echo "📋 Test pages:"
    echo "   - Home: http://localhost:8080/"
    echo "   - Login: http://localhost:8080/login"
    echo "   - Register: http://localhost:8080/register"
    echo
    echo "Run this command to start:"
    echo "mvn clean spring-boot:run"
    echo
fi

echo "2. 🐳 Testing Docker Services"
echo "=============================="

echo "📊 SonarQube (Code Analysis)"
if check_port 9000; then
    echo "🔗 URL: http://localhost:9000"
    echo "👤 Credentials: admin/admin"
    echo "🚀 Start command:"
    echo "docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community"
    echo
fi

echo "📦 Nexus (Artifact Repository)"
if check_port 8081; then
    echo "🔗 URL: http://localhost:8081"
    echo "👤 Username: admin"
    echo "🔑 Password: docker exec -it nexus cat /nexus-data/admin.password"
    echo "🚀 Start command:"
    echo "docker run -d --name nexus -p 8081:8081 sonatype/nexus3"
    echo
fi

echo "🔧 Jenkins (CI/CD)"
if check_port 8090; then
    echo "🔗 URL: http://localhost:8090"
    echo "🔑 Password: docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
    echo "🚀 Start command:"
    echo "docker run -d --name jenkins -p 8090:8080 jenkins/jenkins:lts"
    echo
fi

echo "3. 📈 Testing Monitoring Stack"
echo "==============================="

echo "📊 Grafana (Dashboards)"
if check_port 3000; then
    echo "🔗 URL: http://localhost:3000"
    echo "👤 Credentials: admin/admin"
    echo "🚀 Start command:"
    echo "docker run -d --name grafana -p 3000:3000 grafana/grafana-oss"
    echo
fi

echo "🎯 Prometheus (Metrics)"
if check_port 9090; then
    echo "🔗 URL: http://localhost:9090"
    echo "🚀 Start command:"
    echo "docker run -d --name prometheus -p 9090:9090 prom/prometheus"
    echo
fi

echo "🔍 Testing Application Build"
echo "============================"
echo "🧪 Test compilation:"
echo "mvn compile"
echo
echo "🧪 Run tests:"
echo "mvn test"
echo
echo "🧪 Build JAR:"
echo "mvn package"
echo
echo "🧪 Build Docker image:"
echo "mvn package && docker build -t blog-app:local ."
echo

echo "⚠️  Production Components (Require AWS):"
echo "========================================="
echo "❌ EKS Cluster - Requires AWS EC2 instances"
echo "❌ Production CI/CD Pipeline - Requires 5 EC2 instances"
echo "❌ Load Balancer - AWS managed service"
echo "❌ Production Monitoring - Requires AWS infrastructure"
echo
echo "📖 For full deployment, see: DEPLOYMENT_GUIDE.md"
echo "🏗️ AWS Infrastructure code: EKS_Terraform/main.tf"
echo

echo "🎯 Quick Start Commands:"
echo "======================="
echo "# Start the blog app"
echo "mvn clean spring-boot:run"
echo
echo "# Test the app"
echo "curl http://localhost:8080"
echo
echo "# Open in browser"
echo "open http://localhost:8080"
