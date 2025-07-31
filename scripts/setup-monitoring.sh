#!/bin/bash

echo "📊 Setting up Prometheus and Grafana monitoring..."

# Add Prometheus Helm repository
echo "📦 Adding Prometheus Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace
echo "🏗️ Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Install Prometheus stack
echo "🚀 Installing Prometheus stack..."
helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values monitoring/prometheus/values.yaml \
  --wait

# Apply ServiceMonitor
echo "📈 Applying ServiceMonitor..."
kubectl apply -f monitoring/servicemonitor.yaml

# Wait for Grafana to be ready
echo "⏳ Waiting for Grafana to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus-stack-grafana -n monitoring

# Get Grafana admin password
echo "🔑 Getting Grafana admin password..."
GRAFANA_PASSWORD=$(kubectl get secret --namespace monitoring prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)

echo "✅ Monitoring setup complete!"
echo "=========================="
echo "🌐 Grafana URL: http://localhost:3000"
echo "👤 Username: admin"
echo "🔑 Password: $GRAFANA_PASSWORD"
echo ""
echo "🚀 To access Grafana:"
echo "kubectl port-forward svc/prometheus-stack-grafana 3000:80 -n monitoring"
echo ""
echo "📊 To access Prometheus:"
echo "kubectl port-forward svc/prometheus-stack-kube-prom-prometheus 9090:9090 -n monitoring"
echo ""
echo "📈 Spring Boot metrics available at: /actuator/prometheus"