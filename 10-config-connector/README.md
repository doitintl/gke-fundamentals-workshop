# GKE Workshop LAB-07

## Config Connector example

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GKE/K8s Version](https://img.shields.io/badge/k8s%20version-1.18.20-blue.svg)](#)
[![GCloud SDK Version](https://img.shields.io/badge/gcloud%20version-359.0.0-blue.svg)](#)
[![elasticSearch Version](https://img.shields.io/badge/elasticsearch%20version-6.2.4-green.svg)](#)
[![Build Status](https://img.shields.io/badge/status-unstable-E47911.svg)](#)

## Introduction

In the following lab we will set up our local development environment, provision the workshop GKE cluster with the [Config connector add-on](https://cloud.google.com/config-connector/docs/how-to/install-upgrade-uninstall) installed, then create some resources in GCP using [Config Connector CRDs](https://cloud.google.com/config-connector/docs/reference/overview). This lab will give insight into create Cloud infrastructure and resources using Config Connector, which is a simple way to define infrastructure as code.

## Core Requirements

For the use of the local development environment for all GKE/K8s relevant CLI/API calls a certain tool set is required and Linux or MacOS as operating system is recommended. If it is not possible to install our stack due to limitations in terms of feasibility/availability in the preparation, you can alternatively use the browser-internal cloud shell of your GCP console.

- `gcloud sdk` [installation](https://cloud.google.com/sdk/docs/install) tutorial
- `kubectl` [installation](https://kubernetes.io/docs/tasks/tools/) tutorial
- `<PROJECT_ID>` is used throughout the lab as a placeholder, you can either manually update it on demand, or run the following command to find and replace (of course set your real project name instead of `INSERT_PROJECT_NAME_HERE`):
    `grep -lr '<PROJECT_ID>' | xargs -I{} sed 's/<PROJECT_ID>/INSERT_PROJECT_NAME_HERE/g' {}`

## Cluster Preparation

The preparation of the GKE cluster is one of the first steps of our workshop and is the basis for all our further activity using the local development environment of all participants. We will pave the way to our first K8s application deployment step by step in the following section, learning some of the basics of using the gcloud SDK CLI and kubectl.

## GCloud SDK Preparation
```bash
gcloud init ;
gcloud config set compute/zone europe-west1-b ;
```

## Cluster Provisioning

The present gcloud command call initializes the workshop in a configuration that is as compatible as possible for all upcoming labs. If you have already initialized the cluster, you can skip this step!

Update `<PROJECT_ID>` with the correct project name throughout the tutorial.

```bash
gcloud container clusters create workshop \
--machine-type n1-standard-4 \
--node-locations europe-west1-b,europe-west1-c,europe-west1-d \
--num-nodes "1" \
--release-channel stable \
--region europe-west1 \
--disk-type "pd-ssd" \
--disk-size "120" \
--network "default" \
--logging=SYSTEM,WORKLOAD \
--monitoring=SYSTEM \
--scopes "https://www.googleapis.com/auth/source.read_write,cloud-platform" \
--labels k8s-scope=kubernetes-workshop-doit,k8s-cluster=primary,environment=workshop \
--addons HorizontalPodAutoscaling,HttpLoadBalancing,ConfigConnector \
--workload-pool=<PROJECT_ID>.svc.id.goog && \
kubectl cluster-info ;
```

Now it is time to give the current user complete control over the created cluster using RBAC.

```bash
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
```

## Create an identity for Config Connector

The Config Connector controller utilizes [Workload Identity](../09-workload-identity-pubsub/README.md) to impersonate an IAM service account with permissions in the project. This service account needs to have `roles/owner` role (if you plan to manage IAM, or resources on the folder/organization level), or `roles/editor` otherwise.

```bash
gcloud iam service-accounts create config-connector-sa

gcloud projects add-iam-policy-binding <PROJECT_ID> \
    --member="serviceAccount:config-connector-sa@<PROJECT_ID>.iam.gserviceaccount.com" \
    --role="roles/owner"
```

Then allow the Config Connector controller KSA to use the GSA we just created:

```bash
gcloud iam service-accounts add-iam-policy-binding \
    config-connector-sa@<PROJECT_ID>.iam.gserviceaccount.com \
    --member="serviceAccount:<PROJECT_ID>.svc.id.goog[cnrm-system/cnrm-controller-manager]" \
    --role="roles/iam.workloadIdentityUser"
```

## Configure Config Connector to run in cluster mode

Config Connector can run either in `cluster` or in `namespaced` mode. `cluster` mode will allow the controller to monitor the entire cluster for Config Connector resources. `namespaced` mode will require additional configuration that will allow the controller to monitor only specific namespaces.
We will configure Config Connector to run in `cluster` mode, read [here](https://cloud.google.com/config-connector/docs/how-to/advanced-install#namespaced-mode) for instructions for `namespaced` mode.

```bash
# replace <PROJECT_ID> with the correct value in this file before applying!!
kubectl apply -f 00-configconnector.yaml
```

As mentioned above, Config Connector can create resource in the [Organization, Folder or Project level](https://cloud.google.com/config-connector/docs/how-to/organizing-resources/overview), we will focus on creating resources in the project.
For that, we will need to set an [annotation specifying the project id](https://cloud.google.com/config-connector/docs/how-to/organizing-resources/project-scoped-resources), either on the Namespace level, or on each individual resource.

## Create a Namespace

In order to avoid annotating each individual resource, we will create the Namespace with the annotation setting the correct project id:

```bash
# replace <PROJECT_ID> with the correct value in this file before applying!!
kubectl apply -f 01-namespace.yaml
```

## Create Pub/Sub topic and subscription

Similar to the previous lab, we will create a Pub/Sub topic and subscription, this time using Config Connector (I suggest reviewing the manifests):

```bash
kubectl apply -f 02-pubsub.yaml
```

Wait for our newly created resources to be ready:

```bash
kubectl wait --for=condition=READY pubsubtopics echo

kubectl wait --for=condition=READY pubsubsubscription echo-read
```

## Create KSA, GSA and IAM bindings

We will use Config Connector in conjunction with Workload Identity, to create a GSA with IAM permissions to subscribe to pubsub, then create a KSA that can use that GSA with Workload Identity.

```bash
# replace <PROJECT_ID> with the correct value in this file before applying!!
kubectl apply -f 03-iam.yaml

kubectl apply -f 04-serviceaccount.yaml
```

### Run Deployment
```bash
kubectl apply -f 05-pubsub-deployment.yaml

# wait for pod to be ready, break this command once ready
kubectl get pod --watch --selector app=pubsub
```

### Test the Pub/Sub connection

Now we can tail the logs of our newly created pod, then post a message to the Pub/Sub topic and verify the connection:

```bash
kubectl logs -f --selector app=pubsub
```

In another terminal window, post a message to the echo topic:

```bash
gcloud pubsub topics publish echo --message="Hello, world\!"
```

## Additional notes on Config Connector

### Acquiring existing resources

If a resource created by Config Connector already exists in the project/folder/org, [Config Connector will take control over it](https://cloud.google.com/config-connector/docs/how-to/managing-deleting-resources#acquiring_an_existing_resource). It will also modify any configuration that diverges from the manifest.

### Deletion policy

[By default](https://cloud.google.com/config-connector/docs/how-to/managing-deleting-resources#keeping_resources_after_deletion), Config Connector will delete the associated GCP resource when you delete Config Connector resource. If this is not desired, an annotation can be set to abandon the GCP resource on deletion:
`cnrm.cloud.google.com/deletion-policy: abandon`

### Conflict prevention

It is possible to create several Config Connector resources that are backed by the same GCP resource, this can lead to conflicts. If you have a use-case the necessitates doing that, [you can disable conflict prevention](https://cloud.google.com/config-connector/docs/concepts/managing-conflicts#modifying_conflict_prevention) to allow multiple Config Connector resources backed by the same GCP resource.
This will usually require configuring the [deletion policy](#deletion-policy) of the resource as well.

## Optional Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-10` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-10
```

Inspect each YAML manifest before applying, describe created resources with `kubectl` to inspect each object after creation.

## Application Clean-Up

```bash
# delete k8s namespace and resources in it
kubectl delete ns doit-lab-10

# optional: delete GKE cluster
gcloud container clusters delete workshop

# optional: delete Config Connector IAM Service Account (if cluster is deleted)
gcloud iam serviceaccount delete config-connector-sa@<PROJECT_ID>.iam.gserviceaccount.com
```

## Links

- https://cloud.google.com/config-connector/docs/overview
- https://cloud.google.com/config-connector/docs/how-to/install-upgrade-uninstall
- https://cloud.google.com/config-connector/docs/how-to/organizing-resources/overview
- https://cloud.google.com/config-connector/docs/how-to/getting-started
- https://cloud.google.com/config-connector/docs/reference/overview
- https://cloud.google.com/config-connector/docs/how-to/managing-deleting-resources
- https://cloud.google.com/config-connector/docs/concepts/managing-conflicts
- https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
- https://cloud.google.com/kubernetes-engine/docs/tutorials/authenticating-to-cloud-platform
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/

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
