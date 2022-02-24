# GKE Workshop LAB-06

## Web-Application Deployment, GCE-Ingress Example

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GKE/K8s Version](https://img.shields.io/badge/k8s%20version-1.18.20-blue.svg)](#)
[![GCloud SDK Version](https://img.shields.io/badge/gcloud%20version-359.0.0-blue.svg)](#)

## Introduction

In the following lab we will set up our local development environment, provision the workshop cluster and roll out our static web application example ([source](https://github.com/doitintl/labs-web-app-static). Your deployment will be exposed by corresponding pod-service and wait for incoming traffic through our GCE Ingress-Controller (`http://<external-lb-ip>`). 

![application screenshot](../.github/media/lab-06-screenshot-small.png)

## Deployment

1. Run deployment
  ```bash
  kubectl apply -f . 
  ```

2. Check current ingress state (external IP)

  _this step can take up to 3 Minutes_

  ```bash
  kubectl get ingress -n doit-lab-06 --watch
  ```

## Cluster Application Check / Playground

1. You can check the state of Pods at any time with the following kubectl command:
  ```bash
  kubectl get pods -n doit-lab-06
  ```

2. You can check your ingress target service with the following kubectl command:
  ```bash
  kubectl get service -n doit-lab-06
  ```

3. You can get some more detailed information about your ingress resource by the following kubectl command:
  ```bash
  kubectl describe ingress static-web-app-ingress -n doit-lab-06
  ```

4. As soon as your ingress resource, ingress controller and the corresponding loadBalancer is provisioned (3-4 minutes):

4.1 You can check the benchmark of your web-application using apache-bench command as shown below:
  ```bash
  ab -n 20 http://<external-ip-of-your-ingress-load-balancer>/
  ```

4.2 You can simulate some traffic to your ingress facing loadBalancer by the following ab-command:
  ```bash
  ab -n 500 -c 25 http://<external-ip-of-your-ingress-load-balancer>/
  ```

4.3 Or just visit the application by hitting your load-balancers external-IP:
  ```bash
    -> http://<external-ip-of-your-ingress-load-balancer>/
  ```

## Optional Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-06` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-06
```

## Application Clean-Up

```bash
kubectl delete -f .
```

## Links

- https://cloud.google.com/sdk/gcloud/reference/container/clusters/create
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://phoenixnap.com/kb/kubectl-commands-cheat-sheet
