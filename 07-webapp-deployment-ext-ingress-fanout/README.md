# GKE Workshop LAB-07

## Web-Application Deployment, GCE-FanOut-Ingress Example

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Introduction

In the following lab we will roll out three different versions of a static nginx page, each mounting a different configuration from a ConfigMap.
Those deployments will be exposed by corresponding services and wait for incoming traffic through our GCE Ingress-Controller. The different versions will be available by path-based routing through an external load-balancer (`http://<external-lb-ip>/`,`http://<external-lb-ip>/v2/` and `http://<external-lb-ip>/v3/`).

## Deployment

1. Run deployment

```bash
kubectl apply -f .
```

2. Check current ingress state (external IP)

_this step can take up to 3 Minutes_

```bash
kubectl get ingress -n doit-lab-07 --watch
```

3. Confirm that a Load Balancer was created on the cloud

```bash
gcloud compute forwarding-rules list --filter='description~doit-lab-07'
```

## Cluster Application Check / Playground

1. You can check the state of Pods at any time with the following kubectl command:

```bash
kubectl get pods -n doit-lab-07
```

2. You can check your ingress target service with the following kubectl command:

```bash
kubectl get service -n doit-lab-07
```

3. You can get some more detailed information about your ingress resource by the following kubectl command:

```bash
kubectl describe ingress static-web-app-ingress -n doit-lab-07
```

4. A couple of minutes after your ingress resource, ingress controller and the corresponding loadBalancer are provisioned (3-4 minutes):

4.1 You can check the benchmark of your web-application using apache-bench command as shown below:

```bash
ab -n 20 http://<external-ip-of-your-ingress-load-balancer>/
```

4.2 You can simulate some traffic to your ingress facing loadBalancer by the following ab-command:

```bash
ab -n 500 -c 25 http://<external-ip-of-your-ingress-load-balancer>/
```

4.3 Or just visit the three different application versions by hitting their ingress-path definition:

```bash
  -> version_1 - http://<external-ip-of-your-ingress-load-balancer>/
  -> version_2 - http://<external-ip-of-your-ingress-load-balancer>/v2/
  -> version_3 - http://<external-ip-of-your-ingress-load-balancer>/v3/
```

## Optional Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-07` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-07
```

In this example we can access the authentication token with a much shorter command line (we just ignore the namespace property now).

```bash
kubectl describe ingress static-web-app-ingress
```

## Application Clean-Up

```bash
kubectl delete -f .
```

## Links

- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://phoenixnap.com/kb/kubectl-commands-cheat-sheet
