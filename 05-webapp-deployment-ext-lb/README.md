# GKE Workshop LAB-05

## Web-Application Deployment, LoadBalancer Example

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GKE/K8s Version](https://img.shields.io/badge/k8s%20version-1.18.20-blue.svg)](#)
[![GCloud SDK Version](https://img.shields.io/badge/gcloud%20version-359.0.0-blue.svg)](#)

## Introduction

In the following lab we will set up our local development environment, provision the workshop cluster and roll out our static web application example ([source](https://github.com/doitintl/labs-web-app-static). Your deployment will be exposed by corresponding pod-service and wait for incoming traffic through a standard External HTTP LoadBalancer (`http://<external-lb-ip>`) at port `8080`.

![application screenshot](../.github/media/lab-05-screenshot-small.png)

## Deployment

1. Run deployment

```bash
kubectl apply -f .
```

2. Check current service load-balancer state (external IP)

_this step can take up to 2 Minutes_

```bash
kubectl get service -n doit-lab-05 --watch
```

## Cluster Application Check / Playground

1. You can check the state of Pods at any time with the following kubectl command:

```bash
kubectl get pods -n doit-lab-05
```

2. You can check your deployment with the following kubectl command:

```bash
kubectl get deployments -n doit-lab-05
```

3. You can check the corresponding service endpoint by the following kubectl command:

```bash
kubectl get services -n doit-lab-05
```

4. Or just visit the application by hitting your load-balancers external-IP at port 8080:

```bash
  -> http://<external-ip-of-your-load-balancer>:8080/
```

## Optional Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-05` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-05
```

## Application Clean-Up

```bash
kubectl delete -f .
```

## Links

- https://cloud.google.com/sdk/gcloud/reference/container/clusters/create
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://phoenixnap.com/kb/kubectl-commands-cheat-sheet
