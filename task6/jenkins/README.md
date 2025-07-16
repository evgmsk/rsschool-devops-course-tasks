# Jenkins Helm Chart

A Helm chart for deploying Jenkins on Kubernetes with CI/CD pipeline capabilities for Docker builds and Helm deployments.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `rs-jenkins` in the jenkins namespace:

```bash
helm install rs-jenkins ./jenkins-chart --namespace jenkins --create-namespace
```
The `--create-namespace` flag tells Helm to create the namespace if it doesn't exist.

## Configuration

The following table lists the configurable parameters of the Jenkins chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `image.repository`       | Jenkins image repository| `jenkins/jenkins` |
| `image.tag`              | Jenkins image tag       | `lts`         |
| `image.pullPolicy`       | Image pull policy       | `IfNotPresent`|
| `service.type`           | Service type            | `ClusterIP`   |
| `service.port`           | Service port            | `8080`        |
| `persistence.enabled`    | Enable persistence      | `true`        |
| `persistence.createPV`    | Create PV automatically | `true`        |
| `persistence.storageClass`| Storage class          | `"manual"`    |
| `persistence.hostPath`    | Host path for PV       | `/data/jenkins` |
| `persistence.size`       | PVC size                | `8Gi`         |
| `resources.requests.cpu` | CPU request             | `100m`        |
| `resources.requests.memory` | Memory request       | `256Mi`       |
| `resources.limits.cpu`   | CPU limit               | `500m`        |
| `resources.limits.memory`| Memory limit            | `512Mi`       |
| `admin.name`              | Admin username          | `admin`       |
| `admin.password`          | Admin password          | `password`    |
| `rbac.create`            | Create RBAC resources   | `true`        |
| `pipeline.gitUrl`        | Git repository URL      | `https://github.com/evgmsk/rsschool-devops-course-tasks.git` |
| `sonarqube.url`          | SonarQube server URL    | `http://sonarqube:9000` |

## Accessing Jenkins

1. Get the Jenkins URL:

   ```bash
   # If using port-forward:
   kubectl port-forward svc/rs-jenkins 8080:8080 -n jenkins
   
   # If using NodePort with Docker driver:
   minikube service rs-jenkins -n jenkins --url
   # Keep the terminal open and use the first URL
   
   # If using NodePort with VM-based drivers:
   minikube ip  # Get the Minikube IP
   # Then access Jenkins at http://<minikube-ip>:30080
   ```

2. Access Jenkins at:
   - http://localhost:8080 (if using port-forward)
   - URL from minikube service command (if using Docker driver)
   - http://<minikube-ip>:30080 (if using VM-based drivers)

3. Login with the credentials:
   - Get a generated password if not set in the values.yaml:
   ```bash
   kubectl logs -n jenkins $(kubectl get pods -n jenkins -o name | Select-Object -First 1)
   ```
   - Username: admin
   - Password: 'generated_or_password_from_values.yaml'

## Check persistence

   ```bash
   kubectl get pvc -n jenkins
   kubectl get pv
   ```

## CI/CD Pipeline

This Jenkins deployment includes:

- **Pre-configured plugins** for Docker, Kubernetes, AWS, and SonarQube
- **Pipeline job** that builds Docker images and pushes to ECR
- **Helm deployment** capabilities for Kubernetes
- **Quality gates** with SonarQube integration
- **RBAC configuration** for Kubernetes access

### Pipeline Features

- Builds Flask application and runs tests
- Creates Docker images and pushes to AWS ECR
- Deploys applications using Helm charts
- Supports multiple environments (dev/staging/prod)
- Manual approval gates for deployments

## Uninstalling the Chart

To uninstall/delete the `rs-jenkins` deployment:

```bash
helm uninstall rs-jenkins -n jenkins
```