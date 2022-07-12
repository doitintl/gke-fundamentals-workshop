# GKE Workshop LAB-01 (A)

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GKE/K8s Version](https://img.shields.io/badge/k8s%20version-1.18.20-blue.svg)](#)
[![GCloud SDK Version](https://img.shields.io/badge/gcloud%20version-359.0.0-blue.svg)](#)
[![Build Status](https://img.shields.io/badge/status-unstable-E47911.svg)](#)

## Introduction

In the following lab we will set up our local development environment, provision the workshop cluster and roll out our first application, the Kubernetes-dashboard ([source](https://github.com/kubernetes/dashboard/blob/master/docs/user/installation.md)). This lab will give us a basic insight into the standard Kubernetes resources, clarify an important approach regarding the ServiceAccounts and RBAC to use, and provide a control base for our other labs.

## Core Requirements

For the use of the local development environment for all GKE/K8s relevant CLI/API calls a certain tool set is required and Linux or MacOS as operating system is recommended. If it is not possible to install our stack due to limitations in terms of feasibility/availability in the preparation, you can alternatively use the browser-internal cloud shell of your GCP console.

- `gcloud sdk` [installation](https://cloud.google.com/sdk/docs/install) tutorial
- `kubectl` [installation](https://kubernetes.io/docs/tasks/tools/) tutorial

## Cluster Preparation

The preparation of the GKE cluster is one of the first steps of our workshop and is the basis for all our further activity using the local development environment of all participants. We will pave the way to our first K8s application deployment step by step in the following section, learning some of the basics of using the gcloud SDK CLI and kubectl.

## GCloud SDK Preparation

This gcloud command initializes your

```bash
gcloud init ;
```

## Cluster Provisioning

The present gcloud command call initializes the workshop in a configuration that is as compatible as possible for all upcoming labs.

_If you have already initialized the cluster, you can skip this step now!_

```bash
RANDOM_CLUSTER_KEY=$RANDOM; gcloud container clusters create workshop-${RANDOM_CLUSTER_KEY} \
--machine-type n1-standard-4 \
--scopes "https://www.googleapis.com/auth/source.read_write,cloud-platform" \
--node-locations europe-west1-b,europe-west1-c,europe-west1-d \
--release-channel stable \
--region europe-west1 \
--image-type "ubuntu" \
--disk-type "pd-ssd" \
--disk-size "60" \
--num-nodes "1" \
--logging=SYSTEM,WORKLOAD \
--monitoring=SYSTEM \
--network "default" \
--addons HorizontalPodAutoscaling,HttpLoadBalancing,NodeLocalDNS \
--labels k8s-scope=gke-workshop-doit,k8s-cluster=primary,environment=workshop && \
kubectl get all --all-namespaces && kubectl cluster-info && \
printf "\n%s\n\n" "-> [workshop-${RANDOM_CLUSTER_KEY}] <-" ;
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

### Run Deployment and fetch Admin-User Access-Token

```bash
kubectl apply -f k8s-dashboard.yaml && \
kubectl -n doit-lab-01-a get secret $(kubectl -n doit-lab-01-a get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}" ;
```

### Start Local Proxy Access to ClusterIP based Service Endpoint

To gain appropriate access to the web front-end of the application, we need a tunneled proxy endpoint from the local machine into the GKE cluster. The following command establishes the proxy endpoint and allows us to access by [this URL](http://localhost:8001/api/v1/namespaces/doit-lab-01-a/services/https:kubernetes-dashboard:/proxy/#/login). Attention! The following command starts a process which can only be interrupted by IPC (CTRL+c), further shell commands are no longer possible in this terminal until you break the call by pressing CTRL+c.

```bash
kubectl proxy ;
```

## Additional Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-01-a` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-01-a
```

In this example we can access the authentication token with a much shorter command line (we just ignore the namespace property now).

```bash
kubectl get secret $(kubectl get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
```

## Application Clean-Up

```bash
kubectl delete -f k8s-dashboard.yaml ; killall kubectl &>/dev/null
```

## Links

- https://cloud.google.com/sdk/gcloud/reference/container/clusters/create
- https://github.com/kubernetes/dashboard/blob/master/docs/user/installation.md
- https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
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
