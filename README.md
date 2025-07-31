# Spring Boot Application with CI/CD

A containerized Spring Boot application with automated deployment to AWS EC2 using GitHub Actions and Terraform.

## 🚀 Features

- Spring Boot REST API with Actuator metrics
- Docker containerization
- Terraform infrastructure as code
- GitHub Actions CI/CD pipeline
- AWS EC2 deployment
- Kubernetes deployment with Helm charts
- Prometheus + Grafana monitoring
- ArgoCD GitOps continuous deployment

## 📋 Prerequisites

- Java 17
- Docker
- AWS Account
- GitHub Account
- Terraform
- Kubernetes (Docker Desktop)
- Helm (optional)

## 🏗️ Architecture

- **Application**: Spring Boot running on port 8484
- **Infrastructure**: AWS EC2 t2.micro with Amazon Linux 2
- **CI/CD**: GitHub Actions for build and deployment
- **Container Registry**: Docker Hub
- **Kubernetes**: Local cluster with Helm charts
- **Monitoring**: Prometheus + Grafana stack
- **GitOps**: ArgoCD for continuous deployment

## 🛠️ Local Development

```bash
# Build and run locally
java -jar target/springboot-demo-0.0.1-SNAPSHOT.jar --server.port=8484

# Build Docker image
docker build -t springboot-app .

# Run container
docker run -p 8484:8484 springboot-app
```

## 🌐 API Endpoints

- `GET /hello` - Returns greeting message (all environments)
- `GET /dev` - Returns dev info (dev only)
- `GET /status` - Returns server status (dev & staging)
- `GET /health` - Returns server health status (production)
- `GET /actuator/prometheus` - Prometheus metrics endpoint
- `GET /actuator/health` - Health check endpoint
- Application runs on port 8484

## 🚀 Deployment Flow

**Dev → Staging → Production**

1. **Dev Environment**: Push to `dev` branch
   - Auto-deploys to dev server
   - Runs health checks
   - Creates PR to staging

2. **Staging Environment**: Merge PR to `staging` branch
   - Auto-deploys to staging server
   - Runs comprehensive tests
   - Creates PR to production

3. **Production Environment**: Merge PR to `main` branch
   - Auto-deploys to production server
   - Final health checks
   - Production ready

## 🔧 Deployment

1. **Set GitHub Secrets**:
   - `DOCKER_USERNAME` - Docker Hub username
   - `DOCKER_PASSWORD` - Docker Hub password
   - `EC2_HOST` - EC2 public IP
   - `EC2_PRIVATE_KEY` - SSH private key
   - `AWS_ACCESS_KEY_ID` - AWS access key
   - `AWS_SECRET_ACCESS_KEY` - AWS secret key

2. **Deploy Infrastructure**:
   ```bash
   cd terraform/dev
   terraform init
   terraform apply
   ```

3. **Push to GitHub** - Triggers automatic deployment

## 📁 Project Structure

```
├── src/main/java/com/example/demo/
│   ├── DemoApplication.java
│   └── controller/HelloController.java
├── k8s/                          # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   └── namespace.yaml
├── helm/springboot-app/          # Helm chart
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
├── monitoring/                   # Prometheus & Grafana
│   ├── simple-prometheus.yaml
│   ├── simple-grafana.yaml
│   └── grafana/dashboard.json
├── argocd/                       # GitOps configuration
│   ├── application.yaml
│   └── monitoring-app.yaml
├── scripts/                      # Helper scripts
│   ├── setup-monitoring.sh
│   └── access-monitoring.sh
├── terraform/dev/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── .github/workflows/
│   ├── deploy.yml
│   └── full-lifecycle.yml
├── Dockerfile
└── pom.xml
```

## 📊 Monitoring

### **Prometheus + Grafana Stack**

```bash
# Deploy monitoring stack
kubectl apply -f monitoring/simple-prometheus.yaml
kubectl apply -f monitoring/simple-grafana.yaml

# Access Grafana
kubectl port-forward svc/grafana-service 3000:3000 -n monitoring
# Visit: http://localhost:3000 (admin/admin123)

# Access Prometheus
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring
# Visit: http://localhost:9090
```

### **Available Metrics**
- HTTP request rates and response times
- JVM memory usage and garbage collection
- CPU and system metrics
- Custom application metrics

### **Grafana Dashboards**
- Pre-built Spring Boot dashboard
- System and infrastructure metrics
- Real-time monitoring and alerting

## 🔄 GitOps with ArgoCD

```bash
# Install ArgoCD
bash argocd/install.sh

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Visit: https://localhost:8080
```

**Continuous Deployment Pipeline:**
1. GitHub Actions builds and pushes Docker images
2. ArgoCD monitors Git repository for changes
3. Automatically deploys Helm charts to Kubernetes
4. Prometheus scrapes metrics from deployed applications
5. Grafana visualizes metrics and sends alerts

## 🔒 Security

- SSH keys are not committed to repository
- Terraform state contains sensitive information
- Use GitHub Secrets for credentials
- Kubernetes RBAC for service access
- Prometheus metrics secured within cluster