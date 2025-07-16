# Task 6: Jenkins CI/CD Pipeline

This directory contains a complete Jenkins setup with Helm chart for running CI/CD pipelines.

## Structure

```
task6/
├── jenkins/                    # Jenkins Helm chart
│   ├── templates/
│   │   ├── config.yaml        # Jenkins Configuration as Code
│   │   ├── deployment.yaml    # Jenkins deployment
│   │   ├── service.yaml       # Jenkins service
│   │   ├── pv.yaml           # Persistent volume
│   │   ├── pvc.yaml          # Persistent volume claim
│   │   ├── rbac.yaml         # RBAC configuration
│   │   ├── secret.yaml       # Admin credentials
│   │   ├── plugins.yaml      # Plugin configuration
│   │   └── credentials.yaml  # AWS/SonarQube credentials
│   ├── values.yaml           # Configuration values
│   └── Chart.yaml           # Chart metadata
├── flask-app/              # Flask app Helm chart for deployment
├── setup-iam-role.yaml      # IAM role for service accounts (EKS)
├── Jenkinsfile              # Pipeline definition
├── main.py                  # Flask application
├── requirements.txt         # Python dependencies
├── Dockerfile              # Docker image definition
├── ecr-values.yaml         # ECR-specific Helm values
├── tests/                  # Unit tests
└── README.md              # This file
```

## Prerequisites

1. **Kubernetes cluster** (Minikube or any K8s cluster)
2. **Helm 3.x** installed
3. **Docker** available on Jenkins nodes
4. **SonarQube** server (optional, can be deployed separately)
5. **AWS ECR** repository created

## Installation

### 1. Setup Credentials (Choose One Option)

**Option A: Automated Setup (Recommended)**
```bash
# Linux/Mac - Edit setup-secrets.sh with your actual tokens
chmod +x setup-secrets.sh
./setup-secrets.sh

# Windows PowerShell - Edit setup-secrets.ps1 with your actual tokens
.\setup-secrets.ps1
```

**Option B: Manual Secret Creation**
```bash
# Create GitHub credentials secret
kubectl create secret generic github-credentials \
  --from-literal=username=YOUR_GITHUB_USERNAME \
  --from-literal=token=YOUR_GITHUB_TOKEN \
  --namespace=jenkins

# Create SonarQube token secret
kubectl create secret generic jenkins-sonar-token \
  --from-literal=token=YOUR_SONAR_TOKEN \
  --namespace=jenkins

# Apply IAM role for ECR access
kubectl apply -f setup-iam-role.yaml
```

### 2. Update Configuration

Edit `jenkins/values.yaml` and update:

```yaml
# Pipeline configuration
pipeline:
  gitUrl: "https://github.com/your-username/rsschool-devops-course-tasks.git"

# SonarQube configuration  
sonarqube:
  url: "http://your-sonarqube-server:9000"
```

### 2. Deploy Jenkins

```bash
# Create namespace
kubectl create namespace jenkins

# Install Jenkins with Helm
helm install rs-jenkins ./jenkins --namespace jenkins --create-namespace

# Check deployment
kubectl get pods -n jenkins
```

### 3. Access Jenkins

```bash
# Get Jenkins URL
minikube service rs-jenkins -n jenkins --url

# Or use port-forward
kubectl port-forward svc/rs-jenkins 8080:8080 -n jenkins
```

Login with:
- Username: `admin`
- Password: `password` (or value from values.yaml)

## Pipeline Features

The Jenkins pipeline includes:

1. **Checkout**: Get source code from Git
2. **Build Application**: Set up Python environment and dependencies
3. **Unit Tests**: Run pytest with coverage reporting
4. **Security Check**: SonarQube analysis with quality gate
5. **Quality Gate**: Wait for SonarQube quality gate results
6. **Build & Push Docker Image**: Build Docker image and push to AWS ECR
7. **Deploy to Kubernetes**: Deploy using Helm flask-app chart with environment selection

## Pipeline Configuration

The Jenkinsfile defines a pipeline with:

- **Branch-based deployment**: Docker build/push on main and task_6 branches or FORCE_DEPLOY=true
- **Manual approval**: Deployment stage requires manual confirmation
- **Environment selection**: Choose dev/staging/prod during deployment
- **Helm deployment**: Uses local ./helm-chart (flask-app chart)
- **Email notifications**: On success/failure

## Required Jenkins Plugins

The following plugins are automatically installed:

- workflow-aggregator (Pipeline)
- git
- docker-workflow
- sonar (SonarQube Scanner)
- kubernetes
- aws-credentials
- pipeline-stage-view
- blueocean
- email-ext
- junit
- coverage

## Environment Variables

The pipeline uses these environment variables:

```bash
ECR_REGISTRY=753350392043.dkr.ecr.eu-west-1.amazonaws.com
ECR_REPOSITORY=rs-flask-app
AWS_REGION=eu-west-1
SONAR_PROJECT_KEY=flask-app
```

## Usage

1. **Automatic Build**: Pipeline runs on every commit, builds and tests application
2. **Docker Build**: Builds/pushes Docker image on main and task_6 branches or with FORCE_DEPLOY=true
3. **Manual Deployment**: Requires manual approval with environment selection (dev/staging/prod)
4. **Helm Deployment**: Uses flask-app chart with dynamic image tag and ECR values
5. **Quality Gates**: Pipeline stops if tests fail or SonarQube quality gate fails

## Troubleshooting

### Jenkins Pod Issues
```bash
# Check pod logs
kubectl logs -n jenkins $(kubectl get pods -n jenkins -o name)

# Check persistent volume
kubectl get pv,pvc -n jenkins
```

### Pipeline Issues
```bash
# Check Jenkins logs for pipeline execution
# Access Jenkins UI → Pipeline Job → Console Output
```

### Docker Issues
```bash
# Ensure Docker socket is mounted
kubectl describe pod -n jenkins $(kubectl get pods -n jenkins -o name)
```

## Security Notes

- Change default admin password in production
- Uses IAM role `ecr-man` for ECR access (no AWS credentials needed)
- GitHub and SonarQube tokens stored as Kubernetes secrets
- `setup-secrets.sh` is gitignored to prevent credential exposure
- Configure proper RBAC for Jenkins service account

## Customization

To customize the Jenkins setup:

1. Modify `jenkins/values.yaml` for basic configuration
2. Update `jenkins/templates/config.yaml` for advanced Jenkins settings
3. Add more plugins in the `plugins` section of values.yaml
4. Configure additional tools in the JCasC configuration