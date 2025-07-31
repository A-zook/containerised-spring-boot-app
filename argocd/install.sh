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