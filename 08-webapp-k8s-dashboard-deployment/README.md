# GKE Workshop LAB-08

## Kubernetes Dashboard Deployment

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GKE/K8s Version](https://img.shields.io/badge/k8s%20version-1.18.20-blue.svg)](#)
[![GCloud SDK Version](https://img.shields.io/badge/gcloud%20version-359.0.0-blue.svg)](#)

## Introduction

In the following lab we will set up our local development environment, provision the workshop cluster and roll out the Kubernetes-dashboard application stack ([source](https://github.com/kubernetes/dashboard/blob/master/docs/user/installation.md)). This lab will give us a basic insight into the standard Kubernetes resources, clarify an important approach regarding the ServiceAccounts and RBAC to use, and provide a control base for our other labs.

![application screenshot](../.github/media/lab-08-screenshot-small.png)


## Cluster Application Deployment

Make sure you handled all previous steps of this README! Now, as announced, we perform the actual deployment of the kubernetes-dashboard and provision an access-authorized user for token-based authentication at the frontend of the application.

1. Run deployment and fetch admin-user's access-token
  ```bash
  kubectl apply -f . && \
  kubectl -n doit-lab-08 get secret $(kubectl -n doit-lab-08 get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
  ```

2. Start local proxy-access to gke-clusterIP based service-endpoint

  _To gain appropriate access to the web front-end of the application, we need a tunneled proxy endpoint from the local machine into the GKE cluster. The following command establishes the proxy endpoint and allows us to access under [this URL](https://localhost:8443/api/v1/namespaces/doit-lab-08/services/https:kubernetes-dashboard:/proxy/#/login). Attention! The following command starts a process which can only be interrupted by IPC (CTRL+c), further shell commands are no longer possible in this terminal until you break the call by pressing CTRL+c._
  
  ```bash
  kubectl port-forward service/kubernetes-dashboard 8443:443 -n doit-lab-08
  # You can access your deployed kubernetes-dashboard via `https://localhost:8443/` now.
  ```

## Optional Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-08` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-08
```

In this example we can access the authentication token with a much shorter command line (we just ignore the namespace property now).

```bash
kubectl get secret $(kubectl get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
```

## Application Clean-Up

```bash
kubectl delete -f .
```

## Links

- https://cloud.google.com/sdk/gcloud/reference/container/clusters/create
- https://github.com/kubernetes/dashboard/blob/master/docs/user/installation.md
- https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://phoenixnap.com/kb/kubectl-commands-cheat-sheet
