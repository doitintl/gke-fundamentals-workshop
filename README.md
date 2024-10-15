# GKE Fundamentals

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GKE/K8s Version](https://img.shields.io/badge/k8s%20version-1.30.5-blue.svg)](#)
[![GCloud SDK Version](https://img.shields.io/badge/gcloud%20version-496.0.0-blue.svg)](#)

## Introduction

In this full-day workshop, we will look at some core mechanisms of GKE. We will look at different provisioning models of applications, scaling, monitoring, and command-line-based cluster control. The present subject areas have not yet been fully formulated. There may be changes to the contents and the current schedule. The labs require functional access to a GCP project and a uniform toolset in the local development environment (e.g., kubectl, GCP cloud SDK command-line tools). The lectures on each topic will take about 45 minutes, and the labs will take about 30 minutes each.

## Available Labs

| Lab/Folder                                                                           | Description                                                             |
| ------------------------------------------------------------------------------------ | ----------------------------------------------------------------------- |
| [01-single-container-pod](./01-single-container-pod)                                 | simple single container pod example for a static web application        |
| [02-multiple-container-pod](./02-multiple-container-pod)                             | advanced multi-container pod example for our web application            |
| [03-webapp-deployment](./03-webapp-deployment)                                       | simple deployment abstraction from lab-01 for a static web application  |
| [04-webapp-deployment-ext-np](./04-webapp-deployment-ext-np)                         | simple nodePort service exposing example for this application           |
| [05-webapp-deployment-ext-lb](./05-webapp-deployment-ext-lb)                         | simple loadBalancer service exposing example using the same backend-app |
| [06-webapp-deployment-ext-ingress](./06-webapp-deployment-ext-ingress)               | simple ingress example using gce-based ingress controller               |
| [07-webapp-deployment-ext-ingress-fanout](./07-webapp-deployment-ext-ingress-fanout) | advanced ingress fan-out example for multiple app-versions              |
| [08-webapp-deployment-gateway-api](./08-webapp-deployment-gateway-api) | example deployment exposed using Gateway API |
| [09-workload-identity-pubsub](./09-workload-identity-pubsub) | connect a workload to Pub/Sub using Workload Identity Federation for GKE |
| [10-config-connector](./10-config-connector) | deploy and configure Config Connector, the use it to provision Pub/Sub resources and connect a workload  |
| [11-rbac-podlabeler](./11-rbac-podlabeler) | demonstrates RBAC permissions |
| [12-jobs](./12-jobs) | several examples of Kubernetes Jobs
| [13-hpa](./13-hpa) | scaling a Deployment using HorizontalPodAutoscaler |
| [14-pvc-deployment](./14-pvc-deployment) | an example deployment with a PersistentVolumeClaim|

## Core Requirements

For the use of the local development environment for all GKE/K8s relevant CLI/API calls a certain tool set is required and Linux or macOS as operating system is recommended. If it is not possible to install our stack due to limitations in terms of feasibility/availability in the preparation, you can alternatively use the browser-internal cloud shell of your GCP console.

- `gcloud sdk` [installation](https://cloud.google.com/sdk/docs/install) tutorial
- `kubectl` [installation](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#install_kubectl) tutorial
- `gke-gcloud-auth-plugin` [installation](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#install_plugin)

## Workshop Cluster Preparation

The preparation of the GKE cluster is one of the first steps of our workshop and is the basis for all our further activity using the local development environment of all participants. We will pave the way to our first K8s application deployment step by step in the following section, learning some of the basics of using the gcloud SDK CLI and kubectl.

## GCloud SDK Preparation

```bash
gcloud components update
gcloud init
```

## Optional Terminal Preparation

```bash
alias k='kubectl'
```

## Workshop Cluster Provisioning

The following `gcloud` command call initializes the workshop-cluster as a regional Autopilot cluster .

- Please make sure that you are also in the project prepared for this workshop or that your used dev/sandbox project has also been selected via `cloud init`!

- Init your GKE-Cluster with a unique identifier suffix (_and remind your cluster-id_)

  ```bash
  printf "%s\n" "[INIT] workshop cluster"
  UNIQUE_CLUSTER_KEY=$RANDOM; GCP_PROJECT=$(gcloud config get core/project);
  gcloud container clusters create-auto workshop-${UNIQUE_CLUSTER_KEY} \
  --region europe-west1 \
  --release-channel regular \
  --logging=SYSTEM,WORKLOAD \
  --monitoring=SYSTEM \
  --network "default" \
  --subnetwork default && \
  printf "%s\n" "[INIT] test access new cluster using k8s API via kubectl" \
  kubectl get all --all-namespaces && kubectl cluster-info && \
  printf "\n%s\n\n" "[INIT] workshop cluster finally initialized and available by ID -> [ workshop-${UNIQUE_CLUSTER_KEY} ] <-"
  ```

## Workshop Cluster cleanup

In order to delete the cluster and all resources within it, you can run the following command (requires confirmation):

```bash
gcloud container clusters delete workshop-${UNIQUE_CLUSTER_KEY} --region europe-west1
```

## Links

- pydevop's [gcloud cheat sheet](https://gist.github.com/pydevops/cffbd3c694d599c6ca18342d3625af97) markdown paper

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE.md) for full details.

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
