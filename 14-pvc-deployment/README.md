# GKE Workshop LAB-14 (B)

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GKE/K8s Version](https://img.shields.io/badge/k8s%20version-1.18.20-blue.svg)](#)
[![GCloud SDK Version](https://img.shields.io/badge/gcloud%20version-359.0.0-blue.svg)](#)
[![elasticSearch Version](https://img.shields.io/badge/elasticsearch%20version-6.2.4-green.svg)](#)
[![Build Status](https://img.shields.io/badge/status-unstable-E47911.svg)](#)

## Introduction

In the following lab we will set up our local development environment, provision the workshop cluster and roll out our next application, elasticsearch ([source](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-quickstart.html)) single-node stack. This lab will give us an additional insight into the standard Kubernetes resources, clarify an important approach regarding the PV/PVCs and provide a control base for our next-step labs.
## Deployment

### Run Deployment
```bash
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-elasticsearch-simple.yaml
```

## Application Clean-Up

```bash
kubectl delete -f 00-namespace.yaml
```

## Links

- https://gist.github.com/pyk/3fc87db27eed864e354974bc25aabf88
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://phoenixnap.com/kb/kubectl-commands-cheat-sheet
