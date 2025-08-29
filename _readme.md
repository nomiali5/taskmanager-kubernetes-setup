# TaskManager API

[![Helm Chart Version](https://img.shields.io/badge/helm-v1.0.0-blue)](https://helm.sh)
[![.NET 8](https://img.shields.io/badge/.NET-8.0-blue)](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)

## Description
TaskManager API is a minimal .NET 8 API for managing tasks, deployed via Kubernetes using Helm.  
It uses SQL Server as a backend and supports configuration via Helm `values.yaml`.

---

## Features
- .NET 8 Minimal API
- Kubernetes Deployment, Service, and Ingress
- Helm chart for easy installation and upgrades
- Configurable via `values.yaml`
- SQL Server backend with Kubernetes Secret support
- Horizontal Pod Autoscaling

---

## Prerequisites
- [Docker](https://www.docker.com/get-started)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm 3+](https://helm.sh/docs/intro/install/)
- Kubernetes cluster (Minikube, kind, or cloud provider)
- Optional: Ingress controller installed

---

## Installation

### 1. Build Docker image
```bash
docker build -t nomiali/taskmanagerapi:latest .
docker push nomiali/taskmanagerapi:latest
```

### 2. Deploy Helm chart
```bash
helm install taskmanager ./charts/taskmanager --create-namespace -n taskmanager
```

### 3. Verify Deployment
```bash
kubectl get all -n taskmanager
kubectl get ingress -n taskmanager
```

---

## Configuration

Edit `values.yaml` to change settings:

```yaml
namespace: taskmanager

api:
  replicaCount: 1
  image:
    repository: nomiali/taskmanagerapi
    tag: latest
  service:
    type: ClusterIP
    port: 8080
  env:
    APP_ENV: "development"
    LOG_LEVEL: "Warning"
  livenessProbe:
    path: /tasks
    initialDelaySeconds: 10
    periodSeconds: 15
  readinessProbe:
    path: /tasks
    initialDelaySeconds: 5
    periodSeconds: 10

db:
  image: mcr.microsoft.com/mssql/server:2022-latest
  database: TasksDb
  secretName: sql-secret
  pvc:
    size: 2Gi
  service:
    port: 1433
```

---

## Accessing the API

If using **Minikube**:

```bash
minikube addons enable ingress
minikube tunnel
```

Add the following to your hosts file:

```
<MINIKUBE_IP> taskmanager.local
```

Then access the API:

```
http://taskmanager.local/weatherforecast
```

---

## Updating the Helm Release

```bash
helm upgrade taskmanager ./charts/taskmanager -n taskmanager
```

---

## Uninstall

```bash
helm uninstall taskmanager -n taskmanager
kubectl delete namespace taskmanager
```

---

## License
MIT License

