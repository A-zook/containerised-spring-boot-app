#!/bin/bash

echo "🚀 Setting up access to monitoring services..."

# Check if pods are running
echo "📊 Checking monitoring pods..."
kubectl get pods -n monitoring

echo ""
echo "🌐 To access Grafana (http://localhost:3000):"
echo "kubectl port-forward svc/grafana-service 3000:3000 -n monitoring"
echo "Username: admin"
echo "Password: admin123"

echo ""
echo "📊 To access Prometheus (http://localhost:9090):"
echo "kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring"

echo ""
echo "📈 To access Spring Boot metrics:"
echo "kubectl port-forward svc/springboot-app-service 8080:80 -n springboot-app"
echo "Then visit: http://localhost:8080/actuator/prometheus"

echo ""
echo "🔧 Run these commands in separate terminals to access the services"