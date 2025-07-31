#!/bin/bash

echo "🔧 Configuring Prometheus and Grafana..."

# Port forward to access services
echo "📊 Setting up port forwards..."
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring &
PROMETHEUS_PID=$!

kubectl port-forward svc/grafana-service 3000:3000 -n monitoring &
GRAFANA_PID=$!

kubectl port-forward svc/springboot-app-service-test 8080:80 -n springboot-app &
APP_PID=$!

echo "⏳ Waiting for services to be ready..."
sleep 10

echo "✅ Services are now accessible:"
echo "🌐 Grafana: http://localhost:3000 (admin/admin123)"
echo "📊 Prometheus: http://localhost:9090"
echo "🚀 Spring Boot App: http://localhost:8080"

echo ""
echo "📈 To configure Grafana:"
echo "1. Go to http://localhost:3000"
echo "2. Login with admin/admin123"
echo "3. Add Prometheus data source: http://prometheus-service.monitoring.svc.cluster.local:9090"
echo "4. Import dashboard or create custom queries"

echo ""
echo "🔍 To check Prometheus targets:"
echo "1. Go to http://localhost:9090"
echo "2. Click Status > Targets"
echo "3. Look for kubernetes-pods targets"

echo ""
echo "Press Ctrl+C to stop all port forwards"
wait