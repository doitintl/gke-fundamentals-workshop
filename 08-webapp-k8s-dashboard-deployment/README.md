# GKE Workshop LAB-08

## Kubernetes Dashboard Deployment

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GKE/K8s Version](https://img.shields.io/badge/k8s%20version-1.18.20-blue.svg)](#)
[![GCloud SDK Version](https://img.shields.io/badge/gcloud%20version-359.0.0-blue.svg)](#)

## Introduction

In the following lab we will set up our local development environment, provision the workshop cluster and roll out the Kubernetes-dashboard application stack ([source](https://github.com/kubernetes/dashboard/blob/master/docs/user/installation.md)). This lab will give us a basic insight into the standard Kubernetes resources, clarify an important approach regarding the ServiceAccounts and RBAC to use, and provide a control base for our other labs.

![application screenshot](../.github/media/lab-08-screenshot-small.png)

## Core Requirements

For the use of the local development environment for all GKE/K8s relevant CLI/API calls a certain tool set is required and Linux or macOS as operating system is recommended. If it is not possible to install our stack due to limitations in terms of feasibility/availability in the preparation, you can alternatively use the browser-internal cloud shell of your GCP console.

- `gcloud sdk` [installation](https://cloud.google.com/sdk/docs/install) tutorial
- `kubectl` [installation](https://kubernetes.io/docs/tasks/tools/) tutorial

## Cluster Preparation

The preparation of the GKE cluster is one of the first steps of our workshop and is the basis for all our further activity using the local development environment of all participants. We will pave the way to our first K8s application deployment step by step in the following section, learning some basics of using the gcloud SDK CLI and kubectl.

## GCloud SDK Preparation
```bash
gcloud components update ;
gcloud init ;
```

## Optional Terminal Preparation
```bash
alias k='kubectl'
```

## Cluster Provisioning

The present gcloud command call initializes the workshop-cluster as regional cluster configuration with one node in each of three availability zones.

_If you have already initialized the cluster, you can skip this step now!_

- Please make sure that you are also in the project prepared for this workshop or that your used dev/sandbox project has also been selected via `cloud init`!

- Init your GKE-Cluster with a unique identifier suffix

    ```bash
    printf "%s\n" "[INIT] workshop cluster" ;
    UNIQUE_CLUSTER_KEY=$RANDOM; gcloud container clusters create workshop-${UNIQUE_CLUSTER_KEY} \
    --machine-type n2-standard-2 \
    --scopes "https://www.googleapis.com/auth/source.read_write,cloud-platform" \
    --region europe-west1 \
    --node-locations europe-west1-b,europe-west1-c,europe-west1-d \
    --release-channel stable \
    --disk-type "pd-ssd" \
    --disk-size "60" \
    --num-nodes "1" \
    --max-nodes "1" \
    --min-nodes "1" \
    --logging=SYSTEM,WORKLOAD \
    --monitoring=SYSTEM \
    --network "default" \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing,NodeLocalDNS \
    --labels k8s-scope=gke-workshop-doit,k8s-cluster=primary,k8s-env=workshop && \
    printf "%s\n" "[INIT] test access new cluster using k8s API via kubectl" ; \
    kubectl get all --all-namespaces && kubectl cluster-info && \
    printf "\n%s\n\n" "[INIT] workshop cluster finally initialized and available by ID -> [ workshop-${UNIQUE_CLUSTER_KEY} ] <-" ;
    ```

- (optional) If it is necessary to re-authenticate to the created GKE cluster (e.g. to run kubectl commands) the following command may help:

    ```bash
    gcloud container clusters get-credentials workshop-${UNIQUE_CLUSTER_KEY}
    ```

- (optional) If there are unexpected allocation problems with cluster resources, the current user can also take over the cluster-wide-administration of his created cluster with the following command:

    ```bash
    kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
    ```

## Cluster Application Deployment

Make sure you handled all previous steps of this README! Now, as announced, we perform the actual deployment of the kubernetes-dashboard and provision an access-authorized user for token-based authentication at the frontend of the application.

1. Run deployment and fetch admin-user's access-token
  ```bash
  kubectl apply -f . && \
  kubectl -n doit-lab-08 get secret $(kubectl -n doit-lab-08 get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}" ;
  ```

2. Start local proxy-access to gke-clusterIP based service-endpoint

  _To gain appropriate access to the web front-end of the application, we need a tunneled proxy endpoint from the local machine into the GKE cluster. The following command establishes the proxy endpoint and allows us to access by [this URL](http://localhost:8001/api/v1/namespaces/doit-lab-08/services/https:kubernetes-dashboard:/proxy/#/login). Attention! The following command starts a process which can only be interrupted by IPC (CTRL+c), further shell commands are no longer possible in this terminal until you break the call by pressing CTRL+c._
  
  ```bash
  kubectl port-forward service/static-web-app-service 443:8443 -n doit-lab-08
  # You can access your deployed kubernetes-dashboard via `https://localhost:8443/` now.
  ```

## Optional Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-08` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-08
```

In this example we can access the authentication token with a much shorter command line (we just ignore the namespace property now).

```bash
kubectl get secret $(kubectl get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
```

## Application Clean-Up

```bash
kubectl delete -f . ;
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