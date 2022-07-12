# GKE Workshop LAB-12 (D)

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GKE/K8s Version](https://img.shields.io/badge/k8s%20version-1.18.20-blue.svg)](#)
[![GCloud SDK Version](https://img.shields.io/badge/gcloud%20version-359.0.0-blue.svg)](#)
[![Build Status](https://img.shields.io/badge/status-unstable-E47911.svg)](#)

## Introduction

In the following lab we will set up our local development environment, provision the workshop cluster and provide some job/batch runner examples. This lab will give us an additional insight into combining Kubernetes resource batch/job.

## Deployment

### Create Namespace & jump into it

```bash
kubectl apply -f 00-namespace.yaml && kubectl config set-context --current --namespace=doit-lab-12
```

### Create Jobs

#### 01. SimpleJob (01-job-simple.yaml)

This is a very simple, single-count running job definition

```bash
kubectl apply -f 01-job-simple.yaml && kubectl get pods --watch
```

#### 02. MultipleJob (02-job-multiple.yaml)

For example, we may have a queue of messages that needs processing. We must spawn consumer jobs that pull messages from the queue until it’s empty. To implement this pattern in Kubernetes Jobs, we set the .spec.completions parameter to a number (must be a non-zero, positive number). The Job starts spawning pods up till the completions number. The Job regards itself as complete when all the pods terminate with a successful exit code.

```bash
kubectl apply -f 02-job-multiple.yaml && kubectl get pods --watch
```

#### 03. MultipleJob (03-job-parallel-wq.yaml)

Another pattern may involve the need to run multiple jobs, but instead of running them one after another, we need to run several of them in parallel. Parallel processing decreases the overall execution time. It has its application in many domains, like data science and AI.

```bash
kubectl apply -f 03-job-parallel-wq.yaml && kubectl get pods --watch
```

#### 04. JobRunner with exit-limitation (04-job-exec-limit.yaml)

Sometimes, you are more interested in running your Job for a specific amount of time regardless of whether or not the process completes successfully. Think of an AI application that needs to consume data from Twitter. You’re using a cloud instance, and the provider charges you for the amount of CPU and network resources you are utilizing. You are using a Kubernetes Job for data consumption, and you don’t want it to run for more than one hour.

Kubernetes Jobs offer the spec.activeDeadlineSeconds parameter. Setting this parameter to a number will terminate the Job immediately once this number of seconds is reached.

Notice that this setting overrides .spec.backoffLimit, which means that if the pod fails and the Job reaches its deadline limit, it will not restart the failing pod. It will stop immediately.

```bash
kubectl apply -f 04-job-exec-limit.yaml && kubectl get pods --watch
```

#### 04. MultipleJob auto clean-up by ttl (05-job-ttl.yaml)

When a Kubernetes Job finishes, neither the Job nor the pods that it created get deleted automatically. You have to remove them manually. This feature ensures that you are still able to view the logs and the status of the finished Job and its pods.

It’s worth noting that there is a new feature in Kubernetes that allows you to specify the number of seconds after which a completed Job gets deleted together with its pods. This feature uses the TTL controller. Notice that this feature is still in alpha state.

```bash
kubectl apply -f 05-job-ttl.yaml && kubectl get pods --watch
```

## Application Clean-Up

```bash
kubectl delete -f <your-job-declaration-file.yaml>
```

## Links

- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://phoenixnap.com/kb/kubectl-commands-cheat-sheet
