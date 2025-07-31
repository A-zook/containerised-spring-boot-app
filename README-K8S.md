# Kubernetes + Helm + ArgoCD Setup

## 🏗️ Architecture Overview

```
GitHub Actions (CI) → Docker Hub → ArgoCD (CD) → Kubernetes
```

### Pipeline 1: Containerization (GitHub Actions)
- Builds Spring Boot JAR
- Creates Docker image
- Pushes to Docker Hub

### Pipeline 2: Deployment (ArgoCD)
- Monitors Git repository
- Deploys Helm charts to Kubernetes
- Manages application lifecycle

## 🚀 Quick Start

### 1. Prerequisites
```bash
# Ensure Docker Desktop with Kubernetes is running
kubectl cluster-info

# Install Helm
curl https://get.helm.sh/helm-v3.12.0-windows-amd64.zip
```

### 2. Test Kubernetes Files Locally
```bash
# Apply namespace
kubectl apply -f k8s/namespace.yaml

# Apply all manifests
kubectl apply -f k8s/ -n springboot-app

# Check deployment
kubectl get pods -n springboot-app
```

### 3. Test Helm Chart
```bash
# Validate Helm chart
helm lint helm/springboot-app

# Dry run
helm install springboot-app helm/springboot-app --dry-run --debug

# Install with Helm
helm install springboot-app helm/springboot-app --create-namespace --namespace springboot-app

# Check status
helm status springboot-app -n springboot-app
```

### 4. Install ArgoCD
```bash
# Run installation script
bash argocd/install.sh

# Or manual installation:
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Visit: https://localhost:8080
```

### 5. Deploy Application via ArgoCD
```bash
# Apply ArgoCD application
kubectl apply -f argocd/application.yaml

# Check application status
kubectl get applications -n argocd
```

## 📁 Project Structure

```
├── k8s/                          # Raw Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── helm/springboot-app/          # Helm chart
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── _helpers.tpl
├── argocd/                       # ArgoCD configuration
│   ├── namespace.yaml
│   ├── application.yaml
│   └── install.sh
└── .github/workflows/            # CI pipeline
    └── deploy.yml
```

## 🔄 Continuous Deployment Flow

1. **Developer pushes code** → GitHub
2. **GitHub Actions** builds and pushes Docker image
3. **ArgoCD** detects changes in Git repository
4. **ArgoCD** deploys updated Helm chart to Kubernetes
5. **Kubernetes** runs the application with new image

## 🛠️ Useful Commands

```bash
# Check all resources
kubectl get all -n springboot-app

# View logs
kubectl logs -f deployment/springboot-app -n springboot-app

# Port forward to test locally
kubectl port-forward svc/springboot-app-service 8080:80 -n springboot-app

# Update Helm deployment
helm upgrade springboot-app helm/springboot-app -n springboot-app

# Uninstall
helm uninstall springboot-app -n springboot-app
kubectl delete namespace springboot-app
```

## 🎯 Benefits

- **GitOps**: Declarative configuration management
- **Automated Deployment**: ArgoCD handles Kubernetes deployments
- **Rollback**: Easy rollback to previous versions
- **Scalability**: Kubernetes handles scaling and load balancing
- **Monitoring**: Built-in health checks and monitoring