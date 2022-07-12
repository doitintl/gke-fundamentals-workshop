# GKE Workshop LAB-02 (A)

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
## Introduction

In the following lab we will set up our local development environment, provision the workshop cluster and roll out our next< application, nginx ([source](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-quickstart.html)) as simple-pod/namespace stack. This lab will give us an additional insight into the Pod Kubernetes resource.

## Core Requirements

For the use of the local development environment for all GKE/K8s relevant CLI/API calls a certain tool set is required and Linux or MacOS as operating system is recommended. If it is not possible to install our stack due to limitations in terms of feasibility/availability in the preparation, you can alternatively use the browser-internal cloud shell of your GCP console.

- `gcloud sdk` [installation](https://cloud.google.com/sdk/docs/install) tutorial
- `kubectl` [installation](https://kubernetes.io/docs/tasks/tools/) tutorial

## Cluster Preparation

The preparation of the GKE cluster is one of the first steps of our workshop and is the basis for all our further activity using the local development environment of all participants. We will pave the way to our first K8s application deployment step by step in the following section, learning some of the basics of using the gcloud SDK CLI and kubectl.

## GCloud SDK Preparation

```bash
gcloud init
gcloud config set compute/zone europe-west1-b
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
kubectl cluster-info
```

Now it is time to give the current user complete control over the created cluster using RBAC.

```bash
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
```

In the last step we authenticate ourselves via the gcloud API to the generated GKE cluster and thus enable e.g. further command calls by `kubectl`.

```bash
gcloud container clusters get-credentials workshop
```

## Cluster Application Deployment

Make sure you handled all previous steps of this README! Now, as announced, we perform the actual deployment of the kubernetes-dashboard and provision an access-authorized user for token-based authentication at the frontend of the application.

### Run Deployment

```bash
kubectl apply -f nginx-pod.yaml
```

### Switch Namespace

You can set the current k8s context to our lab exercise namespace `doit-lab-02-a` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-02-a
```

### Watch Deployment Process

```bash
kubectl get pods --watch
```

### Get Details about your Pod

```bash
kubectl describe pod nginx
```

### Open Local Proxy to your Pod

_you can check the results by visiting http://localhost:8080_

```bash
kubectl port-forward nginx 8080:80
```

## Application Clean-Up

```bash
kubectl delete -f nginx-pod.yaml
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
