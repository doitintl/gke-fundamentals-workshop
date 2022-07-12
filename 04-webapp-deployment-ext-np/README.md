# GKE Workshop LAB-04

## Web-Application Deployment, NodePort Example

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Introduction

In the following lab we will set up our local development environment, provision the workshop cluster and roll out our static web application example ([source](https://github.com/doitintl/labs-web-app-static). Your deployment will be exposed by corresponding pod-service and wait for incoming traffic through NodePort `30000` (`http://<one-node-ip>:30000`) at all available nodes in all zones.

![application screenshot](../.github/media/lab-04-screenshot-small.png)

## Deployment

1. Run deployment

```bash
kubectl apply -f .
```

2. Check current service load-balancer state (external IP)

_this step can take up to 2 Minutes_

```bash
kubectl get service -n doit-lab-04 --watch
```

## Cluster Application Check / Playground

1. You can check the state of Pods at any time with the following kubectl command:

```bash
kubectl get pods -n doit-lab-04
```

2. You can check your deployment with the following kubectl command:

```bash
kubectl get deployments -n doit-lab-04
```

3. You can check the corresponding service endpoint by the following kubectl command:

```bash
kubectl get services -n doit-lab-04
```

4. You can check your external IP addresses of your node by entering the following command:

```bash
kubectl get nodes -o jsonpath='{ $.items[*].status.addresses[?(@.type=="ExternalIP")].address }' -n doit-lab-04 | tr ' ' '\n'
```

5. To access your service by NodePort you have to allow tcp-access to your port-definition (e.g. 30000)

```bash
gcloud compute firewall-rules create my-node-port-opened-service --allow tcp:30000
```

6. Now you can access your service calling one of your external node-IPs:30000 in your browser

```bash
-> http://<one-of-your-external-node-ip>:30000
```

## Optional Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-04` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-04
```

## Application Clean-Up

```bash
gcloud compute firewall-rules delete my-node-port-opened-service
kubectl delete -f .
```

## Links

- https://cloud.google.com/sdk/gcloud/reference/container/clusters/create
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://phoenixnap.com/kb/kubectl-commands-cheat-sheet
