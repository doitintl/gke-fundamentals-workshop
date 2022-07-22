# GKE Workshop LAB-13

## Scaling a deployment using HPA

<!-- Source: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/ -->

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Deployment

1. Create namespace and deployments:

```bash
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-php-deployment.yaml
```

2. Inspect the pods once they are running:

```bash
kubectl get pods -n doit-lab-13
kubectl describe pod ... -n doit-lab-13
```

3. Deploy the load generator:

```bash
kubectl apply -f 02-load-generator-pod.yaml
```

4. Check/wait until CPU and memory metrics are coming in:

```bash
watch -n 1 'kubectl top pod -n doit-lab-13'
```

5. Deploy the Horizontal Pod Autoscaler:

```bash
kubectl apply -f 03-php-hpa.yaml
```

6. Check/wait for scaleup:

```bash
watch -n 1 'kubectl top pod -n doit-lab-13'
```

## Application Clean-Up

```bash
kubectl delete -f .
```
