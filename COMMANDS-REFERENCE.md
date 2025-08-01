# DevOps Pipeline Commands Reference

## 📋 Quick Command Reference for Complete Pipeline

---

## Phase 1: Spring Boot Application

### Create Project
```bash
mkdir my-springboot-app
cd my-springboot-app
mvn archetype:generate -DgroupId=com.example -DartifactId=springboot-demo -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
```

### Build and Test
```bash
mvn clean install
java -jar target/springboot-demo-0.0.1-SNAPSHOT.jar
curl http://localhost:8484/hello
curl http://localhost:8484/actuator/health
curl http://localhost:8484/actuator/prometheus
```

---

## Phase 2: Docker Containerization

### Build Docker Image
```bash
mvn clean install
docker build -t springboot-app .
docker run -p 8484:8484 springboot-app
curl http://localhost:8484/hello
```

### Push to Docker Hub
```bash
docker login
docker tag springboot-app your-username/springboot-app
docker push your-username/springboot-app
```

---

## Phase 3: AWS Infrastructure with Terraform

### Generate SSH Keys
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws-springboot-key
cp ~/.ssh/aws-springboot-key.pub terraform/dev/
```

### Deploy Infrastructure
```bash
cd terraform/dev
terraform init
terraform plan
terraform apply
terraform output instance_public_ip
terraform output application_url
```

### Destroy Infrastructure
```bash
terraform destroy -auto-approve
```

---

## Phase 4: CI/CD Pipeline with GitHub Actions

### Git Setup
```bash
git init
git add .
git commit -m "Initial Spring Boot application"
git remote add origin https://github.com/your-username/your-repo.git
git branch -M main
git push -u origin main
git checkout -b dev
git push -u origin dev
```

### GitHub Secrets (Manual Setup)
- Go to GitHub Repository → Settings → Secrets and variables → Actions
- Add: `DOCKER_USERNAME`, `DOCKER_PASSWORD`, `EC2_HOST`, `EC2_PRIVATE_KEY`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

### Test Pipeline
```bash
git checkout main
echo "# Updated" >> README.md
git add .
git commit -m "Test CI/CD pipeline"
git push
```

---

## Phase 5: Kubernetes Deployment

### Enable Kubernetes
```bash
# Enable Kubernetes in Docker Desktop Settings
kubectl cluster-info
```

### Deploy to Kubernetes
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/ -n springboot-app
kubectl get pods -n springboot-app
kubectl get services -n springboot-app
kubectl port-forward svc/springboot-app-service 8080:80 -n springboot-app
curl http://localhost:8080/hello
```

### Cleanup Kubernetes
```bash
kubectl delete -f k8s/ -n springboot-app
kubectl delete namespace springboot-app
```

---

## Phase 6: Helm Charts

### Validate and Install
```bash
helm lint helm/springboot-app
helm install springboot-app helm/springboot-app --dry-run --debug
helm install springboot-app helm/springboot-app --create-namespace --namespace springboot-app
helm status springboot-app -n springboot-app
kubectl get pods -n springboot-app
```

### Manage Helm Releases
```bash
helm list -n springboot-app
helm upgrade springboot-app helm/springboot-app -n springboot-app
helm rollback springboot-app 1 -n springboot-app
helm uninstall springboot-app -n springboot-app
```

---

## Phase 7: ArgoCD GitOps

### Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

### Get ArgoCD Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Access ArgoCD
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Visit: https://localhost:8080 (admin/password-from-above)
```

### Deploy Application
```bash
kubectl apply -f argocd/application.yaml
kubectl get applications -n argocd
kubectl describe application springboot-app -n argocd
```

### ArgoCD CLI (Optional)
```bash
# Download ArgoCD CLI
curl -sSL -o argocd-windows-amd64.exe https://github.com/argoproj/argo-cd/releases/latest/download/argocd-windows-amd64.exe

# Login
argocd login localhost:8080

# Sync application
argocd app sync springboot-app
argocd app get springboot-app
```

---

## Phase 8: Monitoring with Prometheus & Grafana

### Deploy Monitoring Stack
```bash
kubectl create namespace monitoring
# Update monitoring/simple-prometheus.yaml with your EC2 IP
kubectl apply -f monitoring/simple-prometheus.yaml
kubectl apply -f monitoring/simple-grafana.yaml
kubectl get pods -n monitoring
```

### Access Monitoring Services
```bash
# Access Grafana
kubectl port-forward svc/grafana-service 3000:3000 -n monitoring
# Visit: http://localhost:3000 (admin/admin123)

# Access Prometheus
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring
# Visit: http://localhost:9090
```

### Test Monitoring
```bash
# Generate traffic
curl http://YOUR_EC2_IP:8484/hello
curl http://YOUR_EC2_IP:8484/actuator/prometheus

# Check Prometheus targets: http://localhost:9090/targets
# Check Grafana data source: http://localhost:3000
```

---

## Troubleshooting Commands

### General Kubernetes
```bash
kubectl cluster-info
kubectl get nodes
kubectl get all -A
kubectl describe pod POD_NAME -n NAMESPACE
kubectl logs -f deployment/NAME -n NAMESPACE
kubectl exec -it POD_NAME -n NAMESPACE -- /bin/bash
```

### Docker Troubleshooting
```bash
docker images
docker ps -a
docker logs CONTAINER_NAME
docker exec -it CONTAINER_NAME /bin/bash
docker system prune -a
```

### Terraform Troubleshooting
```bash
terraform validate
terraform refresh
terraform state list
terraform state show RESOURCE_NAME
terraform plan -detailed-exitcode
```

### Git Troubleshooting
```bash
git status
git log --oneline
git branch -a
git remote -v
git fetch --all
git reset --hard origin/main
```

---

## Useful Monitoring Queries

### Prometheus Queries
```promql
# HTTP requests total
sum(http_server_requests_seconds_count)

# HTTP requests by endpoint
http_server_requests_seconds_count

# Request rate (per second)
rate(http_server_requests_seconds_count[5m])

# Average response time
rate(http_server_requests_seconds_sum[5m]) / rate(http_server_requests_seconds_count[5m])

# JVM memory usage
jvm_memory_used_bytes

# CPU usage
process_cpu_usage

# Garbage collection time
rate(jvm_gc_pause_seconds_sum[5m])
```

### Grafana Dashboard Queries
```promql
# Panel 1: Request Rate
rate(http_server_requests_seconds_count[5m])

# Panel 2: Response Time
histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m]))

# Panel 3: Memory Usage
jvm_memory_used_bytes{area="heap"}

# Panel 4: CPU Usage
process_cpu_usage * 100
```

---

## Complete Cleanup Commands

### Clean Everything
```bash
# Stop all port-forwards (Ctrl+C in terminals)

# Clean Kubernetes
kubectl delete -f argocd/ --ignore-not-found=true
kubectl delete namespace argocd --ignore-not-found=true
kubectl delete -f monitoring/ --ignore-not-found=true
kubectl delete namespace monitoring --ignore-not-found=true
kubectl delete -f k8s/ -n springboot-app --ignore-not-found=true
kubectl delete namespace springboot-app --ignore-not-found=true
helm uninstall springboot-app -n springboot-app --ignore-not-found=true

# Clean Docker
docker stop $(docker ps -q) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true
docker rmi your-username/springboot-app 2>/dev/null || true

# Clean AWS (if needed)
cd terraform/dev
terraform destroy -auto-approve
```

---

## Quick Start Commands (Full Pipeline)

### Complete Setup (Copy-Paste Ready)
```bash
# 1. Create and build Spring Boot app
mkdir my-springboot-app && cd my-springboot-app
# (Add all source files as per guide)
mvn clean install

# 2. Build and push Docker image
docker build -t your-username/springboot-app .
docker push your-username/springboot-app

# 3. Deploy AWS infrastructure
cd terraform/dev
terraform init && terraform apply -auto-approve
EC2_IP=$(terraform output -raw instance_public_ip)

# 4. Setup Git and push
git init && git add . && git commit -m "Initial commit"
git remote add origin https://github.com/your-username/your-repo.git
git push -u origin main

# 5. Deploy to Kubernetes
kubectl apply -f k8s/
helm install springboot-app helm/springboot-app --create-namespace --namespace springboot-app

# 6. Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd/application.yaml

# 7. Deploy monitoring
kubectl create namespace monitoring
# Update monitoring configs with EC2 IP
kubectl apply -f monitoring/

# 8. Access services
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
kubectl port-forward svc/grafana-service 3000:3000 -n monitoring &
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring &
```

### Quick Test Commands
```bash
# Test Spring Boot app
curl http://localhost:8484/hello

# Test Kubernetes app
kubectl port-forward svc/springboot-app-service 8080:80 -n springboot-app
curl http://localhost:8080/hello

# Test monitoring
curl http://localhost:9090/targets  # Prometheus targets
curl http://localhost:3000         # Grafana login
```

---

## Environment-Specific Commands

### Development Environment
```bash
git checkout dev
kubectl config set-context --current --namespace=springboot-app
helm upgrade springboot-app helm/springboot-app -n springboot-app --set image.tag=dev
```

### Production Environment
```bash
git checkout main
kubectl config set-context --current --namespace=production
helm upgrade springboot-app helm/springboot-app -n production --set image.tag=latest --set replicaCount=3
```

### Staging Environment
```bash
git checkout staging
kubectl config set-context --current --namespace=staging
helm upgrade springboot-app helm/springboot-app -n staging --set image.tag=staging --set replicaCount=2
```