# Jenkins Helm Chart

A simple Helm chart for deploying Jenkins on Kubernetes.

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
| `job.name`               | Job name                | `hello-rs-world` |
| `job.description`        | Job description         | `A simple job that prints hello rs world` |
| `job.command`            | Job command             | `echo 'hello rs world'` |

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

## Jobs

A job named `hello-rs-world` is automatically created using Jenkins Configuration as Code (JCasC). The job runs a simple shell command that prints "hello rs world".

You can customize the job by modifying the `job` section in your values.yaml file:

```yaml
job:
  name: "hello-rs-world"
  description: "A simple job that prints hello rs world"
  command: "echo 'hello rs world'"
```

To run the job:
1. Log in to Jenkins
2. Click on the job name `hello-rs-world`
3. Click "Build Now"
4. Click on the build number and then "Console Output" to see the result

## Uninstalling the Chart

To uninstall/delete the `rs-jenkins` deployment:

```bash
helm uninstall rs-jenkins -n jenkins
```