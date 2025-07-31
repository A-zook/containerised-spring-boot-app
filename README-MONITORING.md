# Monitoring Setup with Prometheus & Grafana

## 🏗️ Architecture

```
Spring Boot App → Actuator Metrics → Prometheus → Grafana Dashboard
```

## 📊 Components Added

### **1. Spring Boot Metrics**
- **Actuator**: Health checks and metrics endpoints
- **Micrometer**: Prometheus metrics export
- **Endpoints**: `/actuator/health`, `/actuator/prometheus`

### **2. Prometheus Stack**
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert management
- **Node Exporter**: System metrics

### **3. Kubernetes Integration**
- **ServiceMonitor**: Automatic service discovery
- **Helm Charts**: Prometheus stack deployment
- **ArgoCD**: GitOps monitoring deployment

## 🚀 Quick Setup

### **Option 1: Manual Helm Installation**
```bash
# Run monitoring setup script
bash scripts/setup-monitoring.sh

# Access Grafana
kubectl port-forward svc/prometheus-stack-grafana 3000:80 -n monitoring
# Visit: http://localhost:3000
```

### **Option 2: ArgoCD GitOps Deployment**
```bash
# Install ArgoCD with monitoring
bash argocd/install.sh

# Check ArgoCD applications
kubectl get applications -n argocd
```

## 📈 Available Metrics

### **Spring Boot Application Metrics**
- `http_server_requests_seconds_count` - HTTP request count
- `http_server_requests_seconds_sum` - HTTP request duration
- `jvm_memory_used_bytes` - JVM memory usage
- `process_cpu_usage` - CPU usage
- `jvm_gc_pause_seconds` - Garbage collection metrics

### **Kubernetes Metrics**
- Pod CPU/Memory usage
- Node resource utilization
- Deployment status
- Service availability

## 🎯 Grafana Dashboards

### **Pre-configured Dashboards**
- **Spring Boot Metrics**: Custom dashboard for app metrics
- **Kubernetes Cluster**: Node and pod monitoring
- **JVM Metrics**: Memory, GC, threads
- **HTTP Metrics**: Request rates, response times

### **Access Information**
- **URL**: http://localhost:3000
- **Username**: admin
- **Password**: admin123 (or from setup script)

## 🔧 Configuration Files

```
monitoring/
├── prometheus/
│   └── values.yaml              # Prometheus stack configuration
├── grafana/
│   └── dashboard.json           # Custom Spring Boot dashboard
├── servicemonitor.yaml          # Prometheus service discovery
└── scripts/
    └── setup-monitoring.sh      # Automated setup script
```

## 📊 Monitoring Endpoints

### **Application Endpoints**
- `GET /actuator/health` - Health status
- `GET /actuator/metrics` - Available metrics
- `GET /actuator/prometheus` - Prometheus format metrics

### **Monitoring Services**
- **Grafana**: http://localhost:3000
- **Prometheus**: http://localhost:9090
- **AlertManager**: http://localhost:9093

## 🔍 Useful Commands

```bash
# Check monitoring namespace
kubectl get all -n monitoring

# View Prometheus targets
kubectl port-forward svc/prometheus-stack-kube-prom-prometheus 9090:9090 -n monitoring

# Access Grafana
kubectl port-forward svc/prometheus-stack-grafana 3000:80 -n monitoring

# Check ServiceMonitor
kubectl get servicemonitor -n monitoring

# View application metrics
curl http://localhost:8080/actuator/prometheus
```

## 🚨 Alerting

### **Pre-configured Alerts**
- High CPU usage (>80%)
- High memory usage (>90%)
- Application down
- High error rate (>5%)

### **Alert Channels**
- Slack notifications
- Email alerts
- Webhook integrations

## 🔄 GitOps Integration

The monitoring stack is deployed via ArgoCD:
- **Prometheus Stack**: Deployed from Helm repository
- **ServiceMonitor**: Deployed from Git repository
- **Dashboards**: Version controlled in Git
- **Auto-sync**: Automatic updates on Git changes

## 📋 Troubleshooting

### **Common Issues**
```bash
# ServiceMonitor not discovering targets
kubectl describe servicemonitor springboot-app-monitor -n monitoring

# Grafana not accessible
kubectl get svc -n monitoring | grep grafana

# Prometheus not scraping
kubectl logs -f deployment/prometheus-stack-kube-prom-prometheus -n monitoring
```