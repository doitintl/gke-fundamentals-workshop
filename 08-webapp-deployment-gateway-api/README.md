# GKE Workshop LAB-08

## Web-Application Deployment, Gateway API Example

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Introduction

In the following lab we will roll out a static nginx deployment, similar to previous labs.
This deployment will be exposed by a service and a HTTP/S Load Balancer. The LB will be created using the new [Gateway API](https://gateway-api.sigs.k8s.io/) which is scheduled to replace the Ingress API.

## Deployment

1. Apply all manifests

```bash
kubectl apply -f .
```

2. Check current gateway state (external IP)

_this step can take up to 3 Minutes_

```bash
kubectl get gateway -n doit-lab-08 --watch
```

3. Confirm that a Load Balancer was created on the cloud

```bash
gcloud compute forwarding-rules list --filter='description~doit-lab-08'
```

## Cluster Application Check / Playground

1. You can check the state of Pods at any time with the following kubectl command:

```bash
kubectl get pods -n doit-lab-08
```

2. You can check your ingress target service with the following kubectl command:

```bash
kubectl get service -n doit-lab-08
```

3. You can get some more detailed information about your gateway resource by the following kubectl command:

```bash
kubectl describe gateway static-web-app-gateway -n doit-lab-08
```

4. You can also check the [HTTPRoute resource](https://gateway-api.sigs.k8s.io/api-types/httproute/) which defines all the routes that our Gateway will handle:

```bash
kubectl describe httproutes.gateway.networking.k8s.io static-web-app-httproute -n doit-lab-08
```

5. A couple of minutes after your gateway resource and the corresponding load balancer are provisioned (3-4 minutes):

5.1 You can check the benchmark of your web-application using apache-bench command as shown below:

```bash
ab -n 20 http://<external-ip-of-your-ingress-load-balancer>/
```

5.2 You can simulate some traffic to your ingress facing loadBalancer by the following ab-command:

```bash
ab -n 500 -c 25 http://<external-ip-of-your-ingress-load-balancer>/
```

5.3 Or just visit the workload by hitting the created LB IP:

```bash
  -> http://<external-ip-of-your-ingress-load-balancer>/
```

## Optional Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-08` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-08
```

In this example we can access the authentication token with a much shorter command line (we just ignore the namespace property now).

```bash
kubectl describe gateway static-web-app-gateway
```

## Application Clean-Up

```bash
kubectl delete -f .
```

## Links

- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://phoenixnap.com/kb/kubectl-commands-cheat-sheet
