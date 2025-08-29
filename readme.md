# TaskManager Helm Chart

This Helm chart deploys the **TaskManager API** and **Database** with optional **Horizontal Pod Autoscaler (HPA)** on Kubernetes.

## Features

- TaskManager API deployment with configurable:
  - Image repository and tag
  - CPU and memory requests/limits
  - Liveness and readiness probes
- Database deployment (MSSQL)
- HPA support for the API based on CPU utilization
- Environment variables via ConfigMap and Secrets
- Optional load testing pods

---

## Requirements

- Kubernetes cluster (tested on Minikube)
- Helm 3+
- Metrics Server installed for HPA (`kubectl get deployment metrics-server -n kube-system`)

---

## Values Configuration (`values.yaml` / `values-dev.yaml`)

### **API**

```yaml
api:
  replicaCount: 1
  image:
    repository: nomiali/taskmanagerapi
    tag: latest
    pullPolicy: Always
  service:
    type: ClusterIP
    port: 8080
  hpa:
    enabled: true
    minReplicas: 1
    maxReplicas: 3
    targetCPUUtilizationPercentage: 20
  resources:
    requests:
      cpu: 10m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi
  livenessProbe:
    path: /tasks
    initialDelaySeconds: 10
    periodSeconds: 15
  readinessProbe:
    path: /tasks
    initialDelaySeconds: 5
    periodSeconds: 10
  env:
    APP_ENV: "development"
    LOG_LEVEL: "Warning"
```

### **Database**

```yaml
db:
  image: mcr.microsoft.com/mssql/server:2022-latest
  secretName: sql-secret
  pvcName: taskmanager-db-pvc
```

---

## Install / Upgrade

```bash
# Install
helm install taskmanager ./charts/taskmanager -n taskmanager --create-namespace

# Upgrade
helm upgrade taskmanager ./charts/taskmanager -n taskmanager
```

---

## HPA Behavior

- HPA scales the API deployment based on CPU requests.
- CPU utilization is calculated as:

```
CPU Usage / CPU Requests * 100%
```

- Ensure `metrics-server` is installed and running.
- For testing scaling, you can reduce CPU requests (e.g., `cpu: 10m`) and run a load generator pod.

---

## Example Load Test Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: load-generator
  namespace: taskmanager
spec:
  containers:
  - name: load-generator
    image: busybox
    command: ["sh", "-c", "while true; do wget -q -O- http://taskmanager-api:8080/tasks; done"]
  restartPolicy: Never
```

---

## Notes

- **Requests vs Limits**:
  - `requests` → used for scheduling and HPA metrics.
  - `limits` → maximum usage allowed for the container.
- HPA **does not scale** without CPU requests defined.
- For testing, set low CPU requests so small load triggers scaling.

---

## Check Status

```bash
# Pods
kubectl get pods -n taskmanager

# HPA
kubectl get hpa -n taskmanager

# Metrics
kubectl top pods -n taskmanager
```

