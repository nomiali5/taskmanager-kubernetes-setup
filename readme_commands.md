# TaskManager Helm Chart

This repository contains the Helm chart for deploying the TaskManager API and database in Kubernetes. It includes HPA (Horizontal Pod Autoscaler) configuration, liveness/readiness probes, and resource management.

---

## Table of Contents

- [Prerequisites](#prerequisites)  
- [Installation](#installation)  
- [Useful Helm and Kubernetes Commands](#useful-helm-and-kubernetes-commands)  
- [Horizontal Pod Autoscaler (HPA) Testing](#horizontal-pod-autoscaler-hpa-testing)  
- [Verify Metrics and Scaling](#verify-metrics-and-scaling)

---

## Prerequisites

- Kubernetes cluster (Minikube or any other K8s cluster)  
- Helm 3 installed  
- Metrics server deployed (`metrics-server`)  

---

## Installation

To deploy the chart using the development values:

```bash
helm install taskmanager . -f values-dev.yaml
```

---

## Useful Helm and Kubernetes Commands

```bash
# List all resources in the taskmanager namespace
kubectl get all -n taskmanager

# Forward ingress-nginx service port for local testing
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 80:80

# Upgrade Helm release
helm upgrade taskmanager . -f .\values-dev.yaml

# Run Helm tests
helm test taskmanager -n taskmanager
```

---

## Horizontal Pod Autoscaler (HPA) Testing

```bash
# Watch HPA scaling
kubectl get hpa -n taskmanager -w

# Run a load generator pod
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh

# Inside the pod, generate load
while true; do wget -q -O- http://taskmanager-api:8080/health; done
```

---

## Verify Metrics and Scaling

```bash
# Show CPU/Memory usage of pods
kubectl top pods -n taskmanager

# Check deployments
kubectl get deployment -n taskmanager

# Check HPA
kubectl get hpa -n taskmanager

# Check metrics server pods
kubectl get pods -n kube-system | findstr metrics-server

# Check metrics server deployment
kubectl get deployment metrics-server -n kube-system

# Watch HPA and pod scaling
kubectl get hpa -n taskmanager -w
kubectl get pods -n taskmanager -w

# Detailed HPA info
kubectl describe hpa taskmanager -n taskmanager
```

**Example of HPA autoscaling behavior:**

```text
kubectl get hpa -n taskmanager -w
NAME          REFERENCE                    TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
taskmanager   Deployment/taskmanager-api   cpu: 1%/20%   1         3         1          26m
taskmanager   Deployment/taskmanager-api   cpu: 363%/20%  1         3         1          26m
taskmanager   Deployment/taskmanager-api   cpu: 363%/20%  1         3         3          26m
```

This shows how HPA scales your deployment from 1 pod to 3 pods under CPU load.

---

## Resources Configuration Example

```yaml
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

- **Requests**: Minimum resources guaranteed to the container.  
- **Limits**: Maximum resources a container can use.  

HPA uses the CPU **requests** to calculate utilization.

