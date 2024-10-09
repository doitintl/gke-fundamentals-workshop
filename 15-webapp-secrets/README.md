# GKE Workshop LAB-15

## Web-Application with a secret

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Introduction

In the following lab roll out a static nginx page as single container Pod with a secret as volume.

## Deployment

1. Run deployment

```bash
kubectl apply -f .
```

## Cluster Application Check / Playground

1. You can check the state of Pods at any time with the following kubectl command:

```bash
kubectl get pods -n doit-lab-15
```

2. You can also permanently display the current log stream of the pod in question in your terminal using the following command:

```bash
kubectl get pods -n doit-lab-15 --watch
```

3. You will need to create a secret called `test-secret`

```bash
kubectl create secret generic test-secret -n doit-lab-15 --from-literal='username=my-app' --from-literal='password=39528$vdg7Jb'
```

4. You can also permanently display the current log stream of the pod in question in your terminal using the following command:

```bash
kubectl get pods -n doit-lab-15 --watch
```


5. Let's check if the secret is ther as volume and as env variable

```bash
kubectl exec -it static-web-app -n doit-lab-15 -- sh
```

## Optional Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-01` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-15
```

## Application Clean-Up

```bash
kubectl delete -f .
```

## Links

- https://cloud.google.com/sdk/gcloud/reference/container/clusters/create
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://phoenixnap.com/kb/kubectl-commands-cheat-sheet
