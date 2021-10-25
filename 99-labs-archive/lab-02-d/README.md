# GKE Workshop LAB-02 (D)

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GKE/K8s Version](https://img.shields.io/badge/k8s%20version-1.18.20-blue.svg)](#)
[![GCloud SDK Version](https://img.shields.io/badge/gcloud%20version-359.0.0-blue.svg)](#)
[![Build Status](https://img.shields.io/badge/status-unstable-E47911.svg)](#)

## Introduction

In the following lab we will set up our local development environment, provision the workshop cluster and provide some job/batch runner examples. This lab will give us an additional insight into combining Kubernetes resource batch/job.

## Core Requirements

For the use of the local development environment for all GKE/K8s relevant CLI/API calls a certain tool set is required and Linux or MacOS as operating system is recommended. If it is not possible to install our stack due to limitations in terms of feasibility/availability in the preparation, you can alternatively use the browser-internal cloud shell of your GCP console.

- `gcloud sdk` [installation](https://cloud.google.com/sdk/docs/install) tutorial
- `kubectl` [installation](https://kubernetes.io/docs/tasks/tools/) tutorial

## Cluster Preparation

The preparation of the GKE cluster is one of the first steps of our workshop and is the basis for all our further activity using the local development environment of all participants. We will pave the way to our first K8s application deployment step by step in the following section, learning some of the basics of using the gcloud SDK CLI and kubectl.

## GCloud SDK Preparation
```bash
gcloud init ;
gcloud config set compute/zone europe-west1-b ;
```

## Cluster Provisioning

The present gcloud command call initializes the workshop in a configuration that is as compatible as possible for all upcoming labs. If you have already initialized the cluster, you can skip this step!

```bash
gcloud container clusters create workshop \
--machine-type n1-standard-4 \
--node-locations europe-west1-b,europe-west1-c,europe-west1-d \
--num-nodes "1" \
--release-channel stable \
--region europe-west1 \
--image-type "ubuntu" \
--disk-type "pd-ssd" \
--disk-size "120" \
--network "default" \
--logging=SYSTEM,WORKLOAD \
--monitoring=SYSTEM \
--scopes "https://www.googleapis.com/auth/source.read_write,cloud-platform" \
--addons HorizontalPodAutoscaling,HttpLoadBalancing,NodeLocalDNS \
--labels k8s-scope=kubernetes-workshop-doit,k8s-cluster=primary,environment=workshop && \
kubectl cluster-info ;
```

Now it is time to give the current user complete control over the created cluster using RBAC.

```bash
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
```

In the last step we authenticate ourselves via the gcloud API to the generated GKE cluster and thus enable e.g. further command calls by `kubectl`.

```bash
gcloud container clusters get-credentials workshop
```

## Cluster Job Deployment

### Create Namespace & jump into it
```bash
kubectl apply -f 00-namespace.yaml && kubectl config set-context --current --namespace=doit-lab-02-d
```

### Create Jobs

#### 01. SimpleJob (01-job-simple.yaml)

This is a very simple, single-count running job definition

```bash
kubectl apply -f 01-job-simple.yaml && kubectl get pods --watch ;
```

#### 02. MultipleJob (02-job-multiple.yaml)

For example, we may have a queue of messages that needs processing. We must spawn consumer jobs that pull messages from the queue until it’s empty. To implement this pattern in Kubernetes Jobs, we set the .spec.completions parameter to a number (must be a non-zero, positive number). The Job starts spawning pods up till the completions number. The Job regards itself as complete when all the pods terminate with a successful exit code.

```bash
kubectl apply -f 02-job-multiple.yaml && kubectl get pods --watch ;
```

#### 03. MultipleJob (03-job-parallel-wq.yaml)

Another pattern may involve the need to run multiple jobs, but instead of running them one after another, we need to run several of them in parallel. Parallel processing decreases the overall execution time. It has its application in many domains, like data science and AI.

```bash
kubectl apply -f 03-job-parallel-wq.yaml && kubectl get pods --watch ;
```

#### 04. JobRunner with exit-limitation (04-job-exec-limit.yaml)

Sometimes, you are more interested in running your Job for a specific amount of time regardless of whether or not the process completes successfully. Think of an AI application that needs to consume data from Twitter. You’re using a cloud instance, and the provider charges you for the amount of CPU and network resources you are utilizing. You are using a Kubernetes Job for data consumption, and you don’t want it to run for more than one hour.

Kubernetes Jobs offer the spec.activeDeadlineSeconds parameter. Setting this parameter to a number will terminate the Job immediately once this number of seconds is reached.

Notice that this setting overrides .spec.backoffLimit, which means that if the pod fails and the Job reaches its deadline limit, it will not restart the failing pod. It will stop immediately.

```bash
kubectl apply -f 04-job-exec-limit.yaml && kubectl get pods --watch ;
```

#### 04. MultipleJob auto clean-up by ttl (05-job-ttl.yaml)

When a Kubernetes Job finishes, neither the Job nor the pods that it created get deleted automatically. You have to remove them manually. This feature ensures that you are still able to view the logs and the status of the finished Job and its pods.

It’s worth noting that there is a new feature in Kubernetes that allows you to specify the number of seconds after which a completed Job gets deleted together with its pods. This feature uses the TTL controller. Notice that this feature is still in alpha state.

```bash
kubectl apply -f 05-job-ttl.yaml && kubectl get pods --watch ;
```

## Application Clean-Up

```bash
kubectl delete -f <your-job-declaration-file.yaml>
```

## Links

- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://phoenixnap.com/kb/kubectl-commands-cheat-sheet

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.

## Copyright

Copyright © 2021 DoiT International