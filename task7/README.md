# Task 7: JPrometheus Deployment on K8s

This directory contains a complete Prometeus and Grafana setup with custom SMTP server.

## Structure

```
task7/
|── values.yaml           # Configuration values
└── README.md              # This file
```

## Prerequisites

1. **Kubernetes cluster** (Minikube or any K8s cluster)
2. **Helm 3.x** installed

## Installation

### 1. Setup Credentials 

**Option A: Automated Setup (Recommended)**
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
.\secrets.sh
```


### 3. Access Dashbord

# Grafana password
```bash
kubectl get secret -n monitoring prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 --decode
```

# Grafana url
```bash
kubectl --namespace monitoring port-forward grafana-pod-name 3000
```

# Promethaus
```bash
kkubectl port-forward -n monitoring pod/prometheus-prometheus-kube-prometheus-prometheus-0 9090:9090
```

### 4. Cleanup

```bash
kkubectl delete namespace monitoring
```