# Flask App Helm Chart

A Helm chart for deploying a simple Flask application to Kubernetes using a private AWS ECR repository.

## Prerequisites

- Kubernetes cluster (e.g., Minikube)
- Helm 3.x
- kubectl configured to communicate with your cluster
- AWS CLI configured with ECR access
- Docker for building and pushing images

## Docker Image

The application uses a private AWS ECR image:
```
753350392043.dkr.ecr.eu-west-1.amazonaws.com/rs-flask-app:latest
```

## Setup AWS ECR Credentials

1. Create Kubernetes secret for ECR access:
```bash
kubectl create secret docker-registry aws-ecr-secret \
  --docker-server=753350392043.dkr.ecr.eu-west-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region eu-west-1) \
  --namespace=default
```

2. Build and push your Flask application:
```bash
# Build the image
docker build -t 753350392043.dkr.ecr.eu-west-1.amazonaws.com/rs-flask-app:latest .

# Login to ECR
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 753350392043.dkr.ecr.eu-west-1.amazonaws.com

# Push the image
docker push 753350392043.dkr.ecr.eu-west-1.amazonaws.com/rs-flask-app:latest
```

## Installation

```bash
# Install the chart with ECR credentials
helm install flask-app ./helm-chart -f ecr-values.yaml

# Verify the deployment
kubectl get pods
kubectl get services
```

## Accessing the Application

```bash
# Using minikube service (recommended for Docker driver)
minikube service flask-app-flask-app --url
# Keep the terminal open and access the provided URL

# Or using port-forward
kubectl port-forward service/flask-app-flask-app 8081:8080
# Then visit http://localhost:8081
```

## Configuration

The following table lists the configurable parameters of the chart and their default values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `753350392043.dkr.ecr.eu-west-1.amazonaws.com/rs-flask-app` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[{name: aws-ecr-secret}]` |
| `service.type` | Service type | `NodePort` |
| `service.port` | Service port | `8080` |
| `service.nodePort` | NodePort | `30082` |
| `env` | Environment variables | Flask configuration |
| `resources.limits.cpu` | CPU limits | `100m` |
| `resources.limits.memory` | Memory limits | `128Mi` |
| `resources.requests.cpu` | CPU requests | `50m` |
| `resources.requests.memory` | Memory requests | `64Mi` |

## Flask Application

The Flask app (`main.py`) contains:
- A simple "Hello, RS World!" endpoint at `/`
- Configured to run on host `0.0.0.0` and port `8080`
- Uses Flask development server

## Troubleshooting

1. **Pod CrashLoopBackOff**: Check if your Flask app has proper startup code:
```python
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
```

2. **Image Pull Errors**: Refresh ECR credentials:
```bash
kubectl delete secret aws-ecr-secret
kubectl create secret docker-registry aws-ecr-secret \
  --docker-server=753350392043.dkr.ecr.eu-west-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region eu-west-1)
```

3. **Service has no endpoints**: Ensure pod is running and ready:
```bash
kubectl get pods -l app=flask-app
kubectl get endpoints flask-app-flask-app
```

## Customization

Create a custom values file:

```yaml
# custom-values.yaml
image:
  repository: your-ecr-repo/flask-app
  tag: v1.0.0

service:
  type: LoadBalancer
  port: 80

resources:
  limits:
    cpu: 200m
    memory: 256Mi
```

Then install:
```bash
helm install flask-app ./helm-chart -f custom-values.yaml
```

## Uninstalling

```bash
# Uninstall the release
helm uninstall flask-app

# Clean up secrets (optional)
kubectl delete secret aws-ecr-secret
```