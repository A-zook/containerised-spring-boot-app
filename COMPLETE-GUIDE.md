# Complete DevOps Pipeline Guide: Spring Boot to Production

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Phase 1: Spring Boot Application](#phase-1-spring-boot-application)
3. [Phase 2: Docker Containerization](#phase-2-docker-containerization)
4. [Phase 3: AWS Infrastructure with Terraform](#phase-3-aws-infrastructure-with-terraform)
5. [Phase 4: CI/CD Pipeline with GitHub Actions](#phase-4-cicd-pipeline-with-github-actions)
6. [Phase 5: Kubernetes Deployment](#phase-5-kubernetes-deployment)
7. [Phase 6: Helm Charts](#phase-6-helm-charts)
8. [Phase 7: ArgoCD GitOps](#phase-7-argocd-gitops)
9. [Phase 8: Monitoring with Prometheus & Grafana](#phase-8-monitoring-with-prometheus--grafana)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Tools
- **Java 17** - Spring Boot development
- **Maven** - Build tool
- **Docker Desktop** - Containerization (with Kubernetes enabled)
- **Git** - Version control
- **AWS CLI** - Cloud infrastructure
- **Terraform** - Infrastructure as Code
- **kubectl** - Kubernetes CLI
- **Helm** (optional) - Kubernetes package manager

### Required Accounts
- **GitHub Account** - Code repository and CI/CD
- **Docker Hub Account** - Container registry
- **AWS Account** - Cloud infrastructure

---

## Phase 1: Spring Boot Application

### Step 1.1: Create Spring Boot Project
```bash
# Create project directory
mkdir my-springboot-app
cd my-springboot-app

# Initialize Maven project
mvn archetype:generate -DgroupId=com.example -DartifactId=springboot-demo -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
```

### Step 1.2: Configure pom.xml
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.2.0</version>
    <relativePath/>
  </parent>
  
  <groupId>com.example</groupId>
  <artifactId>springboot-demo</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <packaging>jar</packaging>
  
  <properties>
    <java.version>17</java.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
      <groupId>io.micrometer</groupId>
      <artifactId>micrometer-registry-prometheus</artifactId>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
```

### Step 1.3: Create Application Files
**src/main/java/com/example/demo/DemoApplication.java**
```java
package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
```

**src/main/java/com/example/demo/controller/HelloController.java**
```java
package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    
    @GetMapping("/hello")
    public String hello() {
        return "Hello from Spring Boot - DEV Environment!";
    }
    
    @GetMapping("/dev")
    public String dev() {
        return "Development environment info: Version 1.0, Server: localhost:8484";
    }
    
    @GetMapping("/status")
    public String status() {
        return "Server Status: Running, Environment: Development, Port: 8484";
    }
}
```

**src/main/resources/application.properties**
```properties
server.port=8484

# Actuator endpoints
management.endpoints.web.exposure.include=health,info,metrics,prometheus
management.endpoint.health.show-details=always
management.endpoint.prometheus.enabled=true
management.metrics.export.prometheus.enabled=true
```

### Step 1.4: Test Locally
```bash
# Build and run
mvn clean install
java -jar target/springboot-demo-0.0.1-SNAPSHOT.jar

# Test endpoints
curl http://localhost:8484/hello
curl http://localhost:8484/actuator/health
curl http://localhost:8484/actuator/prometheus
```

---

## Phase 2: Docker Containerization

### Step 2.1: Create Dockerfile
```dockerfile
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/springboot-demo-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8484

ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Step 2.2: Create .dockerignore
```
target/
.git/
.gitignore
README.md
Dockerfile
.dockerignore
```

### Step 2.3: Build and Test Docker Image
```bash
# Build JAR first
mvn clean install

# Build Docker image
docker build -t springboot-app .

# Run container
docker run -p 8484:8484 springboot-app

# Test
curl http://localhost:8484/hello
```

### Step 2.4: Push to Docker Hub
```bash
# Login to Docker Hub
docker login

# Tag image
docker tag springboot-app your-username/springboot-app

# Push image
docker push your-username/springboot-app
```

---

## Phase 3: AWS Infrastructure with Terraform

### Step 3.1: Generate SSH Keys
```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws-springboot-key

# Copy public key to project
cp ~/.ssh/aws-springboot-key.pub terraform/dev/
```

### Step 3.2: Create Terraform Configuration

**terraform/dev/variables.tf**
```hcl
variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
  default     = "springboot-key"
}

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
  default     = "./aws-springboot-key.pub"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
```

**terraform/dev/main.tf**
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "springboot-app-sg"
  description = "Allow SSH and application traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8484
    to_port     = 8484
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name
  
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user
              EOF

  tags = {
    Name        = "SpringBootAppServer"
    Environment = "dev"
  }
}

output "instance_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "instance_public_dns" {
  value = aws_instance.app_server.public_dns
}

output "application_url" {
  value = "http://${aws_instance.app_server.public_ip}:8484"
}
```

**terraform/dev/terraform.tfvars**
```hcl
key_name        = "springboot-key"
public_key_path = "./aws-springboot-key.pub"
instance_type   = "t2.micro"
```

### Step 3.3: Deploy Infrastructure
```bash
cd terraform/dev

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply configuration
terraform apply

# Get outputs
terraform output instance_public_ip
terraform output application_url
```

---

## Phase 4: CI/CD Pipeline with GitHub Actions

### Step 4.1: Create GitHub Repository
```bash
# Initialize git repository
git init
git add .
git commit -m "Initial Spring Boot application"

# Create GitHub repository and push
git remote add origin https://github.com/your-username/your-repo.git
git branch -M main
git push -u origin main

# Create dev branch
git checkout -b dev
git push -u origin dev
```

### Step 4.2: Configure GitHub Secrets
Go to GitHub Repository → Settings → Secrets and variables → Actions

Add these secrets:
- `DOCKER_USERNAME` - Your Docker Hub username
- `DOCKER_PASSWORD` - Your Docker Hub password
- `EC2_HOST` - EC2 public IP from Terraform output
- `EC2_PRIVATE_KEY` - Content of ~/.ssh/aws-springboot-key (private key)
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key

### Step 4.3: Create GitHub Actions Workflow

**.github/workflows/deploy.yml**
```yaml
name: Build and Deploy Spring Boot App

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout Code
      uses: actions/checkout@v3

    - name: Set up JDK
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'

    - name: Build JAR with Maven
      run: mvn clean install

    - name: Build Docker Image
      run: docker build -t ${{ secrets.DOCKER_USERNAME }}/springboot-app .

    - name: Login to DockerHub
      run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin

    - name: Push Image
      run: docker push ${{ secrets.DOCKER_USERNAME }}/springboot-app

  deploy:
    if: github.ref == 'refs/heads/main'
    needs: build
    runs-on: ubuntu-latest
    steps:
    - name: SSH into EC2 and Deploy
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ec2-user
        key: ${{ secrets.EC2_PRIVATE_KEY }}
        script: |
          docker pull ${{ secrets.DOCKER_USERNAME }}/springboot-app
          docker stop springboot-app || true
          docker rm springboot-app || true
          docker run -d -p 8484:8484 --name springboot-app ${{ secrets.DOCKER_USERNAME }}/springboot-app
```

### Step 4.4: Test CI/CD Pipeline
```bash
# Make a change and push to main
git checkout main
echo "# Updated" >> README.md
git add .
git commit -m "Test CI/CD pipeline"
git push

# Check GitHub Actions tab for pipeline execution
# Test deployed application at http://EC2_IP:8484/hello
```

---

## Phase 5: Kubernetes Deployment

### Step 5.1: Enable Kubernetes in Docker Desktop
1. Open Docker Desktop
2. Go to Settings → Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"

### Step 5.2: Create Kubernetes Manifests

**k8s/namespace.yaml**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: springboot-app
  labels:
    name: springboot-app
```

**k8s/deployment.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: springboot-app
  labels:
    app: springboot-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: springboot-app
  template:
    metadata:
      labels:
        app: springboot-app
    spec:
      containers:
      - name: springboot-app
        image: your-username/springboot-app:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8484
        env:
        - name: SERVER_PORT
          value: "8484"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8484
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8484
          initialDelaySeconds: 5
          periodSeconds: 5
```

**k8s/service.yaml**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: springboot-app-service
  labels:
    app: springboot-app
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8484
    protocol: TCP
  selector:
    app: springboot-app
```

### Step 5.3: Deploy to Kubernetes
```bash
# Apply namespace
kubectl apply -f k8s/namespace.yaml

# Deploy application
kubectl apply -f k8s/ -n springboot-app

# Check deployment
kubectl get pods -n springboot-app
kubectl get services -n springboot-app

# Port forward to test
kubectl port-forward svc/springboot-app-service 8080:80 -n springboot-app

# Test
curl http://localhost:8080/hello
```

---

## Phase 6: Helm Charts

### Step 6.1: Create Helm Chart Structure
```bash
mkdir -p helm/springboot-app/templates
```

### Step 6.2: Create Helm Chart Files

**helm/springboot-app/Chart.yaml**
```yaml
apiVersion: v2
name: springboot-app
description: A Helm chart for Spring Boot Application
type: application
version: 0.1.0
appVersion: "1.0.0"
```

**helm/springboot-app/values.yaml**
```yaml
replicaCount: 2

image:
  repository: your-username/springboot-app
  pullPolicy: Always
  tag: "latest"

nameOverride: ""
fullnameOverride: ""

service:
  type: LoadBalancer
  port: 80
  targetPort: 8484

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80

nodeSelector: {}
tolerations: []
affinity: {}
```

**helm/springboot-app/templates/_helpers.tpl**
```yaml
{{/*
Expand the name of the chart.
*/}}
{{- define "springboot-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "springboot-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "springboot-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "springboot-app.labels" -}}
helm.sh/chart: {{ include "springboot-app.chart" . }}
{{ include "springboot-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "springboot-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "springboot-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
```

**helm/springboot-app/templates/deployment.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "springboot-app.fullname" . }}
  labels:
    {{- include "springboot-app.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "springboot-app.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "springboot-app.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.targetPort }}
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /actuator/health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /actuator/health
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
```

**helm/springboot-app/templates/service.yaml**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "springboot-app.fullname" . }}
  labels:
    {{- include "springboot-app.labels" . | nindent 4 }}
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/path: "/actuator/prometheus"
    prometheus.io/port: "{{ .Values.service.targetPort }}"
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      protocol: TCP
      name: http
  selector:
    {{- include "springboot-app.selectorLabels" . | nindent 4 }}
```

### Step 6.3: Deploy with Helm
```bash
# Install Helm (if not already installed)
# Windows: Download from https://github.com/helm/helm/releases

# Validate chart
helm lint helm/springboot-app

# Dry run
helm install springboot-app helm/springboot-app --dry-run --debug

# Install
helm install springboot-app helm/springboot-app --create-namespace --namespace springboot-app

# Check status
helm status springboot-app -n springboot-app
kubectl get pods -n springboot-app

# Upgrade
helm upgrade springboot-app helm/springboot-app -n springboot-app

# Uninstall
helm uninstall springboot-app -n springboot-app
```

---

## Phase 7: ArgoCD GitOps

### Step 7.1: Create ArgoCD Configuration

**argocd/namespace.yaml**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
  labels:
    name: argocd
```

**argocd/application.yaml**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: springboot-app
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/your-username/your-repo.git
    targetRevision: HEAD
    path: helm/springboot-app
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: springboot-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

**argocd/install.sh**
```bash
#!/bin/bash

echo "🚀 Installing ArgoCD..."

# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get ArgoCD admin password
echo "🔑 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Port forward ArgoCD server
echo "🌐 Starting port forward to ArgoCD server..."
echo "ArgoCD will be available at: http://localhost:8080"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
echo ""
echo "Run this command to access ArgoCD:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"

# Apply the application
echo "📦 Applying ArgoCD application..."
kubectl apply -f argocd/application.yaml

echo "📊 Monitoring applications deployed via ArgoCD!"
echo "Check ArgoCD UI for Prometheus and Grafana deployment status"
```

### Step 7.2: Install and Configure ArgoCD
```bash
# Make script executable
chmod +x argocd/install.sh

# Run installation
bash argocd/install.sh

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Visit https://localhost:8080
# Login with admin and the password from the script output

# Apply application
kubectl apply -f argocd/application.yaml

# Check application status
kubectl get applications -n argocd
```

---

## Phase 8: Monitoring with Prometheus & Grafana

### Step 8.1: Create Simple Monitoring Stack

**monitoring/simple-prometheus.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:latest
        ports:
        - containerPort: 9090
        args:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus/'
          - '--web.console.libraries=/etc/prometheus/console_libraries'
          - '--web.console.templates=/etc/prometheus/consoles'
          - '--web.enable-lifecycle'
        volumeMounts:
        - name: prometheus-config
          mountPath: /etc/prometheus/
        - name: prometheus-storage
          mountPath: /prometheus/
      volumes:
      - name: prometheus-config
        configMap:
          name: prometheus-config
      - name: prometheus-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus-service
  namespace: monitoring
spec:
  selector:
    app: prometheus
  ports:
  - port: 9090
    targetPort: 9090
  type: ClusterIP
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
    - job_name: 'ec2-springboot-app'
      static_configs:
      - targets: ['YOUR_EC2_IP:8484']
      metrics_path: '/actuator/prometheus'
      scrape_interval: 15s
    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
```

**monitoring/simple-grafana.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: admin123
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
      volumes:
      - name: grafana-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: grafana-service
  namespace: monitoring
spec:
  selector:
    app: grafana
  ports:
  - port: 3000
    targetPort: 3000
  type: ClusterIP
```

### Step 8.2: Deploy Monitoring Stack
```bash
# Create monitoring namespace
kubectl create namespace monitoring

# Update Prometheus config with your EC2 IP
# Edit monitoring/simple-prometheus.yaml and replace YOUR_EC2_IP

# Deploy Prometheus
kubectl apply -f monitoring/simple-prometheus.yaml

# Deploy Grafana
kubectl apply -f monitoring/simple-grafana.yaml

# Check deployment
kubectl get pods -n monitoring

# Access Grafana
kubectl port-forward svc/grafana-service 3000:3000 -n monitoring
# Visit: http://localhost:3000 (admin/admin123)

# Access Prometheus
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring
# Visit: http://localhost:9090
```

### Step 8.3: Configure Grafana
1. **Access Grafana**: http://localhost:3000
2. **Login**: admin/admin123
3. **Add Data Source**:
   - Go to Configuration → Data Sources
   - Add Prometheus
   - URL: `http://prometheus-service.monitoring.svc.cluster.local:9090`
   - Save & Test
4. **Create Dashboard**:
   - Go to Create → Dashboard
   - Add Panel
   - Query: `http_server_requests_seconds_count`
   - Apply

### Step 8.4: Test Monitoring
```bash
# Generate some traffic to your application
curl http://YOUR_EC2_IP:8484/hello
curl http://YOUR_EC2_IP:8484/actuator/prometheus

# Check Prometheus targets
# Visit: http://localhost:9090/targets

# View metrics in Grafana
# Create queries for:
# - http_server_requests_seconds_count
# - jvm_memory_used_bytes
# - process_cpu_usage
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Docker Build Issues
```bash
# Issue: Maven build fails
# Solution: Ensure Java 17 is installed
java -version

# Issue: Docker image won't start
# Solution: Check Dockerfile and ensure JAR file exists
ls -la target/
```

#### 2. Terraform Issues
```bash
# Issue: SSH key not found
# Solution: Verify key path and permissions
ls -la ~/.ssh/aws-springboot-key*
chmod 600 ~/.ssh/aws-springboot-key

# Issue: AWS credentials not configured
# Solution: Configure AWS CLI
aws configure
```

#### 3. Kubernetes Issues
```bash
# Issue: Pods not starting
# Solution: Check pod logs and events
kubectl describe pod POD_NAME -n springboot-app
kubectl logs POD_NAME -n springboot-app

# Issue: Image pull errors
# Solution: Verify image exists and is public
docker pull your-username/springboot-app:latest

# Issue: Service not accessible
# Solution: Check service and port-forward
kubectl get svc -n springboot-app
kubectl port-forward svc/springboot-app-service 8080:80 -n springboot-app
```

#### 4. ArgoCD Issues
```bash
# Issue: ArgoCD not accessible
# Solution: Check port-forward and service status
kubectl get pods -n argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Issue: Application not syncing
# Solution: Check repository URL and credentials
kubectl describe application springboot-app -n argocd
```

#### 5. Monitoring Issues
```bash
# Issue: Prometheus not scraping targets
# Solution: Check configuration and network connectivity
kubectl logs deployment/prometheus -n monitoring
curl http://YOUR_EC2_IP:8484/actuator/prometheus

# Issue: Grafana shows no data
# Solution: Verify data source configuration
# Check Prometheus URL in Grafana data source settings
```

### Useful Commands

#### General Kubernetes
```bash
# Check cluster status
kubectl cluster-info

# Get all resources in namespace
kubectl get all -n NAMESPACE

# Describe resource for troubleshooting
kubectl describe TYPE NAME -n NAMESPACE

# View logs
kubectl logs -f deployment/NAME -n NAMESPACE

# Execute into pod
kubectl exec -it POD_NAME -n NAMESPACE -- /bin/bash
```

#### Helm Commands
```bash
# List releases
helm list -n NAMESPACE

# Get release history
helm history RELEASE_NAME -n NAMESPACE

# Rollback release
helm rollback RELEASE_NAME REVISION -n NAMESPACE

# Uninstall release
helm uninstall RELEASE_NAME -n NAMESPACE
```

#### Docker Commands
```bash
# List images
docker images

# Remove image
docker rmi IMAGE_NAME

# List running containers
docker ps

# Stop and remove container
docker stop CONTAINER_NAME
docker rm CONTAINER_NAME
```

---

## Summary

This guide covers the complete journey from a simple Spring Boot application to a full production-ready DevOps pipeline with:

1. **Local Development** - Spring Boot with Actuator metrics
2. **Containerization** - Docker packaging and registry
3. **Infrastructure** - AWS EC2 with Terraform IaC
4. **CI/CD** - GitHub Actions automated pipeline
5. **Kubernetes** - Container orchestration
6. **Helm** - Kubernetes package management
7. **GitOps** - ArgoCD continuous deployment
8. **Monitoring** - Prometheus metrics and Grafana visualization

Each phase builds upon the previous one, creating a comprehensive DevOps ecosystem that demonstrates modern cloud-native application deployment and management practices.