# GKE Workshop LAB-02

## Web-Application, Multiple Container Pod Example

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Introduction

In the following lab we will set up our local development environment, provision the workshop cluster and roll out our static web application example with an additional sidecar and init-container. Your deployment won't be exposed and is only available by ClusterIP of the corresponding pod-service. You can access the application by tunneling your localhost through `kubectl proxy` command, or `kubectl port-forward`.

<!-- ![application screenshot](../.github/media/lab-02-screenshot-small.png) -->

## Deployment

1. Run deployment

```bash
kubectl apply -f .
```

## Cluster Application Check / Playground

1. You can check the state of Pods at any time with the following kubectl command:

```bash
kubectl get pods -n doit-lab-02
```

2. You can also permanently display the current log stream of the pod in question in your terminal using the following command:

```bash
# logs of static web application (container=001-static-web-app-c)
kubectl logs -f -l k8s-app=static-web-app-advanced -n doit-lab-02 -c 001-static-web-app-c

# logs of web applications sidecar (container=002-static-web-app-sidecar-c)
kubectl logs -f -l k8s-app=static-web-app-advanced -n doit-lab-02 -c 002-static-web-app-sidecar-c

# logs of pod's primary init container (container=000-static-web-app-advanced-init-c)
kubectl logs -f -l k8s-app=static-web-app-advanced -n doit-lab-02 -c 000-static-web-app-advanced-init-c
```

3. You can access this pod from your local environment by kubectl port-forwarding & access the app by hitting url `http://localhost:8080`

```bash
kubectl port-forward pod/static-web-app-advanced 8080:80 -n doit-lab-02
```

4. You can also jump directly into a sh-terminal of the started pod

```bash
# static web application (container=001-static-web-app-c)
kubectl exec -it static-web-app-advanced -c 001-static-web-app-c -n doit-lab-02 -- sh

# web applications sidecar (container=002-static-web-app-sidecar-c, will run for 60s)
kubectl exec -it static-web-app-advanced -c 002-static-web-app-sidecar-c -n doit-lab-02 -- sh
```

## Optional Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-02` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-02
```

## Application Clean-Up

```bash
kubectl delete -f .
```

## Links

- https://cloud.google.com/sdk/gcloud/reference/container/clusters/create
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://phoenixnap.com/kb/kubectl-commands-cheat-sheet
