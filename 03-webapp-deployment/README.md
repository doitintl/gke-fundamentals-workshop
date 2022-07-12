# GKE Workshop LAB-03

## Web-Application Deployment, NodePort Example

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Introduction

In the following lab we will set up our local development environment, provision the workshop cluster and roll out our static web application example ([source](https://github.com/doitintl/labs-web-app-static). Your deployment won't be exposed and is only available by ClusterIP of the corresponding pod-service. You can access the application by tunneling your localhost through `kubectl proxy` command.

![application screenshot](../.github/media/lab-03-screenshot-small.png)

## Deployment

1. Run deployment

```bash
kubectl apply -f .
```

## Cluster Application Check / Playground

1. You can check the state of Pods at any time with the following kubectl command:

```bash
kubectl get pods -n doit-lab-03
```

2. You can check your deployment with the following kubectl command:

```bash
kubectl get deployments -n doit-lab-03
```

3. You can check the corresponding service endpoint by the following kubectl command:

```bash
kubectl get services -n doit-lab-03
```

4. You can test the deployed web application using this (mighty proxy) command and access the app by hitting url `http://localhost:8080`

```bash
kubectl port-forward service/static-web-app-service 8080:8080 -n doit-lab-03
```

## Optional Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-03` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-03
```

Replace `02-static-web-app-deployment.yaml` with `affinity-tolerations/03-static-web-app-affinity-deployment.yaml` to see how the Kubernetes scheduler decides on the pod placement now:

```bash
kubectl delete -f 02-static-web-app-deployment.yaml
kubectl apply -f affinity-tolerations/03-static-web-app-affinity-deployment.yaml
```

Taint your nodes with the `NoSchedule` taint and recreate the deployment:

```
kubectl get nodes
kubectl taint nodes node1 node2 node3 blocked:NoSchedule
kubectl delete -f 02-static-web-app-deployment.yaml
kubectl apply -f 02-static-web-app-deployment.yaml
```

Replace the (unscheduleable, due to taints) deployment with `affinity-tolerations/04-static-web-app-tolerations-deployment.yaml`:

```bash
kubectl delete -f 02-static-web-app-deployment.yaml
kubectl apply -f affinity-tolerations/04-static-web-app-tolerations-deployment.yaml
```

## Application Clean-Up

```bash
kubectl delete -f .
kubectl taint nodes node1 node2 node3 blocked:NoSchedule-
```
