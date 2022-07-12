# GKE Workshop LAB-01

## Web-Application, Single Container Pod Example

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GKE/K8s Version](https://img.shields.io/badge/k8s%20version-1.18.20-blue.svg)](#)
[![GCloud SDK Version](https://img.shields.io/badge/gcloud%20version-359.0.0-blue.svg)](#)

## Introduction

In the following lab we will set up our local development environment, provision the workshop cluster and roll out our static web application example ([source](https://github.com/doitintl/labs-web-app-static) as single container Pod. Your deployment won't be exposed and is only available by ClusterIP of the corresponding pod-service. You can access the application by tunneling your localhost through `kubectl proxy` command.

![application screenshot](../.github/media/lab-01-screenshot-small.png)

## Deployment

1. Run deployment

```bash
kubectl apply -f .
```

## Cluster Application Check / Playground

1. You can check the state of Pods at any time with the following kubectl command:

```bash
kubectl get pods -n doit-lab-01
```

2. You can also permanently display the current log stream of the pod in question in your terminal using the following command:

```bash
kubectl get pods -n doit-lab-01 --watch
```

3. You can access this pod from your local environment by kubectl port-forwarding & access this web-app @localhost:8080

```bash
kubectl port-forward pod/static-web-app 8080:80 -n doit-lab-01
```

5. You can also jump directly into a sh-terminal of the started pod

```bash
kubectl exec -it static-web-app -n doit-lab-01 -- sh
```

## Optional Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-01` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-01
```

## Application Clean-Up

```bash
kubectl delete -f .
```

## Links

- https://cloud.google.com/sdk/gcloud/reference/container/clusters/create
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://phoenixnap.com/kb/kubectl-commands-cheat-sheet
